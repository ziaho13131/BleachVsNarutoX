/**
 * 已重建完成
 */
package net.play5d.game.obvn.stage {
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.interfaces.GameInterface;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.MenuBtnGroup;
	import net.play5d.game.obvn.ui.UIUtils;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 主菜单类
	 */
	public class MenuStage extends Sprite implements IStage {
		
		
		private var _ui:MovieClip;
		private var _btnGroup:MenuBtnGroup;
		private var _versionTxt:TextField;
		private var _destroyed:Boolean = false;
		private var _isBackTitleCd:Boolean = false;
		private var _isIngExitGame:Boolean = false;
		
	/**
	 * 获取菜单界面显示对象
	 */	
		public function get display():DisplayObject {
			return _ui;
		}
	
	/**
	 * 创建菜单界面
	 */
		public function build():void {
		
		// 游戏界面: 赋值 资源工具类创建显示对象(标题,标题)，跳帧并暂停播放(1)
			_ui = ResUtils.I.createDisplayObject(ResUtils.I.title, ResUtils.TITLE);
			_ui.gotoAndStop(1);
			
		// 游戏接口: 初始化界面UI(游戏菜单界面)
			GameInterface.instance.initTitleUI(_ui);
			GameInputer.enabled = false;
			
		// 音效接口: 播放BGM( 资源管理器: 获取音效(op) )
			SoundCtrl.I.BGM(AssetManager.I.getSound("op"));
		}
		
	/** 
	 * 创建后处理
	 */
		public function afterBuild():void {
			_ui.gotoAndPlay(2);
			
			setTimeout(function ():void {
				_ui.buttonMode = true;
				_ui.useHandCursor = true;
				_ui.addEventListener(MouseEvent.CLICK, showBtns);
				
				GameRender.add(render);
				GameInputer.focus();
				GameInputer.enabled = true;
			}, 500);
			
			_versionTxt = new TextField();
			UIUtils.formatText(_versionTxt, {
				color: 0x000000,
				size : 18
			});
			_versionTxt.text = MainGame.VERSION;
			_versionTxt.autoSize = TextFieldAutoSize.LEFT;
			_versionTxt.x = GameConfig.GAME_SIZE.x - _versionTxt.width - 15;
			_versionTxt.y = GameConfig.GAME_SIZE.y - _versionTxt.height - 10;
			
			_ui.addChild(_versionTxt);
			if (GameData.I.isFristRun && MainGame.UPDATE_INFO) {
				GameData.I.isFristRun = false;
				GameUI.alert("UPDATE", MainGame.UPDATE_INFO);
			}
		}
		
	/**
	 * 是否在退出游戏界面中
	 */
		public function get isIngExitGame():Boolean {
			return _isIngExitGame;
		}	
		
	/**
	 * 返回界面渲染器
	 */
		private function backRender():void {
			if (_destroyed) {
				GameRender.remove(backRender);
				return;
			}
			if (GameInputer.back()&&!_isBackTitleCd) {
				closeBtns();
			}
			
		}
	
	/**
	 * 主菜单总渲染器
	 */
		private function render():void {
			if (_destroyed) {
				GameRender.remove(render);
				return;
			}
			if (GameInputer.anyKey(1) && !GameInputer.back() && !_isIngExitGame) {
				showBtns();
				return;
			} else if(GameInputer.back() && _ui.currentLabel != "back" && !_isIngExitGame) {
				GameInputer.enabled = false;
				_isIngExitGame = true;
				GameUI.confirm("EXIT GAME?", "是否退出游戏？", function ():void {
					NativeApplication.nativeApplication.exit();
				}, function ():void {
					_isIngExitGame = false;
					GameInputer.enabled = true;
				});
			}
		}
		
	/**
	 * 展开菜单按钮列表
	 */
		private function showBtns(...params):void {
			
		// 删除鼠标侦听器: 展开菜单按钮列表	
			_ui.removeEventListener(MouseEvent.CLICK, showBtns);
			
		// 删除游戏渲染: 游戏菜单主渲染器
			GameRender.remove(render);
			
		// 添加游戏渲染: 收回菜单渲染器
			GameRender.add(backRender);
		
		// 游戏界面: 关闭按钮模式，关闭鼠标使用，跳转并播放帧标签(menu)
			_ui.buttonMode = false;
			_ui.useHandCursor = false;
			_ui.gotoAndPlay("menu");
			
		// 音效接口: 通过swc播放音效(snd_menu5)
			SoundCtrl.I.playSwcSound(snd_menu5);
			
		// 菜单按钮列表: 是否激活: 关闭，X轴赋值: 470，Y轴赋值: 100	
			_btnGroup = new MenuBtnGroup();
			_btnGroup.enabled = false;
			_btnGroup.x = 470;
			_btnGroup.y = 100;
			
		// 定义精灵赋值: 游戏界面: 通过名称获取容器(btnct) 并转换成精灵
			var ct:Sprite = _ui.getChildByName("btnct") as Sprite;
		
		// 如果精灵存在(转换成功) 则: ct增加容器(菜单列表) 否则: 游戏界面增加容器(菜单列表)
			if (ct) {
				ct.addChild(_btnGroup);
			}
			else {
				_ui.addChild(_btnGroup);
			}
			
		// 菜单按钮列表: 创建,并出现
			_btnGroup.build();
			_btnGroup.fadIn(0.2, 0.04);
			
		// 设置计时器: function()，400毫秒	
			setTimeout(function ():void {
				
			// 如果不存在菜单按钮列表 则返回
				if (!_btnGroup) {
					return;
			    }
			// 设置菜单按钮列表激活状态: 开启
				_btnGroup.enabled = true;
				
			// 设置返回菜单CD: 关闭	
				_isBackTitleCd = false;	
			}, 400);
		}
		
	/**
	 * 收回菜单按钮列表
	 */	
		private function closeBtns():void {
		// 游戏界面: 开启按钮模式，开启鼠标使用，跳转并播放帧标签(back)
			_ui.buttonMode = true;
			_ui.useHandCursor = true;
			_ui.gotoAndPlay("back");

		// 增加鼠标侦听器: 展开菜单按钮列表	
			_ui.addEventListener(MouseEvent.CLICK,showBtns);
			
		// 音效接口: 通过swc播放音效(snd_menu5)
			SoundCtrl.I.playSwcSound(snd_menu5);
			
		// 删除游戏渲染: 收回游戏菜单列表 
			GameRender.remove(backRender);
		
		// 销毁游戏菜单
			destory();
		
		// 设置是否销毁: 否 	
			_destroyed = false;
			
		// 游戏键盘接口: 设置激活状态: 开启，清除输入	
			GameInputer.enabled = true;
			GameInputer.clearInput();
			
		// 设置返回菜单CD: 开启	
			_isBackTitleCd = true;
		
		// 添加游戏渲染: 游戏菜单主渲染器
			GameRender.add(render);
		}
		
	/**
	 * 销毁菜单界面
	 */
		public function destory(back:Function = null):void {
			_destroyed = true;
			if (_btnGroup) {
				try {
					_btnGroup.parent.removeChild(_btnGroup);
				}
				catch (e:Error) {
				}
				
				_btnGroup.destory();
				_btnGroup = null;
			}
			
			GameInputer.enabled = false;
		}
	}
}
