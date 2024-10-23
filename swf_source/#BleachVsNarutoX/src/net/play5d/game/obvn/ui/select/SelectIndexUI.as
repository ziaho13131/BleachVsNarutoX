/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.select {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.data.GameMode;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.utils.ResUtils;
	
	/**
	 * 选择次序UI类
	 */
	public class SelectIndexUI extends Sprite {
		
		public static var SHOW_MODE:int = 0;
		
		public var onFinish:Function;
		
		private var _p1Group:SelectIndexUIGroup;
		private var _p2Group:SelectIndexUIGroup;
		
		public function SelectIndexUI() {
			buildItems();
			initSelect();
		}
		
		public function getP1Order():Array {
			return _p1Group.getOrder();
		}
		
		public function getP2Order():Array {
			return _p2Group.getOrder();
		}
		
//		public function setP1Order(v:Array):void {
//			_p1Group.setOrder(v);
//		}
//
//		public function setP2Order(v:Array):void {
//			_p2Group.setOrder(v);
//		}
//
//		public function p1Finish():Boolean {
//			return _p1Group.isFinish;
//		}
//
//		public function p2Finish():Boolean {
//			return _p2Group.isFinish;
//		}
		
		public function isFinish():Boolean {
			return _p1Group.isFinish && _p2Group.isFinish;
		}
		
		public function destory():void {
			if (_p1Group) {
				_p1Group.destory();
				_p1Group = null;
			}
			if (_p2Group) {
				_p2Group.destory();
				_p2Group = null;
			}
			
			onFinish = null;
		}
		
		private function buildItems():void {
			_p1Group = new SelectIndexUIGroup();
			_p2Group = new SelectIndexUIGroup();
			
			if (SHOW_MODE == 1) {
				_p1Group.x = 35;
				_p2Group.x = 515;
				_p1Group.setFighterScale(0.85);
				_p2Group.setFighterScale(0.85);
				_p1Group.fighterOffset.x = -5;
				_p2Group.fighterOffset.x = 40;
				_p1Group.fzx = -5;
				_p2Group.fzx = 0;
			}
			else {
				_p1Group.x = 70;
				_p2Group.x = 480;
				_p1Group.fzx = -30;
				_p2Group.fzx = 45;
			}
			
			_p1Group.y = 85;
			_p2Group.y = 85;
			
			var p1class:Class = ResUtils.I.getItemClass(ResUtils.I.select, "selected_item_p1_mc");
			var p2class:Class = ResUtils.I.getItemClass(ResUtils.I.select, "selected_item_p2_mc");
			_p1Group.build(p1class, GameData.I.p1Select);
			_p2Group.build(p2class, GameData.I.p2Select);
			
			addChild(_p1Group);
			addChild(_p2Group);
		}
		
		private function initSelect():void {
			switch (GameMode.currentMode) {
				case GameMode.TEAM_ACRADE:
					initP1Group();
					initP2Group(null, true);
					break;
				case GameMode.TEAM_VS_PEOPLE:
					initP1Group();
					initP2Group(GameInputType.P2, false);
					break;
				case GameMode.TEAM_VS_CPU:
				case GameMode.TEAM_WATCH:
					initP1Group(function ():void {
						initP2Group(GameInputType.P1, false);
					});
					break;
				default:
					_p1Group.isFinish = true;
					_p2Group.isFinish = true;
			}
		}
		
		private function initP1Group(finishBack:Function = null):void {
			var arrow:DisplayObject = ResUtils.I.createDisplayObject(ResUtils.I.select, "select_arrow_mc_1");
			
			_p1Group.initArrow(arrow, new Point(-10, 30));
			_p1Group.setKey(GameInputType.P1);
			
			if (finishBack != null) {
				_p1Group.onFinish = function ():void {
					finishBack();
					finishBack = null;
					onSelectFinish();
				};
				
				return;
			}
			
			_p1Group.onFinish = onSelectFinish;
		}
		
		private function initP2Group(type:String, autoSelect:Boolean):void {
			var arrow:DisplayObject = ResUtils.I.createDisplayObject(ResUtils.I.select, "select_arrow_mc_2");
			
			_p2Group.initArrow(arrow, new Point(260, 30));
			if (autoSelect) {
				_p2Group.autoSelect();
			}
			else {
				_p2Group.setKey(type);
			}
			
			_p2Group.onFinish = onSelectFinish;
		}
		
		private function onSelectFinish():void {
			if (_p1Group.isFinish && _p2Group.isFinish) {
				if (onFinish != null) {
					setTimeout(function ():void {
						if (onFinish == null) {
							return;
						}
						
						onFinish();
						onFinish = null;
					}, 1000);
				}
			}
		}
	}
}
