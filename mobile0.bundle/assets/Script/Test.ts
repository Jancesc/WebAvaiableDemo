
const { ccclass, property } = cc._decorator;

@ccclass
export default class NewClass extends cc.Component {

    private _resumeAttempts = 0;
    private _maxResumeAttempts = 3;
    private _resumeTimer = null;

    onLoad() {
        // 使用捕获阶段监听pageshow事件，确保尽早处理
        window.addEventListener('pageshow', this.onPageShow.bind(this), true);
        
        // 使用自定义的展示事件处理函数
        cc.game.on(cc.game.EVENT_SHOW, this.onGameShow.bind(this));
        cc.game.on(cc.game.EVENT_HIDE, this.onGameHide.bind(this));
    }

    onPageShow(event) {
        console.log("pageshow事件触发", event.persisted);
        if (event.persisted && cc.sys.os === cc.sys.OS_IOS) {
            // 清除之前可能存在的定时器
            this.clearResumeTimer();
            
            // 重置恢复尝试次数
            this._resumeAttempts = 0;
            
            // 立即尝试一次恢复
            this.onResume();
            
            // 设置多次尝试恢复的定时器
            this.scheduleResumeAttempts();
        }
    }

    onGameShow() {
        console.log("Game.EVENT_SHOW");
        if (cc.sys.os === cc.sys.OS_IOS) {
            // 清除之前可能存在的定时器
            this.clearResumeTimer();
            
            // 重置恢复尝试次数
            this._resumeAttempts = 0;
            
            // 立即尝试一次恢复
            this.onResume();
            
            // 设置多次尝试恢复的定时器
            this.scheduleResumeAttempts();
        }
    }

    onGameHide() {
        console.log("Game.EVENT_HIDE");
        // 清除恢复定时器
        this.clearResumeTimer();
    }

    scheduleResumeAttempts() {
        // 设置多次尝试，间隔递增
        this._resumeTimer = setTimeout(() => {
            this._resumeAttempts++;
            if (this._resumeAttempts < this._maxResumeAttempts) {
                console.log(`第${this._resumeAttempts}次尝试恢复AudioContext`);
                this.onResume();
                this.scheduleResumeAttempts();
            }
        }, 300 * (this._resumeAttempts + 1)); // 300ms, 600ms, 900ms递增间隔
    }

    clearResumeTimer() {
        if (this._resumeTimer) {
            clearTimeout(this._resumeTimer);
            this._resumeTimer = null;
        }
    }

    @property(cc.AudioClip)
    audioClip: cc.AudioClip = null;

    start() {}

    onDestroy() {
        // 清除定时器
        this.clearResumeTimer();
        
        // 移除事件监听
        window.removeEventListener('pageshow', this.onPageShow.bind(this), true);
        cc.game.off(cc.game.EVENT_SHOW, this.onGameShow, this);
        cc.game.off(cc.game.EVENT_HIDE, this.onGameHide, this);
    }

    play() {
        // 在播放前检查AudioContext状态
        if (cc.sys.os === cc.sys.OS_IOS) {
            const globalContext = cc.sys.__audioSupport.context;
            if (globalContext && 
                (globalContext.state === 'suspended' || globalContext.state === 'interrupted')) {
                
                console.log("播放前恢复AudioContext");
                globalContext.resume().then(() => {
                    this.doPlay();
                }).catch(err => {
                    console.error("播放前恢复AudioContext失败:", err);
                    // 尝试强制恢复
                    this.forceResumeAudioContext();
                    setTimeout(() => this.doPlay(), 100);
                });
            } else {
                this.doPlay();
            }
        } else {
            this.doPlay();
        }
    }

    doPlay() {
        const audioId = cc.audioEngine.playEffect(this.audioClip, false);
        console.log("audioId play:", audioId);
        if (audioId) {
            cc.audioEngine.setVolume(audioId, 1);
            cc.audioEngine.setEffectsVolume(1);
            cc.audioEngine.setFinishCallback(audioId, () => {
                console.log("audio play finish");
            });
        } else {
            console.error("音频播放失败，无效的audioId");
        }
    }

    onResume() {
        const globalContext = cc.sys.__audioSupport.context;
        if (!globalContext) {
            console.warn("找不到全局AudioContext");
            return;
        }
        
        console.log("当前AudioContext状态:", globalContext.state);
        
        if (globalContext.state === 'suspended' || globalContext.state === 'interrupted') {
            console.log("恢复全局AudioContext");
            
            // 尝试恢复全局AudioContext
            globalContext.resume().then(() => {
                console.log("全局AudioContext恢复成功");
                
                // 强制"唤醒"音频系统
                this.forceResumeAudioContext();
                
                // 恢复正在播放的音频
                this.resumePlayingAudio();
            }).catch(err => {
                console.error("恢复AudioContext失败:", err);
                
                // 尝试使用更激进的方式恢复
                this.forceResumeAudioContext();
            });
        } else {
            console.log("AudioContext状态已正常:", globalContext.state);
            
            // 即使状态看起来正常，也进行一次音频恢复
            // 有时iOS会报告状态正常但实际上还是无法播放
            this.resumePlayingAudio();
        }
    }
    
    forceResumeAudioContext() {
        try {
            const globalContext = cc.sys.__audioSupport.context;
            if (!globalContext) return;
            
            // 创建一个短暂的空音频来"唤醒"系统
            const testOsc = globalContext.createOscillator();
            const testGain = globalContext.createGain();
            testGain.gain.value = 0.01; // 极小音量但不是0
            testOsc.connect(testGain);
            testGain.connect(globalContext.destination);
            testOsc.start(0);
            setTimeout(() => {
                try {
                    testOsc.stop();
                    testOsc.disconnect();
                    testGain.disconnect();
                } catch (e) {}
            }, 100); // 短暂播放100ms
            
            console.log("强制唤醒AudioContext完成");
        } catch (e) {
            console.error("强制唤醒AudioContext失败:", e);
        }
    }
    
    resumePlayingAudio() {
        // 遍历所有音频并检查它们的状态
        const audioIds = Object.keys(cc.audioEngine._id2audio);
        console.log("恢复音频状态检查, 当前音频数:", audioIds.length);
        
        if (audioIds.length === 0) return;
        
        // 恢复所有正在播放的音频
        for (let id of audioIds) {
            const audio = cc.audioEngine._id2audio[id];
            if (!audio || !audio._element) continue;
            
            const audioState = audio._state;
            console.log(`音频ID: ${id}, 状态: ${audioState}`);
            
            if (audioState === cc.audioEngine.AudioState.PLAYING && 
                (audio._element.paused || 
                (audio._element._currentSource === null && audio._element._context))) {
                console.log(`恢复播放音频: ${id}`);
                
                try {
                    // 先确保音量正确
                    const volume = audio.getVolume();
                    audio.setVolume(volume);
                    
                    // 然后恢复播放
                    audio.resume();
                } catch (e) {
                    console.error(`恢复音频${id}失败:`, e);
                }
            }
        }
    }
}