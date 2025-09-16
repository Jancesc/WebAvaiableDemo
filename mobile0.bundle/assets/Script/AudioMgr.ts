// /**
//  * iOS 音频恢复管理器
//  * 处理 iOS 系统中应用切换后台后音频无法恢复的问题
//  */


// const { ccclass, property } =  cc._decorator;

// // 定义音频上下文管理器接口
// interface IAudioContextManager {
//     context: AudioContext;
//     isRunning: boolean;
//     isIOS: boolean;
//     checkContextState: () => void;
//     resumeContext: () => Promise<boolean>;
// }

// @ccclass('AudioMgr')
// export class AudioManager extends cc.Component {
//     // 可配置属性
//     @property({
//         type: Boolean,
//         tooltip: '是否自动恢复音频'
//     })
//     autoResume: boolean = true;

//     @property({
//         type: Boolean,
//         tooltip: '是否开启调试模式'
//     })
//     debug: boolean = false;

//     // 私有成员变量
//     private _originalAudioContext: AudioContext = null;
//     private _audioContextManager: IAudioContextManager = null;
//     private _visibilityChangeHandler: () => void = null;
//     private _focusHandler: () => void = null;

//     onLoad() {
//         // 保存原始的音频上下文
//         this._originalAudioContext = cc.audioEngine['_audioContext'];
        
//         // 创建一个新的音频上下文用于管理
//         this._audioContextManager = this._createAudioContextManager();
        
//         // 注册应用状态监听
//         this._registerAppStateListeners();
        
//         // 替换 Cocos 内置的音频上下文获取方法
//         // this._hookAudioContextGetter();
        
//         // 调试信息
//         if (this.debug) {
//             console.log('[AudioManager] 已初始化，正在监听 iOS 音频状态');
//         }
//     }
    
//     private _createAudioContextManager(): IAudioContextManager {
//         // 创建一个简单的音频上下文管理器
//         return {
//             context: cc.audioEngine['_audioContext'],
//             isRunning: true,
//             isIOS: this._checkIsIOS(),
//             checkContextState: () => {
//                 if (!this._audioContextManager.isIOS) return;
                
//                 const context = this._audioContextManager.context;
//                 if (context && context.state === 'suspended') {
//                     this._audioContextManager.isRunning = false;
//                     if (this.debug) {
//                         console.log('[AudioManager] 检测到音频上下文已挂起');
//                     }
//                 } else if (context && context.state === 'running') {
//                     this._audioContextManager.isRunning = true;
//                     if (this.debug) {
//                         console.log('[AudioManager] 音频上下文正在运行');
//                     }
//                 }
//             },
//             resumeContext: async () => {
//                 if (!this._audioContextManager.isIOS) return true;
                
//                 const context = this._audioContextManager.context;
//                 if (context && context.state !== 'running') {
//                     try {
//                         await context.resume();
//                         this._audioContextManager.isRunning = true;
//                         if (this.debug) {
//                             console.log('[AudioManager] 音频上下文已成功恢复');
//                         }
//                         return true;
//                     } catch (error) {
//                         if (this.debug) {
//                             console.error('[AudioManager] 恢复音频上下文失败:', error);
//                         }
//                         return false;
//                     }
//                 }
//                 return true;
//             }
//         };
//     }
    
//     private _checkIsIOS(): boolean {
//         // 检测是否为 iOS 设备
//         return cc.sys.isBrowser && cc.sys.os === cc.sys.OS_IOS;
//     }
    
//     private _registerAppStateListeners() {
//         // 监听应用状态变化
//         this._visibilityChangeHandler = () => {
//             if (this.debug) {
//                 console.log('[AudioManager] 应用可见性变化:', document.visibilityState);
//             }
            
//             if (document.visibilityState === 'visible' && this.autoResume) {
//                 // 应用回到前台时尝试恢复音频上下文
//                 this._audioContextManager.checkContextState();
//                 if (!this._audioContextManager.isRunning) {
//                     this._audioContextManager.resumeContext();
//                 }
//             }
//         };
        
//         // 监听页面焦点变化
//         this._focusHandler = () => {
//             if (this.debug) {
//                 console.log('[AudioManager] 页面获得焦点');
//             }
            
//             if (this.autoResume) {
//                 this._audioContextManager.checkContextState();
//                 if (!this._audioContextManager.isRunning) {
//                     this._audioContextManager.resumeContext();
//                 }
//             }
//         };
        
//         document.addEventListener('visibilitychange', this._visibilityChangeHandler);
//         window.addEventListener('focus', this._focusHandler);
//     }
    
//     // private _hookAudioContextGetter() {
//     //     // 替换 Cocos Creator 的音频上下文获取方法
//     //     // 注意：这是一个 hack 方法，可能需要根据 Cocos Creator 版本调整
//     //     const originalGetAudioContext = cc.audioEngine._getAudioContext;
        
//     //     cc.audioEngine._getAudioContext = function() {
//     //         // 检查上下文状态，如果被挂起则尝试恢复
//     //         if (this._audioContext && this._audioContext.state === 'suspended') {
//     //             this._audioContext.resume().catch(e => {
//     //                 console.warn('Failed to resume audio context:', e);
//     //             });
//     //         }
//     //         return originalGetAudioContext.call(this);
//     //     };
//     // }
    
//     // 提供一个公共方法，在用户交互时调用，确保音频上下文被激活
//     public ensureAudioContextRunning(): Promise<boolean> {
//         return this._audioContextManager.resumeContext();
//     }
    
//     onDestroy() {
//         // 清理监听
//         document.removeEventListener('visibilitychange', this._visibilityChangeHandler);
//         window.removeEventListener('focus', this._focusHandler);
        
//         // 恢复原始音频上下文
//         cc.audioEngine['_audioContext'] = this._originalAudioContext;
//     }
// }
