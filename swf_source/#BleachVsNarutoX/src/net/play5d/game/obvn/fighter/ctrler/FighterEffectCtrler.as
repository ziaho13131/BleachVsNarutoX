/**
 * 已重建完成
 */
package net.play5d.game.obvn.fighter.ctrler {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.Debugger;
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.fighter.FighterActionState;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	
	/**
	 * 角色特效控制器
	 */
	public class FighterEffectCtrler {
		
		private var _target:BaseGameSprite;
		private var _targetDisplay:DisplayObject;
		
		private var _inGhostStep:Boolean;
		private var _faceObj:Object = {};
		private var _isShakeIng:Boolean;
		private var _isShadowIng:Boolean;
		private var _isGlowIng:Boolean;
		
		public function FighterEffectCtrler(target:BaseGameSprite) {
			_target = target;
			_targetDisplay = target.getDisplay();
		}
		
		public function destory():void {
			_target = null;
			_targetDisplay = null;
			_faceObj = null;
		}
		
		public function setBishaFace(id:String, face:Class):void {
			_faceObj[id] = face;
		}
		
		private function getFace(id:String):DisplayObject {
			if (!id) {
				return null;
			}
			
			var faceClass:Class = _faceObj[id] as Class;
			if (!faceClass) {
				Debugger.errorMsg("Undefined bishaFace:" + id);
				return null;
			}
			
			var bd:BitmapData = new faceClass() as BitmapData;
			var bp:Bitmap = new Bitmap(bd);
			bp.smoothing = true;
			
			return bp;
		}
		
		public function shine(color:uint = 0xFFFFFF):void {
			var alpha:Number = color == 0xFFFFFF ? 0.3 : 0.2;
			EffectCtrl.I.shine(color, alpha);
		}
		
		public function shake(powX:Number = 0, powY:Number = 3, time:Number = 0):void {
			var pow:Number = Math.max(powX, powY);
			EffectCtrl.I.shake(0, pow * 2, time * 1000);
		}
		
		public function startShake(powX:Number = 0, powY:Number = 3):void {
			_isShakeIng = true;
			EffectCtrl.I.startShake(powX, powY);
		}
		
		public function endShake():void {
			if (_isShakeIng) {
				EffectCtrl.I.endShake();
				_isShakeIng = false;
			}
		}
		
		public function shadow(r:int = 0, g:int = 0, b:int = 0):void {
			_isShadowIng = true;
			EffectCtrl.I.startShadow(_targetDisplay, r, g, b);
		}
		
		public function endShadow():void {
			if (_isShadowIng) {
				EffectCtrl.I.endShadow(_targetDisplay);
			}
		}
		
		public function dash():void {
			if (_target.isInAir) {
				EffectCtrl.I.doEffectById("dash_air", _target.x, _target.y, _target.direct);
			}
			else {
				EffectCtrl.I.doEffectById("dash", _target.x, _target.y, _target.direct);
			}
		}
		
		public function bisha(isSuper:Boolean = false, face:String = null):void {
			var faceDisplay:DisplayObject = getFace(face);
			EffectCtrl.I.bisha(_target, isSuper, faceDisplay);
		}
		
		public function endBisha():void {
			EffectCtrl.I.endBisha(_target);
		}
		
		public function startWanKai(face:String = null):void {
			var faceDisplay:DisplayObject = face ? getFace(face) : null;
			EffectCtrl.I.wanKai(_target as FighterMain, faceDisplay);
		}
		
		public function endWanKai():void {
			if ((_target as FighterMain).actionState == FighterActionState.WAN_KAI_ING) {
				EffectCtrl.I.endWanKai(_target as FighterMain);
			}
		}
		
		public function walk():void {
			if (_inGhostStep) {
				EffectCtrl.I.doEffectById("ghost_step", _target.x, _target.y, _target.direct);
				return;
			}
			
			SoundCtrl.I.playAssetSoundRandom("se_step1", "se_step2", "se_step3");
		}
		
		public function jump():void {
			EffectCtrl.I.jumpEffect(_targetDisplay.x, _targetDisplay.y);
		}
		
		public function jumpAir():void {
			EffectCtrl.I.jumpAirEffect(_targetDisplay.x, _targetDisplay.y);
		}
		
		public function touchFloor():void {
			EffectCtrl.I.touchFloorEffect(_targetDisplay.x, _targetDisplay.y);
		}
		
		public function hitFloor(type:int):void {
			EffectCtrl.I.hitFloorEffect(type, _targetDisplay.x, _targetDisplay.y);
		}
		
		public function slowDown(time:Number):void {
			EffectCtrl.I.slowDown(1.5, time * 1000);
		}
		
		public function energyExplode():void {
			EffectCtrl.I.energyExplode(_target);
		}
		
		public function replaceSkill():void {
			EffectCtrl.I.replaceSkill(_target);
		}
		
		public function ghostStep():void {
			_inGhostStep = true;
			shadow(0, 0, 255);
			
			EffectCtrl.I.ghostStep(_target);
		}
		
		public function endGhostStep():void {
			_inGhostStep = false;
			endShadow();
			
			EffectCtrl.I.endGhostStep(_target);
		}
		
		public function startGlow(color:uint = 0xFFFFFF):void {
			_isGlowIng = true;
			
			var offset:Point = new Point(20, 20);
			var filter:GlowFilter = new GlowFilter(color, 1, offset.x, offset.y, 2, 1, false, true);
			
			EffectCtrl.I.startFilter(_target, filter, offset);
		}
		
		public function endGlow():void {
			if (_isGlowIng) {
				EffectCtrl.I.endFilter(_target);
			}
			
			_isGlowIng = false;
		}
		
		/**
		 * 播放轻砍声音
		 */
		public function playSoundHit1():void {
			SoundCtrl.I.playAssetSound("se_hit1");
		}
		
		/**
		 * 播放重砍声音
		 */
		public function playSoundHit2():void {
			SoundCtrl.I.playAssetSound("se_hit2");
		}
	}
}
