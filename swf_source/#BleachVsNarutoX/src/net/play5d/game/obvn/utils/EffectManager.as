/**
 * 已重建完成
 */
package net.play5d.game.obvn.utils {
	import flash.utils.Dictionary;
	
	import net.play5d.game.obvn.data.EffectModel;
	import net.play5d.game.obvn.data.EffectVO;
	import net.play5d.game.obvn.fighter.models.HitVO;
	import net.play5d.game.obvn.views.effects.BuffEffectView;
	import net.play5d.game.obvn.views.effects.EffectView;
	import net.play5d.game.obvn.views.effects.ShineEffectView;
	import net.play5d.game.obvn.views.effects.SpecialEffectView;
	import net.play5d.game.obvn.views.effects.SteelHitEffect;
	
	/**
	 * 特效管理器
	 */
	public class EffectManager {
		
		
		private var _viewCache:Dictionary = new Dictionary();								// 视图缓存
		private var _hitCache:Dictionary = new Dictionary();								// 攻击缓存
		private var _shineCache:Vector.<ShineEffectView> = new Vector.<ShineEffectView>();	// 闪光缓存
		
		public function destory():void {
			for each(var i:Vector.<EffectView> in _viewCache) {
				for each(var j:EffectView in i) {
					j.destory();
				}
			}
			for each(var k:ShineEffectView in _shineCache) {
				k.destory();
			}
			
			_viewCache = null;
			_hitCache = null;
			_shineCache = null;
		}
		
		public function getEffectVOByHitVO(hitvo:HitVO):EffectVO {
			if (_hitCache[hitvo] != undefined) {
				return _hitCache[hitvo];
			}
			
			var effect:EffectVO = EffectModel.I.getHitEffect(hitvo.hitType);
			if (!effect) {
				_hitCache[hitvo] = null;
				return null;
			}
			
			effect = effect.clone();
			if (effect.shake) {
				if (effect.shake.pow != undefined && effect.shake.pow != 0) {
					effect.shake.y = effect.shake.pow;
				}
				if (effect.shake.x == 0 && effect.shake.y == 0) {
					effect.shake.x = 3;
				}
			}
			
			_hitCache[hitvo] = effect;
			return effect;
		}
		
		public function getEffectView(data:EffectVO):EffectView {
			var evs:Vector.<EffectView> = _viewCache[data] as Vector.<EffectView>;
			
			if (evs) {
				for each (var ev:EffectView in evs) {
					if (!ev.isActive) {
						return ev;
					}
				}
			}
			else {
				evs = new Vector.<EffectView>();
				_viewCache[data] = evs;
			}
			
			var effectView:EffectView = null;
			if (data.isSpecial) {
				effectView = new SpecialEffectView(data);
			}
			else if (data.isBuff) {
				effectView = new BuffEffectView(data);
			}
			else if (data.isSteelHit) {
				effectView = new SteelHitEffect(data);
			}
			else {
				effectView = new EffectView(data);
			}
			
			evs.push(effectView);
			return effectView;
		}
		
		public function getShine():ShineEffectView {
			for each (var shine:ShineEffectView in _shineCache) {
				if (!shine.isActive) {
					return shine;
				}
			}
			
			var se:ShineEffectView = new ShineEffectView();
			_shineCache.push(se);
			
			return se;
		}
	}
}
