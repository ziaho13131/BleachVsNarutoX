/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl.game_ctrler {
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.GameLogic;
	import net.play5d.game.obvn.data.TeamMap;
	import net.play5d.game.obvn.data.TeamVO;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.map.MapMain;
	import net.play5d.game.obvn.stage.GameStage;
	
	/**
	 * 游戏主要逻辑控制器
	 */
	public class GameMainLogicCtrler {
		
		public var renderHit:Boolean = true;
		
		private var _gameState:GameStage;
		
		private var _leftSide:Number = 0;
		private var _rightSide:Number = 0;
		
		private var _teamMap:TeamMap;
		
		private var _renderAnimate:Boolean;
		
		public function initlize(gameState:GameStage, teamMap:TeamMap, map:MapMain):void {
			_gameState = gameState;
			_teamMap = teamMap;
			_leftSide = map.left + 10;
			_rightSide = map.right - 10;
		}
		
		public function setSpeedPlus(v:Number):void {
			GameConfig.SPEED_PLUS = v;
			
			var l:int = _teamMap.teams.length;
			for (var i:int = 0; i < l; i++) {
				var team:TeamVO = _teamMap.teams[i] as TeamVO;
				
				var cl:int = team.children.length;
				for (var j:int = 0; j < cl; j++) {
					var sp:IGameSprite = team.children[j];
					if (sp && !sp.isDestoryed()) {
						sp.setSpeedRate(v);
					}
				}
			}
		}
		
		public function destory():void {}
		
		public function render():void {
			renderMainLogic();
		}
		
		private function renderMainLogic():void {
			var teams:Vector.<TeamVO> = _teamMap.teams;
			var displays:Vector.<IGameSprite> = _gameState.getGameSprites();
			if (!displays) {
				return;
			}
			
			var i:int = 0;
			for (i = 0; i < displays.length; i++) {
				renderGameSprite(displays[i]);
			}
			
			var team:TeamVO = teams[0] as TeamVO;
			var children:Vector.<IGameSprite> = team.children;
			
			var team2:TeamVO = teams[1] as TeamVO;
			var children2:Vector.<IGameSprite> = team2.children;
			
			for (i = 0; i < children.length; i++) {
				var sp:IGameSprite = children[i] as IGameSprite;
				if (sp == null || sp.isDestoryed()) {
					continue;
				}
				
				for (var j:int = 0; j < children2.length; j++) {
					var sp2:IGameSprite = children2[j] as IGameSprite;
					if (sp2 == null || sp2.isDestoryed()) {
						continue;
					}
					
					checkBodyHit(sp, sp2);
					if (_renderAnimate) {
						checkHit(sp, sp2);
					}
				}
			}
			_renderAnimate = false;
		}
		
		public function renderAnimate():void {
			_renderAnimate = true;
		}
		
		private function checkBodyHit(A:IGameSprite, B:IGameSprite):void {
			if (!renderHit) {
				return;
			}
			if (!(A is BaseGameSprite) || !(B is BaseGameSprite)) {
				return;
			}
			
			var ba:BaseGameSprite = A as BaseGameSprite;
			var bb:BaseGameSprite = B as BaseGameSprite;
			if (ba.isCross || bb.isCross) {
				return;
			}
			
			var bodyA:Rectangle = A.getBodyArea();
			var bodyB:Rectangle = B.getBodyArea();
			if (bodyA == null || bodyB == null) {
				return;
			}
			
			var bodyHit:Rectangle = bodyA.intersection(bodyB);
			if (!bodyHit || bodyHit.isEmpty()) {
				return;
			}
			var vecA:Number = ba.getVecX();
			var vecB:Number = bb.getVecX();
			
			var overVec:Object;
			if (ba.x < bb.x) {
				if (vecA < 0 && vecA < vecB || vecB > 0 && vecB > vecA) {
					return;
				}
				if (bodyHit.width > 2) {
					if (!overVec) {
						overVec = getVec(5 * GameConfig.SPEED_PLUS);
					}
					ba.move(-overVec.A);
					bb.move(overVec.B);
				}
			}
			else {
				if (vecA > 0 && vecA > vecB || vecB < 0 && vecB < vecA) {
					return;
				}
				if (bodyHit.width > 2) {
					if (!overVec) {
						overVec = getVec(5 * GameConfig.SPEED_PLUS);
					}
					ba.move(overVec.A);
					bb.move(-overVec.B);
				}
			}
			if (vecA != 0) {
				var vo:Object = getVec(vecA);
				bb.move(vo.B);
				ba.move(-vo.A);
			}
			if (vecB != 0) {
				var vo2:Object = getVec(vecB);
				ba.move(vo2.A);
				bb.move(-vo2.B);
			}
			
			function getVec(vec:Number):Object {
				var rate:Number = bb.heavy / ba.heavy / 2;
				if (rate > 0.9) {
					rate = 0.9;
				}
				if (rate < 0.1) {
					rate = 0.1;
				}
				var vecA:Number = vec * rate;
				var vecB:Number = vec * (1 - rate);
				
				if (A.getIsTouchSide() && B.getIsTouchSide()) {
					vecA = vec;
					vecB = vec;
				}
				else if (A.getIsTouchSide()) {
					vecA = 0;
					vecB = vec;
				}
				else if (B.getIsTouchSide()) {
					vecB = 0;
					vecA = vec;
				}
				
				
				return {
					A: vecA,
					B: vecB
				};
			}
		}
		
		private function renderGameSprite(sp:IGameSprite):void {
			try {
				GameLogic.fixGameSpritePosition(sp);
				if (sp is BaseGameSprite) {
					var bsp:BaseGameSprite = sp as BaseGameSprite;
					var inAir:Boolean = GameLogic.isInAir(bsp);
					if (inAir) {
						bsp.applayG(12);
					}
					bsp.setInAir(inAir);
				}
				
				sp.render();
				if (_renderAnimate && !sp.isDestoryed()) {
					sp.renderAnimate();
				}
			}
			catch (e:Error) {
				trace(sp);
				Debugger.log("GameMainLogicCtrler.renderGameSprite :: " + e);
			}
		}
		
		private function checkHit(A:IGameSprite, B:IGameSprite):void {
			if (!renderHit) {
				return;
			}
			var hitsA:Array = A.getCurrentHits();
			var hitsB:Array = B.getCurrentHits();
			
			var bodyA:Rectangle;
			var bodyB:Rectangle;
			if (A is BaseGameSprite && !(A as BaseGameSprite).isAllowBeHit) {
				bodyA = null;
			}
			else {
				bodyA = A.getBodyArea();
			}
			if (B is BaseGameSprite && !(B as BaseGameSprite).isAllowBeHit) {
				bodyB = null;
			}
			else {
				bodyB = B.getBodyArea();
			}
			
			var AhitB:Object = getHitObj(hitsA, bodyB);
			var BhitA:Object = getHitObj(hitsB, bodyA);
			if (AhitB) {
				B.beHit(AhitB.hitVO, AhitB.hitRect);
				A.hit(AhitB.hitVO, B);
			}
			if (BhitA) {
				A.beHit(BhitA.hitVO, BhitA.hitRect);
				B.hit(BhitA.hitVO, A);
			}
		}
		
		private static function getHitObj(hitArray:Array, body:Rectangle):Object {
			if (!body) {
				return null;
			}
			if (!hitArray || hitArray.length < 1) {
				return null;
			}
			var hitLen:int = hitArray.length;
			for (var i:int = 0; i < hitLen; i++) {
				var hitvo:HitVO = hitArray[i];
				if (hitvo == null) {
					continue;
				}
				
				var hitArea:Rectangle = hitvo.currentArea;
				if (hitArea == null) {
					continue;
				}
				
				var hitRect:Rectangle = hitArea.intersection(body);
				if (hitRect && !hitRect.isEmpty()) {
					return {
						hitVO  : hitvo,
						hitRect: hitRect
					};
				}
			}
			return null;
		}
		
//		public function renderPause():void {}
	}
}
