/**
 * 这个文件是最终版本
 * 主要是为了测试音频恢复功能最终确认是否正常工作
 * 
 */

const { ccclass, property } = cc._decorator;
@ccclass
export default class AudioManager extends cc.Component {

    @property(cc.Button)
    playButton: cc.Button = null;

    @property(cc.AudioClip)
    audioClip: cc.AudioClip = null;

    @property(cc.Prefab)
    tipAudioUI: cc.Prefab = null;

    private _testAudioId: number = -1;

    // 保存正在播放的音频信息
    private playingAudios: Array<{
        id: number,
        clip: cc.AudioClip,
        loop: boolean,
        volume: number,
        currentTime: number,
        finishCallback?: (audioId: number) => void
    }> = new Array();

    onLoad() {
        if (cc.sys.isBrowser && cc.sys.os === cc.sys.OS_IOS) {
            cc.game.on(cc.game.EVENT_GAME_INITED, () => {
                cc.game.on(cc.game.EVENT_SHOW, this.handleGameShow, this);
                cc.game.on(cc.game.EVENT_HIDE, this.handleGameHide, this);
            });
        }
    }

    handleGameShow() {
        console.log("应用恢复到前台");

        if (cc.sys.os === cc.sys.OS_IOS && cc.sys.isBrowser && cc.sys.isMobile) {
            //@ts-ignore
            const content = cc.sys.__audioSupport.context;
            console.log(`当前音频上下文状态: ${content.state}`);
            if (content.state === "suspended") {
                //挂起状态，高版本ios系统, 需要重建 audioContent, 启用并关闭旧的
                this.savePlayingAudios();
                this.rebuildAudioSystem().then(() => {
                    //展示恢复音频界面，提示用户触摸屏幕恢复音频播放
                    this._showTipAudioUI();
                });
            }
            else if (content.state === "interrupted") {
                // 需要延迟一小会儿, 给系统初始化时间
                console.log("普通恢复");
                setTimeout(() => {
                    content.resume();
                },  50);
                
            }
        }
    }

    handleGameHide() {
        console.log("应用进入后台");
        if(this._testAudioId != -1) {
            const state = cc.audioEngine.getState(this._testAudioId);
            console.log(`当前测试音频ID=${this._testAudioId}, 状态=${state}`);
        }
    }

    savePlayingAudios() {
        this.playingAudios.length = 0; // 清空旧的记录
        //@ts-ignore
        const allAudioIds = Object.keys(cc.audioEngine._id2audio);
        console.log(`检查 ${allAudioIds.length} 个音频状态`);

        for (const idStr of allAudioIds) {
            const id = parseInt(idStr);
            const state = cc.audioEngine.getState(id);
            if (state === cc.audioEngine.AudioState.PLAYING) {
                //@ts-ignore
                const audio = cc.audioEngine._id2audio[id];
                // 获取音频信息
                this.playingAudios.push({
                    id: id,
                    clip: audio._src,
                    loop: audio._element._loop,
                    volume: audio._element._volume,
                    currentTime: audio._element.currentTime,
                    finishCallback: audio._finishCallback
                });
            }
        }
        for (const audioInfo of this.playingAudios) {
            console.log(`保存音频状态: ID=${audioInfo.id}, 时间=${audioInfo.currentTime}, 循环=${audioInfo.loop}, 音量=${audioInfo.volume}, 回调=${audioInfo.finishCallback ? '有' : '无'}`);
        }
    }

    // 恢复之前播放的音频
    restorePausedAudios() {
        if (this.playingAudios.length === 0) {
            console.log("没有需要恢复的音频");
            return;
        }

        console.log(`准备恢复 ${this.playingAudios.length} 个音频`);

        for (const audioInfo of this.playingAudios) {
            console.log(`恢复音频状态: ID=${audioInfo.id}, 时间=${audioInfo.currentTime}, 循环=${audioInfo.loop}, 音量=${audioInfo.volume}, 回调=${audioInfo.finishCallback ? '有' : '无'}`);
            if (!audioInfo.clip) {
                console.log(`音频没有可用的clip, 跳过`);
                continue;
            }
            // 重新播放
            const newId = cc.audioEngine.play(audioInfo.clip, audioInfo.loop, audioInfo.volume);
            if (audioInfo.currentTime > 0) {
                cc.audioEngine.setCurrentTime(newId, audioInfo.currentTime);
            }
            if (audioInfo.finishCallback) {
                cc.audioEngine.setFinishCallback(newId, audioInfo.finishCallback);
            }
        }
        
        this.playingAudios.length = 0;
    }

    async rebuildAudioSystem() {
        console.log("开始重建音频系统");
        return new Promise((resolve, reject) => {
            // 需要延迟一下
            setTimeout(() => {
                try {
                    //@ts-ignore
                    const oldContext = cc.sys.__audioSupport.context;
                    if (oldContext && oldContext.close) {
                        oldContext.close();
                        console.log("已关闭旧 AudioContext");
                    }
                    // 3. 创建新的 AudioContext
                    console.log("创建新的 AudioContext");
                    const AudioContextClass = window.AudioContext;
                    if (AudioContextClass) {
                        //@ts-ignore
                        const audioSupport = cc.sys.__audioSupport;
                        //以下摘自引擎源码的创建方式
                        if (audioSupport.WEB_AUDIO) {
                            //@ts-ignore
                            audioSupport.context = new (window.AudioContext || window.webkitAudioContext || window.mozAudioContext)();
                            if (audioSupport.DELAY_CREATE_CTX) {
                                //@ts-ignore
                                setTimeout(function () { audioSupport.context = new (window.AudioContext || window.webkitAudioContext || window.mozAudioContext)(); }, 0);
                            }
                        }
                        //@ts-ignore
                        console.log("新 AudioContext 创建成功，状态:", cc.sys.__audioSupport.context.state);
                    }
                    resolve(true);
                } catch (e) {
                    console.error("重建音频系统失败:", e);
                    reject(e);
                }
            }, 50);
        });
    }

    onPlayButtonClick() {
        console.log("播放按钮点击");

        const audioId = cc.audioEngine.playEffect(this.audioClip, false);
        cc.audioEngine.setFinishCallback(audioId, () => {
            console.log("音频播放完成，ID:", audioId);
        });
    }
    
    private _showTipAudioUI() {
        const scene = cc.director.getScene();
        const canvas = scene.getChildByName("Canvas");
        let tipAudioUI = cc.instantiate(this.tipAudioUI);
        tipAudioUI.parent = canvas;
        tipAudioUI.setPosition(0, 0);
        tipAudioUI.on(cc.Node.EventType.TOUCH_START, () => {
            this.restorePausedAudios();
            tipAudioUI.destroy();
        });
    }

    onResume() {
        console.log("手动恢复按钮点击");
        // this.rebuildAudioSystem();

        this.restorePausedAudios();
    }

    onReplay() {
        const id = cc.audioEngine.playEffect(this.audioClip, false);
        const onFinish = () => {
            console.log("音频播放完成，ID:", id);
        }
        cc.audioEngine.setFinishCallback(id, onFinish);
        cc.audioEngine.setCurrentTime(id, 2);
    }

    onDestroy() {
        cc.game.off(cc.game.EVENT_SHOW, this.handleGameShow, this);
        cc.game.off(cc.game.EVENT_HIDE, this.handleGameHide, this);
    }
}