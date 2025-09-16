const { ccclass, property } = cc._decorator;
@ccclass
export default class AudioManager extends cc.Component {

    @property(cc.Button)
    playButton: cc.Button = null;

    @property(cc.AudioClip)
    audioClip: cc.AudioClip = null;

    private isAudioSystemReset: boolean = true;

    // 保存后台前正在播放的音频信息
    private playingAudios: Map<number, {
        clip: cc.AudioClip,
        loop: boolean,
        volume: number,
        currentTime: number
    }> = new Map();

    onLoad() {
        if (cc.sys.isBrowser && cc.sys.os === cc.sys.OS_IOS) {
            cc.game.on(cc.game.EVENT_GAME_INITED, () => {
                cc.game.on(cc.game.EVENT_SHOW, this.handleGameShow, this);
                cc.game.on(cc.game.EVENT_HIDE, this.handleGameHide, this);
            });
        }

        // 设置按钮事件
        if (this.playButton) {
            this.playButton.node.on('click', this.onPlayButtonClick, this);
        }
    }

    handleGameShow() {
        console.log("应用恢复到前台");

        const state = cc.audioEngine.getState(this._testAudioId);
        console.log(`当前测试音频ID=${this._testAudioId}, 状态=${state}`);
        const audio = cc.audioEngine._id2audio[this._testAudioId];
        const content = cc.sys.__audioSupport.context;
        console.log(`show 当前AudioContext状态:`, content.state);
        console.log(`当前测试音频信息:`, audio);

        // return;

        // 标记音频系统需要重置
        this.isAudioSystemReset = false;
        this.scheduleOnce(() => {
            content.resume();
            // this.rebuildAudioSystem();

            // this.scheduleOnce(() => {
            //     const id = cc.audioEngine.playEffect(this.audioClip, false);
            //     cc.audioEngine.setCurrentTime(id, 2);
            //     cc.audioEngine.setFinishCallback(id, () => {
            //         console.log("音频重新播放完成，ID:", id);
            //     });
            // }, 0.4)

             // 核心修复逻辑
             if (content.state === "suspended") {
                console.log("尝试恢复 suspended 状态");

                // 1. 强制断开音频节点连接（防止残留状态）
                if (audio?._sourceNode) {
                    audio._sourceNode.disconnect();
                    console.log("已断开旧音频节点连接");
                }

                // 2. 重新创建音频源（关键步骤）
                const newSource = content.createBufferSource();
                console.log("创建新的音频源节点 newSource: ", newSource);
                console.log("设置音频源 buffer: ", audio._element._buffer);
                newSource.buffer = audio._element._buffer;
                console.log("设置音频源 _gainObj: ", audio._element._gainObj);
                newSource.connect(audio._element._gainObj);
                newSource.loop = audio._element._loop;
                audio._sourceNode = newSource;

                // 3. 恢复上下文并重启播放
                content.resume().then(() => {
                    console.log("AudioContext resumed，尝试重新播放");
                    // 4. 从上次位置开始播放
                    const currentTime = cc.audioEngine.getCurrentTime(this._testAudioId);
                    newSource.start(0, currentTime);
                }).catch(e => {
                    console.error("恢复失败:", e);
                });

            } else {
                // 正常恢复流程
                content.resume();
            }
        }, 0.1);
    }

    handleGameHide() {
        console.log("应用进入后台");
        const state = cc.audioEngine.getState(this._testAudioId);
        console.log(`当前测试音频ID=${this._testAudioId}, 状态=${state}`);

        // this.savePlayingAudios();


    }

    // // 保存正在播放的音频状态
    // savePlayingAudios() {
    //     // 清空旧的记录
    //     this.playingAudios.clear();

    //     // 获取所有音频ID
    //     //@ts-ignore
    //     const allAudioIds = Object.keys(cc.audioEngine._id2audio);
    //     console.log(`检查 ${allAudioIds.length} 个音频状态`);

    //     for (const idStr of allAudioIds) {
    //         const id = parseInt(idStr);
    //         try {
    //             // 检查是否在播放
    //             const state = cc.audioEngine.getState(id);
    //             console.log(`音频ID=${id}, 状态=${state}`);
    //             if (state === cc.audioEngine.AudioState.PLAYING) {
    //                 //@ts-ignore
    //                 const audio = cc.audioEngine._id2audio[id];
    //                 if (!audio) continue;

    //                 // 获取音频信息
    //                 const currentTime = cc.audioEngine.getCurrentTime(id);
    //                 const volume = cc.audioEngine.getVolume(id);
    //                 const loop = cc.audioEngine.isLoop(id);
    //                 const clip = audio._src;

    //                 // 保存信息
    //                 this.playingAudios.set(id, {
    //                     clip,
    //                     loop,
    //                     volume,
    //                     currentTime
    //                 });

    //                 console.log(`保存音频状态: ID=${id}, 时间=${currentTime.toFixed(2)}, 循环=${loop}`);
    //             }
    //         } catch (e) {
    //             console.error(`获取音频 ${id} 状态失败:`, e);
    //         }
    //     }

    //     console.log(`共保存了 ${this.playingAudios.size} 个正在播放的音频状态`);
    // }

    // // 恢复之前播放的音频
    // restorePausedAudios() {
    //     if (this.playingAudios.size === 0) {
    //         console.log("没有需要恢复的音频");
    //         return;
    //     }

    //     console.log(`准备恢复 ${this.playingAudios.size} 个音频`);

    //     // 逐个恢复
    //     const newAudioIds = new Map();
    //     //@ts-ignore
    //     for (const [oldId, info] of this.playingAudios.entries()) {
    //         try {
    //             if (!info.clip) {
    //                 console.log(`音频 ${oldId} 没有可用的clip，跳过`);
    //                 continue;
    //             }

    //             console.log(`恢复音频: 原ID=${oldId}, 时间=${info.currentTime.toFixed(2)}`);

    //             // 重新播放
    //             const newId = cc.audioEngine.playEffect(info.clip, info.loop);
    //             cc.audioEngine.setVolume(newId, info.volume);

    //             // 记录新旧ID映射
    //             newAudioIds.set(oldId, newId);

    //             // 设置播放位置
    //             if (info.currentTime > 0) {
    //                 setTimeout(() => {
    //                     try {
    //                         cc.audioEngine.setCurrentTime(newId, info.currentTime);
    //                         console.log(`设置音频 ${newId} 的播放位置: ${info.currentTime.toFixed(2)}`);
    //                     } catch (e) {
    //                         console.error(`设置音频 ${newId} 播放位置失败:`, e);
    //                     }
    //                 }, 100);
    //             }
    //         } catch (e) {
    //             console.error(`恢复音频 ${oldId} 失败:`, e);
    //         }
    //     }

    //     console.log(`成功恢复了 ${newAudioIds.size} 个音频`);

    //     // 清空保存的状态
    //     this.playingAudios.clear();
    // }

    rebuildAudioSystem() {
        console.log("开始重建音频系统");

        try {
            // 1. 获取当前 AudioContext
            //@ts-ignore
            const oldContext = cc.sys.__audioSupport.context;

            if (oldContext) {
                console.log("当前 AudioContext 状态:", oldContext.state);

                // 2. 关闭旧的 AudioContext
                try {
                    if (oldContext.close) {
                        oldContext.close();
                        console.log("已关闭旧 AudioContext");
                    }
                } catch (e) {
                    console.error("关闭旧 AudioContext 失败:", e);
                }
            }

            // 3. 创建新的 AudioContext
            console.log("创建新的 AudioContext");
            const AudioContextClass = window.AudioContext;
            if (AudioContextClass) {
                //@ts-ignore
                cc.sys.__audioSupport.context = new AudioContext();
                //@ts-ignore
                console.log("新 AudioContext 创建成功，状态:", cc.sys.__audioSupport.context.state);

                // 标记系统已重置
                this.isAudioSystemReset = true;

                console.log("音频系统重建完成，下次播放应该正常");
            }
        } catch (e) {
            console.error("重建音频系统失败:", e);
        }
    }

    onPlayButtonClick() {
        console.log("播放按钮点击");

        // 检查音频系统是否需要重置
        this.playAudio();
    }
    private _testAudioId = -1;
    playAudio() {
        try {
            const audioId = cc.audioEngine.playEffect(this.audioClip, false);
            console.log("音频开始播放，ID:", audioId);

            if (audioId) {
                cc.audioEngine.setFinishCallback(audioId, () => {
                    console.log("音频播放完成，ID:", audioId);
                    this._testAudioId = -1;
                });
                const duration = cc.audioEngine.getDuration(audioId);
                console.log(`音频ID=${audioId}，时长=${duration}`);
                this._testAudioId = audioId;
                // 设置检查播放状态的定时器
                this.scheduleOnce(() => {
                    try {
                        const state = cc.audioEngine.getState(audioId);
                        console.log(`音频${audioId}状态:`, state);

                        if (state !== cc.audioEngine.AudioState.PLAYING) {
                            console.warn("音频可能没有正常播放");
                        }
                    } catch (e) {
                        console.error("检查音频状态失败:", e);
                    }
                }, 0.2);
            } else {
                console.error("音频播放失败，无效的audioId");
            }
        } catch (e) {
            console.error("播放音频出错:", e);

            // 如果播放失败，尝试完全重建系统
            if (cc.sys.os === cc.sys.OS_IOS) {
                console.log("播放失败，尝试重建系统");
                this.rebuildAudioSystem();
            }
        }
    }

    onResume() {
        console.log("手动恢复按钮点击");
        // this.rebuildAudioSystem();

        const context = cc.sys.__audioSupport.context;
        const audio = cc.audioEngine._id2audio[this._testAudioId];
        if (context == audio._element._context) {
            console.log("当前音频上下文与全局一致，尝试恢复");
        }
        console.log("当前AudioContext状态:", context.state);
        if (audio._element._context.state === "interrupted") {

            console.log("音频系统中断，尝试恢复");
            audio._element._context.resume();
        }
        context.resume();


    }

    onReplay() {


        const id = cc.audioEngine.playEffect(this.audioClip, false);
        const onFinish = () => {
            console.log("音频播放完成，ID:", id);
        }
        cc.audioEngine.setFinishCallback(id, onFinish);
        cc.audioEngine.setCurrentTime(id, 2);
        // cc.audioEngine.setFinishCallback(id, onFinish);


        // this.scheduleOnce(() => {
        //     cc.audioEngine.setFinishCallback(id, () => {
        //         console.log("音频重新播放完成，ID:", id);
        //         this._testAudioId = -1;
        //     });
        // }, 0.2)
    }

    onDestroy() {
        cc.game.off(cc.game.EVENT_SHOW, this.handleGameShow, this);
        cc.game.off(cc.game.EVENT_HIDE, this.handleGameHide, this);
    }
}