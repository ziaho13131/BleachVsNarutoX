/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.event.SetBtnEvent;
	
	/**
	 * 出招表界面
	 */
	public class MoveListSp extends Sprite {
		
		[Embed(source="/../res/movelist.jpg")]
		private var _picClass:Class;
		private var _pic:Bitmap;
		private var _btns:SetBtnGroup;
		
		public var onBackSelect:Function;
		
		public function MoveListSp() {
			_pic = new _picClass();
			
			_pic.width = GameConfig.GAME_SIZE.x;
			_pic.height = GameConfig.GAME_SIZE.y;
			
			addChild(_pic);
			
			_btns = new SetBtnGroup();
			_btns.setBtnData([{
				label: "BACK",
				cn   : "返回"
			}]);
			
			_btns.addEventListener(SetBtnEvent.SELECT, onSelect);
			_btns.x = 250;
			_btns.y = GameConfig.GAME_SIZE.y - 130;
			
			addChild(_btns);
		}
		
		public function destory():void {
			if (_btns) {
				_btns.removeEventListener(SetBtnEvent.SELECT, onSelect);
				_btns.destory();
				_btns = null;
			}
		}
		
		public function show():void {
			visible = true;
			
			setTimeout(function ():void {
				_btns.keyEnable = true;
			}, 100);
		}
		
		public function hide():void {
			_btns.keyEnable = false;
			visible = false;
		}
		
		private function onSelect(e:Event):void {
			if (onBackSelect != null) {
				onBackSelect();
			}
		}
	}
}
