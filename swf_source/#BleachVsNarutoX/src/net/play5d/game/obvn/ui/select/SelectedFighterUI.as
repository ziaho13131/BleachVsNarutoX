/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormatAlign;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.data.FighterVO;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.game.obvn.ui.UIUtils;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.BitmapText;
	
	/**
	 * 选择完成的角色UI
	 */
	public class SelectedFighterUI extends EventDispatcher {
		
		public var ui:Sprite;
		public var trueY:Number = 0;
		
		private var _fighterIndex:int = -1;
		private var _face:DisplayObject;
		private var _fighter:FighterVO;
		private var _text:BitmapText;
//		private var _uiWidth:Number;
		private var _selectedItemP1Class:Class = ResUtils.I.getItemClass(ResUtils.I.select, "selected_item_p1_mc");
		
		public function SelectedFighterUI(ui:Sprite) {
			this.ui = ui;
			ui.mouseChildren = false;
			
			if (GameUI.SHOW_CN_TEXT) {
				_text = new BitmapText(true, 0xFFFFFF, [new GlowFilter(0, 1, 3, 3, 3)]);
				
				var params:Object = {
					color: 0xFFFFFF,
					size : 14,
					align: TextFormatAlign.RIGHT
				};
				
				if (ui is _selectedItemP1Class) {
					_text.width = ui.width - 10;
				}
				else {
					params.align = TextFormatAlign.LEFT;
					
					_text.x = 10;
					_text.width = ui.width - 10;
				}
				
				UIUtils.formatText(_text.textfield, params);
				_text.y = ui.height - 25;
				
				ui.addChild(_text);
			}
		}
		
		public function mouseEnabled(v:Boolean):void {
			if (v) {
				ui.buttonMode = true;
				
				ui.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				ui.addEventListener(MouseEvent.CLICK, mouseHandler);
			}
			else {
				ui.buttonMode = false;
				
				ui.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				ui.removeEventListener(MouseEvent.CLICK, mouseHandler);
			}
		}
		
		private function mouseHandler(e:Event):void {
			dispatchEvent(e);
		}
		
		public function destory():void {
			if (ui) {
				ui.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
				ui.removeEventListener(MouseEvent.CLICK, mouseHandler);
			}
			
			if (_text) {
				_text.destory();
				_text = null;
			}
		}
		
		public function setFighter(vo:FighterVO):void {
			if (!vo) {
				return;
			}
			
			_fighter = vo;
			if (_text) {
				_text.text = vo.name;
			}
			
			var ct:Sprite = ui.getChildByName("ct") as Sprite;
			var ct2:Sprite = ct ? ct.getChildByName("ct") as Sprite : null;
			if(ct2) {
				if(_face) {
					try {
						ct2.removeChild(_face);
					}
					catch(e:Error) {
					}
				}
				
				var face:DisplayObject = AssetManager.I.getFighterFaceBig(vo);
				if(face) {
					_face = face;
					ct2.addChild(face);
				}
			}
		}
		
		public function getFighter():FighterVO {
			return _fighter;
		}
		
		public function getFighterIndex():int {
			return _fighterIndex;
		}
		
		public function setFighterIndex(index:int):void {
			_fighterIndex = index;
			
			var au:MovieClip = ResUtils.I.createDisplayObject(ResUtils.I.loading, "seltwzmc");
			au.gotoAndStop(index);
			ui.addChild(au);
			
			if (ui is _selectedItemP1Class) {
				au.x = -8;
			}
			else {
				au.x = 252 - au.width;
			}
			
			au.y = -5;
			mouseEnabled(false);
		}
		
		public function setAssister():void {
			var au:MovieClip = ResUtils.I.createDisplayObject(ResUtils.I.loading, "seltwzmc");
			au.gotoAndStop(4);
			ui.addChild(au);
			
			if (ui is _selectedItemP1Class) {
				au.x = -8;
			}
			else {
				au.x = 176;
			}
			au.y = -5;
		}
	}
}
