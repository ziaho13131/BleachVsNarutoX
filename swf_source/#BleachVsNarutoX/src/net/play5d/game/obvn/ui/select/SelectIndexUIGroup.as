/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.data.AssisterModel;
	import net.play5d.game.obvn.data.FighterModel;
	import net.play5d.game.obvn.data.SelectVO;
	import net.play5d.game.obvn.event.GameEvent;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.kyo.utils.KyoRandom;
	
	/**
	 * 选择次序UI组
	 */
	public class SelectIndexUIGroup extends Sprite {
		
		public var isFinish:Boolean;
		public var fzx:Number = 0;
		public var fzy:Number = 325;
		
		public var onFinish:Function;
		
		public var fighterOffset:Point = new Point();
		
		private var _fighters:Vector.<SelectedFighterUI>;
		private var _fighterScale:Number = 1;
		private var _arrowOffset:Point = new Point();
		private var _arrow:DisplayObject;
		private var _selectIndex:int;
		private var _selectItem:SelectedFighterUI;
		private var _inputType:String;
		private var _currentSelectId:int = 1;
		private var _gy:int = 100;
		private var _fuzhu:SelectedFighterUI;
		
		public function getOrder():Array {
			var a:Array = [];
			
			_fighters.sort(sortFighters);
			for (var i:int = 0; i < _fighters.length; i++) {
				a.push(_fighters[i].getFighter().id);
			}
			
			return a;
		}
		
		public function setFighterScale(v:Number):void {
			_fighterScale = v;
			
			for each(var i:SelectedFighterUI in _fighters) {
				i.ui.scaleX = i.ui.scaleY = v;
			}
		}
		
		public function setOrder(v:Array):void {
			for (var i:int = 0; i < _fighters.length; i++) {
				var index:int = v.indexOf(_fighters[i].getFighter().id);
				if (index != -1) {
					_fighters[i].setFighterIndex(index + 1);
				}
			}
			
			removeArrow();
			isFinish = true;
			updateOrder();
		}
		
		private function sortFighters(
			a:SelectedFighterUI, b:SelectedFighterUI):int 
		{
			var ai:int = a.getFighterIndex();
			var bi:int = b.getFighterIndex();
			if (ai == -1) {
				ai = 10;
			}
			if (bi == -1) {
				bi = 10;
			}
			
			if (ai > bi) {
				return 1;
			}
			if (ai < bi) {
				return -1;
			}
			
			return 0;
		}
		
		public function destory():void {
			removeArrow();
			
			if (_fighters) {
				for each(var i:SelectedFighterUI in _fighters) {
					i.removeEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
					i.removeEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
					
					i.destory();
				}
				
				_fighters = null;
			}
			if (_fuzhu) {
				_fuzhu.destory();
				_fuzhu = null;
			}
			
			_selectItem = null;
		}
		
		public function build(itemUIClass:Class, selectVO:SelectVO):void {
			var fs:Array = selectVO.getSelectFighters();
			
			_fighters = new Vector.<SelectedFighterUI>();
			var fui:SelectedFighterUI;
			for (var i:int = 0; i < fs.length; i++) {
				fui = new SelectedFighterUI(new itemUIClass());
				
				fui.setFighter(FighterModel.I.getFighter(fs[i]));
				fui.mouseEnabled(true);
				
				fui.addEventListener(MouseEvent.MOUSE_OVER, selectFighterMouseHandler);
				fui.addEventListener(MouseEvent.CLICK, selectFighterMouseHandler);
				
				fui.ui.x = fighterOffset.x;
				fui.ui.y = i * _gy + fighterOffset.y;
				fui.trueY = i * _gy;
				
				if (_fighterScale != 1) {
					fui.ui.scaleX = fui.ui.scaleY = _fighterScale;
				}
				
				_fighters.push(fui);
				addChild(fui.ui);
			}
			if (selectVO.fuzhu) {
				fui = new SelectedFighterUI(new itemUIClass());
					
				fui.setFighter(AssisterModel.I.getAssister(selectVO.fuzhu));
				fui.ui.x = fzx;
				fui.ui.y = fzy;
				fui.setAssister();
				
				addChild(fui.ui);
				_fuzhu = fui;
			}
		}
		
//		private function selectFighterTouchHandler(e:TouchEvent):void {
//			var target:SelectedFighterUI = e.currentTarget as SelectedFighterUI;
//			var index:int = _fighters.indexOf(target);
//			if (index == -1) {
//				return;
//			}
//			selectIndex(index);
//			doConfrim();
//		}
		
		private function selectFighterMouseHandler(e:MouseEvent):void {
			var target:SelectedFighterUI = e.currentTarget as SelectedFighterUI;
			var index:int = _fighters.indexOf(target);
			if (index == -1 || _arrow == null) {
				return;
			}
			
			switch (e.type) {
				case MouseEvent.MOUSE_OVER:
					selectIndex(index);
					
					SoundCtrl.I.sndSelect();
					break;
				case MouseEvent.CLICK:
					doConfrim();
			}
		}
		
		public function initArrow(arrowUI:DisplayObject, offset:Point):void {
			_arrowOffset = offset;
			_arrow = arrowUI;
			_arrow.x = offset.x;
			
			addChild(_arrow);
			selectIndex(0);
		}
		
		public function selectIndex(index:int, direct:int = 0):void {
			if (index < 0) {
				index = _fighters.length - 1;
			}
			if (index > _fighters.length - 1) {
				index = 0;
			}
			
			var item:SelectedFighterUI = _fighters[index];
			if (item.getFighterIndex() != -1) {
				if (direct != 0) {
					selectIndex(index + direct, direct);
				}
				
				return;
			}
			
			_selectIndex = index;
			_selectItem = _fighters[index];
			_arrow.y = _selectItem.trueY + _arrowOffset.y;
		}
		
		public function setKey(inputType:String):void {
			_inputType = inputType;
			
			GameRender.add(render);
			GameInputer.focus();
		}
		
		public function autoSelect():void {
			var a:Array = [];
			
			for each (var i:SelectedFighterUI in _fighters) {
				a.push(i);
			}
			
			KyoRandom.arraySortRandom(a);
			
			var n:int = 1;
			for each (i in a) {
				i.setFighterIndex(n);
				n++;
			}
			
			selectFinish();
		}
		
		private function removeArrow():void {
			if (_arrow) {
				try {
					removeChild(_arrow);
				}
				catch (e:Error) {
				}
				
				_arrow = null;
			}
			
			GameRender.remove(render);
		}
		
		private function render():void {
			if (GameUI.showingDialog()) {
				return;
			}
			
			if (GameInputer.up(_inputType, 1)) {
				selectIndex(_selectIndex - 1, -1);
				SoundCtrl.I.sndSelect();
			}
			if (GameInputer.down(_inputType, 1)) {
				selectIndex(_selectIndex + 1, 1);
				SoundCtrl.I.sndSelect();
			}
			if (GameInputer.select(_inputType, 1)) {
				doConfrim();
			}
		}
		
		private function doConfrim():void {
			if (!_selectItem) {
				return;
			}
			
			_selectItem.setFighterIndex(_currentSelectId);
			_currentSelectId++;
			
			if (_currentSelectId > _fighters.length - 1) {
				selectLast();
				selectFinish();
			}
			else {
				updateOrder();
				selectIndex(1, 1);
			}
			
			SoundCtrl.I.sndConfrim();
		}
		
		private function selectLast():void {
			for each(var i:SelectedFighterUI in _fighters) {
				if (i.getFighterIndex() == -1) {
					i.setFighterIndex(_currentSelectId);
					
					return;
				}
			}
		}
		
		private function selectFinish():void {
			removeArrow();
			isFinish = true;
			updateOrder();
			
			if (onFinish != null) {
				GameEvent.dispatchEvent(GameEvent.SELECT_FIGHTER_INDEX, getOrder());
				onFinish();
			}
		}
		
		private function updateOrder():void {
			_fighters.sort(sortFighters);
			
			for (var i:int = 0; i < _fighters.length; i++) {
				var ty:Number = i * _gy;
				
				_fighters[i].trueY = ty;
				var fui:DisplayObject = _fighters[i].ui;
				
				if (Math.abs(ty - fui.y) > 2) {
					TweenLite.to(fui, 0.2, {
						y: ty
					});
				}
			}
		}
	}
}
