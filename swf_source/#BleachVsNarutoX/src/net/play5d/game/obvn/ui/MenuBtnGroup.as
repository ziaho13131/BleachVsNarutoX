/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.data.MessionModel;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.interfaces.GameInterface;
	
	/**
	 * 主菜单按钮组类
	 */
	public class MenuBtnGroup extends Sprite {
		
		public var enabled:Boolean = true;			// 是否启用
		
		protected var _btnConfig:Array;
		protected var _xadd:Number = -40;
		protected var _yadd:Number = 5;
		
		private var _btnIndex:int;
		private var _startPoint:Point;
		private var _btnHeight:Number = 0;
		private var _btns:Array = [];
		private var _showIngChildrenBtn:MenuBtn;
		
		public function destory():void {
			GameRender.remove(render);
			
			for each(var b:MenuBtn in _btns) {
				b.removeEventListener(MouseEvent.CLICK, mouseHandler);
				b.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				
				b.dispose();
			}
			
			_btns = null;
		}
		
		public function fadIn(duration:Number = 0.5, itemDelay:Number = 0.05):void {
			for (var i:int = 0;i < _btns.length; i++) {
				var b:MenuBtn = _btns[i];
				
				b.ui.scaleX = 0.01;
				TweenLite.to(b.ui, duration, {
					scaleX: 1,
					delay : i * itemDelay,
					ease  : Back.easeOut
				});
			}
		}
		
		public function build():void {
			_startPoint = new Point(x, y);
			
			_btnConfig = GameInterface.instance.getGameMenu();
			if (!_btnConfig) {
				_btnConfig = GameInterface.getDefaultMenu();
			}
			
			for (var i:int = 0;i < _btnConfig.length; i++) {
				var o:Object = _btnConfig[i];
				addMenuBtn(o);
			}
			
			setBtns(true, false);
			hoverBtn(_btns[0]);

			GameRender.add(render);
		}
		
		private function addMenuBtn(o:Object, isChild:Boolean = false):MenuBtn {
			var b:MenuBtn = new MenuBtn(o.txt, o.cn, o.func);
			b.addEventListener(MouseEvent.CLICK, mouseHandler);
			b.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			
			if (!isChild) {
				b.index = _btns.length;
				_btns.push(b);
				
				if (_btnHeight == 0) {
					_btnHeight = b.height;
				}
			}
			var children:Array = o.children as Array;
			if (children) {
				b.children = [];
				for (var j:int = 0; j < children.length; j++) {
					var o2:Object = children[j];
					var cb:MenuBtn = addMenuBtn(o2, true);
					
					b.children.push(cb);
					cb.childMode();
					cb.index = j;
				}
			}
			
			return b;
		}
		
		protected function mouseHandler(type:String, target:MenuBtn):void {
			if (!enabled) {
				return;
			}
			
			switch (type) {
				case MouseEvent.MOUSE_OVER:
					hoverBtn(target);
					break;
				case MouseEvent.CLICK:
					selectBtn(target);
			}
		}
		
		protected function touchHandler(type:String, target:MenuBtn):void {
			if (target.children && target.children.length > 0) {
				hoverBtn(target);
				selectBtn(target);
				
				return;
			}
			if (!target.isHover()) {
				hoverBtn(target);
				
				return;
			}
			
			selectBtn(target);
		}
		
		private function moveScroll():void {
			if (!_startPoint || _btns.length < 7) {
				return;
			}
			
			var H:Number = GameConfig.GAME_SIZE.y - 10;
			var H2:Number = _startPoint.y + height;
			if (H2 < H) {
				return;
			}
			
			var H3:Number = H - _startPoint.y;
			var step:Number = H3 / _btns.length;
			var itemHeight:Number = _btnHeight + _yadd;
			var offsetY:Number = _btnIndex * (step - itemHeight) + _startPoint.y;
			
			TweenLite.to(this, 0.2, {
				y: offsetY
			});
		}
		
		private function hoverBtn(btn:MenuBtn):void {
			for (var i:int = 0; i < _btns.length; i++) {
				var b:MenuBtn = _btns[i];
				if (b == btn) {
					b.hover();
					_btnIndex = i;
					moveScroll();
				}
				else {
					b.normal();
				}
			}
			
			if (_showIngChildrenBtn) {
				var children:Array = _showIngChildrenBtn.children;
				
				for (var j:int = 0; j < children.length; j++) {
					b = children[j];
					if (b == btn) {
						b.hover();
						_btnIndex = j;
					}
					else {
						b.normal();
					}
				}
			}
		}
		
		protected function selectBtn(target:MenuBtn):void {
			var func:Function;
			
			if (target.children) {
				toogleChildren(target);
				return;
			}
			
			if (target.func) {
				func = target.func;
			}
			else {
				func = getFucByLabel(target.label);
			}
			
			enabled = false;
			target.select(function ():void {
				if (func != null) {
					func();
				}
				
				this.mouseChildren = true;
				this.mouseEnabled = true;
				enabled = true;
			});
		}
		
		private function getFucByLabel(label:String):Function {
			var func:Function;
			switch (label) {
				case "TEAM ACRADE":
					func = function ():void {
						GameMode.currentMode = GameMode.TEAM_ACRADE;
						MessionModel.I.reset();
						if (GameConfig.SHOW_HOW_TO_PLAY) {
							MainGame.I.goHowToPlay();
						}
						else {
							MainGame.I.goSelect();
						}
					};
					break;
				case "TEAM VS PEOPLE":
					func = function ():void {
						GameMode.currentMode = GameMode.TEAM_VS_PEOPLE;
						MainGame.I.goSelect();
					};
					break;
				case "TEAM VS CPU":
					func = function ():void {
						GameMode.currentMode = GameMode.TEAM_VS_CPU;
						MainGame.I.goSelect();
					};
					break;
				case "TEAM WATCH":
					func = function ():void {
						GameMode.currentMode = GameMode.TEAM_WATCH;
						MainGame.I.goSelect();
					};
					break;
				case "SINGLE ACRADE":
					func = function ():void {
						GameMode.currentMode = GameMode.SINGLE_ACRADE;
						MessionModel.I.reset();
						if (GameConfig.SHOW_HOW_TO_PLAY) {
							MainGame.I.goHowToPlay();
						}
						else {
							MainGame.I.goSelect();
						}
					};
					break;
				case "SINGLE VS PEOPLE":
					func = function ():void {
						GameMode.currentMode = GameMode.SINGLE_VS_PEOPLE;
						MainGame.I.goSelect();
					};
					break;
				case "SINGLE VS CPU":
					func = function ():void {
						GameMode.currentMode = GameMode.SINGLE_VS_CPU;
						MainGame.I.goSelect();
					};
					break;
				case "SINGLE WATCH":
					func = function ():void {
						GameMode.currentMode = GameMode.SINGLE_WATCH;
						MainGame.I.goSelect();
					};
					break;
//				case "SURVIVOR":
//					func = function ():void {
//						GameMode.currentMode = 30;
//						MessionModel.I.reset();
//						MainGame.I.goSelect();
//					};
//					break;
				case "OPTION":
					func = function ():void {
						MainGame.I.goOption();
					};
					break;
				case "TRAINING":
					func = function ():void {
						GameMode.currentMode = GameMode.TRAINING;
						MainGame.I.goSelect();
					};
					break;
				case "CREDITS":
					func = function ():void {
						MainGame.I.goCredits();
					};
					break;
				case "MORE GAMES":
//					func = function ():void {
//						MainGame.moreGames();
//					};
			}
			
			return func;
		}
		
		private function toogleChildren(btn:MenuBtn):void {
			if (_showIngChildrenBtn) {
				var isSame:Boolean = btn == _showIngChildrenBtn;
				
				if (!isSame) {
					_showIngChildrenBtn.normal();
				}
				
				closeChildren(isSame, isSame);
				if (isSame) {
					return;
				}
			}
			
			_showIngChildrenBtn = btn;
			setBtns(true, true);
			btn.openChild();
			hoverBtn(btn.children[0]);
		}
		
		private function closeChildren(isSetBtns:Boolean, tween:Boolean):void {
			var children:Array = _showIngChildrenBtn.children;
			
			for (var i:int = 0; i < children.length; i++) {
				var b:MenuBtn = children[i];
				
				try {
					removeChild(b.ui);
				}
				catch (e:Error) {
				}
			}
			
			_showIngChildrenBtn.closeChild();
			_showIngChildrenBtn = null;
			if (isSetBtns) {
				setBtns(false, tween);
			}
		}
		
		private function setBtns(_addChild:Boolean, _tween:Boolean = false):void {
			var lx:Number = 0;
			var ly:Number = 0;
			for (var i:int = 0; i < _btns.length; i++) {
				var b:MenuBtn = _btns[i];
				
				if (_tween) {
					TweenLite.to(b.ui, 0.2, {
						x: lx,
						y: ly
					});
				}
				else {
					b.ui.x = lx;
					b.ui.y = ly;
				}
				
				lx += _xadd;
				ly += b.height + _yadd;
				
				if (_addChild) {
					addChild(b.ui);
				}
				
				if (_showIngChildrenBtn == b) {
					for (var j:int = 0; j < b.children.length; j++) {
						var cb:MenuBtn = b.children[j];
						
						cb.ui.x = lx;
						cb.ui.y = ly;
						
						if (_tween) {
							cb.ui.scaleX = 0.01;
							TweenLite.to(cb.ui, 0.2, {
								scaleX: 1,
								delay : j * 0.04,
								ease  : Back.easeOut
							});
						}
						
						if (_addChild) {
							addChild(cb.ui);
						}
						
						lx += _xadd;
						ly += cb.height + _yadd;
					}
				}
			}
		}
		
		private function render():void {
			if (!enabled) {
				return;
			}
			if (GameUI.showingDialog()) {
				return;
			}
			
			var btns:Array = _showIngChildrenBtn ? _showIngChildrenBtn.children : _btns;
			if (GameInputer.up(GameInputType.MENU, 1)) {
				_btnIndex--;
				
				if (_btnIndex < 0) {
					_btnIndex = btns.length - 1;
				}
				
				hoverBtn(btns[_btnIndex]);
			}
			
			if (GameInputer.down(GameInputType.MENU, 1)) {
				_btnIndex++;
				
				if (_btnIndex > btns.length - 1) {
					_btnIndex = 0;
				}
				
				hoverBtn(btns[_btnIndex]);
			}
			
			if (GameInputer.select(GameInputType.MENU, 1)) {
				selectBtn(btns[_btnIndex]);
			}
			if (GameInputer.back(1)) {
				if (_showIngChildrenBtn) {
					_btnIndex = _showIngChildrenBtn.index;
					closeChildren(true, true);
				}
			}
		}
	}
}
