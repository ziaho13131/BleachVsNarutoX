/**
 * 已重建完成
 */
package net.play5d.game.obvn.ctrl {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.ctrl.game_ctrler.GameCtrler;
	import net.play5d.game.obvn.data.EffectModel;
	import net.play5d.game.obvn.data.EffectVO;
	import net.play5d.game.obvn.data.HitType;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterDefenseType;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.fighter.vos.FighterBuffVO;
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	import net.play5d.game.obvn.stage.GameStage;
	import net.play5d.game.obvn.utils.EffectManager;
	import net.play5d.game.obvn.views.effects.BitmapFilterView;
	import net.play5d.game.obvn.views.effects.BlackBackView;
	import net.play5d.game.obvn.views.effects.BuffEffectView;
	import net.play5d.game.obvn.views.effects.EffectView;
	import net.play5d.game.obvn.views.effects.ShadowEffectView;
	import net.play5d.game.obvn.views.effects.ShineEffectView;
	import net.play5d.game.obvn.views.effects.SpecialEffectView;
	
	/**
	 * 特效控制器
	 */
	public class EffectCtrl {
		
		public static var EFFECT_SMOOTHING:Boolean = true;
		public static var SHADOW_ENABLED:Boolean = true;
		public static var SHAKE_ENABLED:Boolean = true;
		
		private static var _i:EffectCtrl;
		
		public var shineMaxCount:int = 3;
		
		private var _gameStage:GameStage;
		private var _effectLayer:Sprite;
		
		private var _manager:EffectManager;
		
		public var freezeEnabled:Boolean = true;
		private var _freezeFrame:int = 0;
		
		private var _effects:Vector.<EffectView>;
		
		private var _justRenderAnimateTargets:Vector.<BaseGameSprite>;
		private var _justRenderTargets:Vector.<BaseGameSprite>;
		
		private var _shineEffects:Vector.<ShineEffectView>;
		private var _shadowEffects:Dictionary;
		private var _filterEffects:Vector.<BitmapFilterView> = new Vector.<BitmapFilterView>();
		private var _blackBack:BlackBackView;
		
		private var _shakeHoldX:int = 0;
		private var _shakeHoldY:int = 0;
		private var _shakePowX:int = 0;
		private var _shakePowY:int = 0;
		private var _shakeXDirect:int = 1;
		private var _shakeYDirect:int = 1;
		private var _shakeFrameX:int = 0;
		private var _shakeFrameY:int = 0;
		private var _shakeLoseX:int = 0;
		private var _shakeLoseY:int = 0;
		
		private var _renderAnimateGap:int = 0;
		private var _renderAnimateFrame:int = 0;
		
//		private var _renderAnimate:Boolean = true;
		
		private var _slowDownFrame:int;
		
		private var _replaceSkillFrame:int;
		private var _replaceSkillFrameHold:int;
		private var _replaceSkillPos:Point;
		private var _explodeSkillFrame:int;
		private var _explodeEffectPos:Point;
		
		private var _onFreezeOver:Vector.<Function> = null;
		
		public static function get I():EffectCtrl {
			_i ||= new EffectCtrl();
			
			return _i;
		}
		
		public function destory():void {
			endShake();
			_replaceSkillFrame = 0;
			_explodeSkillFrame = 0;
			
			if (_manager) {
				_manager.destory();
				_manager = null;
			}
			if (_blackBack) {
				_blackBack.destory();
				_blackBack = null;
			}
			
			_effects = null;
			_justRenderAnimateTargets = null;
			_justRenderTargets = null;
			_shineEffects = null;
			_shadowEffects = null;
			_gameStage = null;
			_effectLayer = null;
		}
		
		public function initlize(gameStage:GameStage, effectLayer:Sprite):void {
			_manager = new EffectManager();
			_gameStage = gameStage;
			_effectLayer = effectLayer;
			
			_effects = new Vector.<EffectView>();
			
			_justRenderAnimateTargets = new Vector.<BaseGameSprite>();
			_justRenderTargets = new Vector.<BaseGameSprite>();
			
			_shineEffects = new Vector.<ShineEffectView>();
			_shadowEffects = new Dictionary();
			
			_blackBack = new BlackBackView();
			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
		}
		
		public function render():void {
			if (freezeEnabled) {
				renderFreeze();
			}
			renderSlowDown();
			renderShine();
			
			for each (var effect:EffectView in _effects) {
				effect.render();
			}
			
			if (isRenderAnimate()) {
				renderAnimate();
			}
			if (_replaceSkillFrameHold > 0) {
				renderReplaceSkill();
			}
			if (_explodeSkillFrame > 0) {
				renderEnergyExplode();
			}
			if (_justRenderTargets && _justRenderTargets.length > 0) {
				for each(var sp:BaseGameSprite in _justRenderTargets) {
					sp.render();
					GameLogic.fixGameSpritePosition(sp);
				}
			}
		}
		
		private function renderShine():void {
			for each (var sv:ShineEffectView in _shineEffects) {
				sv.render();
			}
		}
		
		private function renderAnimate():void {
			for each(var ev:EffectView in _effects) {
				ev.renderAnimate();
			}
			
			for each(var s:ShadowEffectView in _shadowEffects) {
				s.render();
			}
			if (_justRenderAnimateTargets.length > 0) {
				for each(var g:BaseGameSprite in _justRenderAnimateTargets) {
					g.renderAnimate();
				}
			}
			if (_blackBack) {
				_blackBack.renderAnimate();
			}
			renderShakeX();
			renderShakeY();
		}
		
		private function isRenderAnimate():Boolean {
			if (_renderAnimateGap > 0) {
				if (_renderAnimateFrame++ >= _renderAnimateGap) {
					_renderAnimateFrame = 0;
					
					return true;
				}
				
				return false;
			}
			
			return true;
		}
		
		private function renderFreeze():void {
			if (_freezeFrame > 0) {
				_freezeFrame--;
				if (_freezeFrame <= 0) {
					if (_onFreezeOver) {
						for each (var func:Function in _onFreezeOver) {
							func();
						}
						
						_onFreezeOver = null;
					}
					GameCtrler.I.resume();
				}
			}
		}
		
		private function renderShakeX():void {
			var shakeX:Number = _shakeHoldX + _shakePowX;
			
			if (shakeX > 0) {
				_gameStage.x = shakeX * _shakeXDirect;
				
				if (_shakePowX > 0 && _shakeFrameX % 2 == 0) {
					_shakePowX -= _shakeLoseX;
					
					if (_shakePowX < _shakeLoseX) {
						_shakePowX = 0;
						_gameStage.x = 0;
						_shakeFrameX = 0;
						_shakeLoseX = 0;
						
						return;
					}
				}
				
				_shakeFrameX++;
				_shakeXDirect *= -1;
			}
		}
		
		private function renderShakeY():void {
			var shakeY:Number = _shakeHoldY + _shakePowY;
			if (shakeY > 0) {
				_gameStage.y = shakeY * _shakeYDirect;
				
				if (_shakePowY > 0 && _shakeFrameY % 2 == 0) {
					_shakePowY -= _shakeLoseY;
					
					if (_shakePowY < _shakeLoseY) {
						_shakePowY = 0;
						_gameStage.y = 0;
						_shakeFrameY = 0;
						_shakeLoseY = 0;
						
						return;
					}
				}
				
				_shakeYDirect *= -1;
				_shakeFrameY++;
			}
		}
		
		public function doHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite = null):void {
			var effect:EffectVO = _manager.getEffectVOByHitVO(hitvo);
			if (!effect) {
				return;
			}
			
			var ex:Number = hitRect.x + hitRect.width / 2;
			var ey:Number = hitRect.y + hitRect.height / 2;
			var direct:int = 1;
			if (effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite) {
				direct = (hitvo.owner as IGameSprite).direct;
			}
			
			doEffectVO(effect, ex, ey, direct, target);
		}
		
		public function doDefenseEffect(
			hitvo:HitVO, hitRect:Rectangle,
			defenseType:int, target:IGameSprite = null):void 
		{
			var hitType:int = hitvo.hitType;
			
			switch (defenseType) {
				case FighterDefenseType.SWOARD:
					break;
				case FighterDefenseType.HAND:
					if (hitType == HitType.KAN) {
						hitType = HitType.DA;
					}
					if (hitType == HitType.KAN_HEAVY) {
						hitType = HitType.DA_HEAVY;
						break;
					}
			}
			
			var effect:EffectVO = EffectModel.I.getDefenseEffect(hitType);
			if (!effect) {
				return;
			}
			
			var ex:Number = hitRect.x + hitRect.width / 2;
			var ey:Number = hitRect.y + hitRect.height / 2;
			if (effect.shake) {
				if (effect.shake.pow != undefined && effect.shake.pow != 0) {
					effect.shake.x = 0;
					effect.shake.y = effect.shake.pow;
				}
			}
			
			var direct:int = 1;
			if (effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite) {
				direct = int((hitvo.owner as IGameSprite).direct);
			}
			
			doEffectVO(effect, ex, ey, direct, target);
		}
		
		public function doSteelHitEffect(hitvo:HitVO, hitRect:Rectangle, target:IGameSprite):void {
			var effect:EffectVO = null;
			switch (hitvo.hitType) {
				case 0:
					return;
				case HitType.KAN:
				case HitType.KAN_HEAVY:
					effect = EffectModel.I.getEffect("steel_hit_kan");
					break;
				case HitType.DA:
				case HitType.DA_HEAVY:
					effect = EffectModel.I.getEffect("steel_hit_qdj");
					break;
				default:
					effect = EffectModel.I.getEffect("steel_hit_mfdj");
			}
			
			if (!effect) {
				return;
			}
			
			var ex:Number = hitRect.x + hitRect.width / 2;
			var ey:Number = hitRect.y + hitRect.height / 2;
			
			var direct:int = 1;
			if (effect.followDirect && hitvo.owner && hitvo.owner is IGameSprite) {
				direct = (hitvo.owner as IGameSprite).direct;
			}
			
			doEffectVO(effect, ex, ey, direct, target);
		}
		
		public function doEffectById(id:String, x:Number, y:Number, direct:int = 1, target:IGameSprite = null):void {
			var effect:EffectVO = EffectModel.I.getEffect(id);
			if (effect) {
				doEffectVO(effect, x, y, direct, target);
			}
		}
		
		public function assisterEffect(fz:Assister):void {
			if (fz.data.comicType == 1) {
				doEffectById("fz_naruto", fz.x, fz.y);
			}
			else {
				doEffectById("fz_bleach", fz.x, fz.y);
			}
		}
		
		public function doEffectVO(
			effect:EffectVO,
			ex:Number, ey:Number, direct:int = 1,
			target:IGameSprite = null):void 
		{
			var effectView:EffectView = addEffect(effect, ex, ey, direct);
			if (effectView) {
				_effectLayer.addChild(effectView.display);
			}
			
			if (effect.freeze > 0) {
				freeze(effect.freeze);
			}
			
			if (effect.shake) {
				var time:Number = effect.shake.time != undefined ? effect.shake.time : 0;
				var shakex:Number = effect.shake.x != undefined ? effect.shake.x : 0;
				var shakey:Number = effect.shake.y != undefined ? effect.shake.y : 0;
				shake(shakex, shakey, time);
			}
			if (effect.shine) {
				var color:uint = effect.shine.color != undefined ? effect.shine.color : 0xffffff;
				var alpha:Number = effect.shine.alpha != undefined ? effect.shine.alpha : 0.2;
				
				shine(color, alpha);
			}
			if (effect.slowDown) {
				var rate:Number = effect.slowDown.rate != undefined ? effect.slowDown.rate : 1.5;
				var slowDownTime:int = effect.slowDown.time != undefined ? effect.slowDown.time : 1000;
				
				slowDown(rate, slowDownTime);
			}
			if (target) {
				effectView.setTarget(target);
			}
			if (effect.specialEffectId && target && target is FighterMain) {
				doSpecialEffect(effect.specialEffectId, target as FighterMain);
			}
		}
		
		public function doSpecialEffect(id:String, target:FighterMain):void {
			var data:EffectVO = EffectModel.I.getEffect(id);
			
			var effect:SpecialEffectView = addEffect(data, target.x, target.y, target.direct) as SpecialEffectView;
			if (effect) {
				effect.setTarget(target);
				_effectLayer.addChild(effect.display);
			}
		}
		
		public function doBuffEffect(id:String, target:FighterMain, buff:FighterBuffVO):void {
			var data:EffectVO = EffectModel.I.getEffect(id);
			
			var effect:BuffEffectView = addEffect(data, target.x, target.y, target.direct) as BuffEffectView;
			if (effect) {
				effect.setTarget(target);
				effect.setBuff(buff);
				_effectLayer.addChild(effect.display);
			}
		}
		
		private function addEffect(data:EffectVO, x:Number, y:Number, direct:int = 1):EffectView {
			var effectView:EffectView = _manager.getEffectView(data);
			if (!effectView) {
				return null;
			}
			
			effectView.start(x, y, direct);
			effectView.addRemoveBack(removeEffect);
			
			_effects.push(effectView);
			return effectView;
		}
		
		private function removeEffect(effect:EffectView):void {
			var id:int = _effects.indexOf(effect);
			if (id != -1) {
				_effects.splice(id, 1);
			}
		}
		
		public function freeze(time:int):void {
			if (!freezeEnabled) {
				return;
			}
			if (time < 1) {
				return;
			}
			
			var frame:int = time / 1000 * GameConfig.FPS_GAME;
			if (frame < 1) {
				return;
			}
			
			_freezeFrame = frame;
			GameCtrler.I.pause();
		}
		
		private function justRender(target:BaseGameSprite):void {
			if (_justRenderTargets.indexOf(target) == -1) {
				_justRenderTargets.push(target);
			}
		}
		
		private function justRenderAnimate(animateTarget:BaseGameSprite):void {
			if (_justRenderAnimateTargets.indexOf(animateTarget) == -1) {
				_justRenderAnimateTargets.push(animateTarget);
			}
		}
		
		private function cancelJustRender(target:BaseGameSprite):Boolean {
			var index:int = _justRenderTargets.indexOf(target);
			if (index != -1) {
				_justRenderTargets.splice(index, 1);
			}
			
			return _justRenderTargets.length < 1;
		}
		
		private function cancelJustRenderAnimate(target:BaseGameSprite):Boolean {
			var index:int = _justRenderAnimateTargets.indexOf(target);
			if (index != -1) {
				_justRenderAnimateTargets.splice(index, 1);
			}
			
			return _justRenderAnimateTargets.length < 1;
		}
		
		public function shine(color:uint = 16777215, alpha:Number = 0.2):void {
			if (GameConfig.FPS_SHINE_EFFECT == 0) {
				return;
			}
			
			if (_shineEffects.length > shineMaxCount) {
				_shineEffects[0].removeSelf();
			}
			
			var sv:ShineEffectView = _manager.getShine();
			sv.init(color, alpha);
			sv.onRemove = removeShine;
			
			_shineEffects.push(sv);
			_gameStage.addChild(sv);
		}
		
		private function removeShine(s:ShineEffectView):void {
			var id:int = _shineEffects.indexOf(s);
			if (id != -1) {
				_shineEffects.splice(id, 1);
			}
		}
		
		public function startShake(sx:Number, sy:Number):void {
			_shakeHoldX = sx;
			_shakeHoldY = sy;
		}
		
		public function endShake():void {
			_shakeHoldX = 0;
			_shakeHoldY = 0;
			_gameStage.x = 0;
			_gameStage.y = 0;
		}
		
		public function shake(powX:Number = 0, powY:Number = 3, time:int = 500):void {
			if (!SHAKE_ENABLED) {
				return;
			}
			if (isNaN(powX) || isNaN(powY)) {
				return;
			}
			
			if (powX != 0) {
				if (_shakePowX == 0) {
					_shakeXDirect = powX > 0 ? 1 : -1;
					_shakePowX = Math.abs(powX);
				}
				else {
					_shakePowX += Math.abs(powX) / 2;
				}
			}
			
			if (powY != 0) {
				if (_shakePowY == 0) {
					_shakeYDirect = powY > 0 ? 1 : -1;
					_shakePowY = Math.abs(powY);
				}
				else {
					_shakePowY += Math.abs(powY) / 2;
				}
			}
			
			if (time <= 0) {
				time = 500;
			}
			
			_shakeLoseX = Math.ceil(_shakePowX / (time / 1000 * 30));
			_shakeLoseY = Math.ceil(_shakePowY / (time / 1000 * 30));
			if (_shakeLoseX < 1) {
				_shakeLoseX = 1;
			}
			if (_shakeLoseY < 1) {
				_shakeLoseY = 1;
			}
		}
		
		public function startShadow(target:DisplayObject, r:int = 0, g:int = 0, b:int = 0):void {
			if (!SHADOW_ENABLED) {
				return;
			}
			
			var sv:ShadowEffectView = _shadowEffects[target] as ShadowEffectView;
			if (sv) {
				sv.r = r;
				sv.g = g;
				sv.b = b;
				sv.stopShadow = false;
				
				return;
			}
			
			sv = new ShadowEffectView(target, r, g, b);
			sv.onRemove = removeShadow;
			sv.container = _effectLayer;
			
			_shadowEffects[target] = sv;
		}
		
		public function endShadow(target:DisplayObject):void {
			if (!SHADOW_ENABLED) {
				return;
			}
			if (!_shadowEffects) {
				return;
			}
			
			var sv:ShadowEffectView = _shadowEffects[target] as ShadowEffectView;
			if (sv) {
				sv.stopShadow = true;
			}
		}
		
		private function removeShadow(s:ShadowEffectView):void {
			if (!_shadowEffects) {
				return;
			}
			
			delete _shadowEffects[s.target];
		}
		
		public function bisha(target:BaseGameSprite, isSuper:Boolean = false, face:DisplayObject = null):void {
			justRenderAnimate(target);
			
			GameCtrler.I.pause();
			GameCtrler.I.setRenderHit(false);
			
			_gameStage.addChildAt(_blackBack, 0);
			
			_blackBack.fadIn();
			
			if (face && target is FighterMain) {
				showFace(target as FighterMain, face);
			}
			if (isSuper) {
				GameCtrler.I.gameState.cameraFocusOne(target.getDisplay());
				doEffectById("bisha_super", target.x, target.y - 50);
			}
			else {
				doEffectById("bisha", target.x, target.y - 50);
			}
			
			_gameStage.getMap().setVisible(false);
			_gameStage.setVisibleByClass(BitmapFilterView, false);
		}
		
		public function endBisha(target:BaseGameSprite):void {
			if (cancelJustRenderAnimate(target)) {
				GameCtrler.I.resume();
				GameCtrler.I.gameState.cameraResume();
				GameCtrler.I.setRenderHit(true);
				
				_blackBack.fadOut();
				_gameStage.getMap().setVisible(true);
				_gameStage.setVisibleByClass(BitmapFilterView, true);
			}
		}
		
		private function showFace(target:FighterMain, face:DisplayObject):void {
			var faceId:int = 1;
			
			var curTarget:IGameSprite = target.getCurrentTarget();
			if (curTarget) {
				
				var display:DisplayObject = curTarget.getDisplay();
				if (display) {
					faceId = target.getDisplay().x > display.x ? 2 : 1;
				}
			}
			
			_blackBack.showBishaFace(faceId, face);
		}
		
		public function wanKai(target:FighterMain, face:DisplayObject = null):void {
			justRenderAnimate(target);
			
			GameCtrler.I.pause();
			GameCtrler.I.setRenderHit(false);
			
			_gameStage.addChildAt(_blackBack, 0);
			_blackBack.fadIn();
			
			if (face) {
				showFace(target, face);
			}
			
			GameCtrler.I.gameState.cameraFocusOne(target.getDisplay());
			doEffectById("bisha_super", target.x, target.y - 50);
			
			_gameStage.getMap().setVisible(false);
			_gameStage.setVisibleByClass(BitmapFilterView, false);
		}
		
		public function endWanKai(target:FighterMain):void {
			if (cancelJustRenderAnimate(target)) {
				GameCtrler.I.resume();
				GameCtrler.I.gameState.cameraResume();
				
				_blackBack.fadOut();
				
				GameCtrler.I.setRenderHit(true);
				_gameStage.getMap().setVisible(true);
			}
		}
		
		public function jumpEffect(x:Number, y:Number):void {
			doEffectById("jump", x, y);
		}
		
		public function jumpAirEffect(x:Number, y:Number):void {
			doEffectById("jump_air", x, y);
		}
		
		public function touchFloorEffect(x:Number, y:Number):void {
			doEffectById("touch_floor", x, y);
		}
		
		public function hitFloorEffect(type:int, x:Number, y:Number):void {
			switch (type) {
				case 0:
					doEffectById("hit_floor", x, y);
					break;
				case 1:
					doEffectById("hit_floor_low", x, y);
					break;
				case 2:
					doEffectById("hit_floor_heavy", x, y);
					doEffectById("hit_floor_yan", x, y);
			}
		}
		
		public function slowDown(rate:Number, time:int = 1000):void {
			GameCtrler.I.slow(rate);
			
			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / (30 / rate)) - 1;
			if (time == 0) {
				_slowDownFrame = 0;
			}
			else {
				_slowDownFrame = time * 0.001 * GameConfig.FPS_GAME;
			}
		}
		
		private function renderSlowDown():void {
			if (_slowDownFrame > 0) {
				_slowDownFrame--;
				
				if (_slowDownFrame <= 0) {
					slowDownResume();
				}
			}
		}
		
		public function slowDownResume():void {
			GameCtrler.I.slowResume();
			_renderAnimateGap = Math.ceil(GameConfig.FPS_GAME / 30) - 1;
			_slowDownFrame = 0;
		}
		
		public function BGEffect(id:String, hold:Number = -1):void {
			var data:EffectVO = EffectModel.I.getEffect(id);
			if (!data) {
				return;
			}
			
			var effect:EffectView = addEffect(data, 0, 0, 1);
			if (hold != -1) {
				effect.holdFrame = hold * 30;
			}
			if (effect) {
				effect.addRemoveBack(function ():void {
					_gameStage.getMap().setVisible(true);
				});
				
				_gameStage.getMap().setVisible(false);
				_gameStage.addChildAt(effect.display, 0);
			}
		}
		
		public function setOnFreezeOver(v:Function):void {
			if (!_onFreezeOver) {
				_onFreezeOver = new Vector.<Function>();
			}
			_onFreezeOver.push(v);
		}
		
		public function replaceSkill(target:BaseGameSprite):void {
			GameCtrler.I.pause();
			
			_gameStage.addChildAt(_blackBack, 0);
			_gameStage.getMap().setVisible(false);
			
			doEffectById("replaceSp", target.x, target.y);
			
			_replaceSkillPos = new Point(target.x, target.y);
			_replaceSkillFrame = 0;
			_replaceSkillFrameHold = GameConfig.FPS_GAME / 3;
		}
		
		private function endReplaceSkill():void {
			GameCtrler.I.resume();
			
			_blackBack.fadOut();
			_gameStage.getMap().setVisible(true);
			
			_replaceSkillFrameHold = 0;
		}
		
		private function renderReplaceSkill():void {
			_replaceSkillFrame++;
			if (_replaceSkillFrame == 1) {
				doEffectById("replaceSp2", _replaceSkillPos.x, _replaceSkillPos.y);
			}
			if (_replaceSkillFrame > _replaceSkillFrameHold) {
				endReplaceSkill();
			}
		}
		
		public function energyExplode(target:BaseGameSprite):void {
			GameCtrler.I.pause();
			
			_gameStage.addChildAt(_blackBack, 0);
			_gameStage.getMap().setVisible(false);
			
			doEffectById("explodeSp", target.x, target.y);
			
			_explodeEffectPos = new Point(target.x, target.y);
			_explodeSkillFrame = 0.7 * GameConfig.FPS_GAME;
		}
		
		private function endEnergyExplode():void {
			doEffectById("explodeSp2", _explodeEffectPos.x, _explodeEffectPos.y);
			
			GameCtrler.I.resume();
			
			_blackBack.fadOut();
			_gameStage.getMap().setVisible(true);
			
			_explodeSkillFrame = 0;
		}
		
		private function renderEnergyExplode():void {
			_explodeSkillFrame--;
			if (_explodeSkillFrame <= 0) {
				endEnergyExplode();
			}
		}
		
		public function ghostStep(target:BaseGameSprite):void {
			justRender(target);
			justRenderAnimate(target);
			
			GameCtrler.I.pause();
			
			_gameStage.addChildAt(_blackBack, 0);
			_blackBack.fadIn();
			_gameStage.getMap().setVisible(false);
			
			SoundCtrl.I.playSwcSound(snd_ghost_jump);
		}
		
		public function endGhostStep(target:BaseGameSprite):void {
			var cancel1:Boolean = cancelJustRender(target);
			var cancel2:Boolean = cancelJustRenderAnimate(target);
			
			if (cancel1 && cancel2) {
				GameCtrler.I.resume();
				_blackBack.fadOut();
				_gameStage.getMap().setVisible(true);
			}
		}
		
		public function startFilter(target:BaseGameSprite, filter:BitmapFilter, filterOffset:Point = null):void {
			var bv:BitmapFilterView = null;
			
			for each(var i:BitmapFilterView in _filterEffects) {
				if (i.target == target) {
					bv = i;
					break;
				}
			}
			if (!bv) {
				bv = new BitmapFilterView(target, filter, filterOffset);
				
				GameCtrler.I.addGameSprite(0, bv, 0);
				_filterEffects.push(bv);
			}
			else {
				bv.update(filter, filterOffset);
			}
		}
		
		public function endFilter(target:BaseGameSprite):void {
			for (var i:int = 0; i < _filterEffects.length; i++) {
				var bv:BitmapFilterView = _filterEffects[i] as BitmapFilterView;
				if (bv.target == target) {
					GameCtrler.I.removeGameSprite(bv, true);
					
					_filterEffects.splice(i, 1);
					break;
				}
			}
		}
	}
}
