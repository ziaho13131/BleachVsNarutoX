/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import flash.display.BlendMode;
	
	/**
	 * 特效模型集合类
	 */
	public class EffectModel {
		
		private static var _i:EffectModel;
		
		private var _effect:Object;
		
		public static function get I():EffectModel {
			_i ||= new EffectModel();
			
			return _i;
		}
		
		public function initlize():void {
			initEffects();
			cacheEffects();
		}
		
		private function initEffects():void {
			_effect = {};
			
			_effect["bisha"]           = new EffectVO("XG_bs", {
				sound    : "snd_bs",
				blendMode: BlendMode.ADD
			});
			_effect["bisha_super"]     = new EffectVO("XG_cbs", {
				sound    : "snd_cbs",
				blendMode: BlendMode.ADD
			});
			_effect["dash"]            = new EffectVO("XG_rush", {
				sound: "snd_dash_air"
			});
			_effect["dash_air"]        = new EffectVO("XG_rush_air", {
				sound: "snd_dash_air"
			});
			_effect["jump"]            = new EffectVO("XG_jump", {
				sound: "snd_jump"
			});
			_effect["jump_air"]        = new EffectVO("XG_jump_air", {
				sound    : "snd_jump",
				blendMode: BlendMode.ADD
			});
			_effect["touch_floor"]     = new EffectVO("XG_luodi", {
				sound: "snd_luodi"
			});
			_effect["hit_floor"]       = new EffectVO("XG_hitfloor", {
				sound: "snd_hitfloor"
			});
			_effect["hit_floor_low"]   = new EffectVO("xg_hitfloor_low", {
				sound: "snd_hitfloor_low"
			});
			_effect["hit_floor_heavy"] = new EffectVO("xg_hitfllor_heavy", {
				sound: "snd_hitfloor_heavy"
			});
			_effect["hit_floor_yan"]   = new EffectVO("xg_hitfloor_yan", {
				blendMode: "lighten"
			});
			_effect["hit_end"]         = new EffectVO("xg_hitover");
			_effect["break_def"]       = new EffectVO("XG_mfdjx", {
				sound    : "snd_mfdjx",
				blendMode: BlendMode.ADD,
				freeze   : 500,
				shake    : {
					x   : 6,
					time: 400
				}
			});
			_effect["fz_bleach"]       = new EffectVO("XG_fz_bleach_mc", {
				sound: "snd_dash"
			});
			_effect["fz_naruto"]       = new EffectVO("XG_fz_naruto_mc", {
				sound: "snd_fz"
			});
			_effect["replaceSp"]       = new EffectVO("XG_tishen", {
				sound: "snd_fz"
			});
			_effect["replaceSp2"]      = new EffectVO("XG_tishen2");
			_effect["explodeSp"]       = new EffectVO("XG_bsq", {
				sound: "snd_baoqi1"
			});
			_effect["explodeSp2"]      = new EffectVO("XG_baoqi", {
				sound: "snd_baoqi"
			});
			_effect["ghost_step"]      = new EffectVO("XG_ghost_step", {
				sound    : "snd_ghost_step",
				blendMode: BlendMode.ADD
			});
			_effect["kobg"] = new EffectVO("kobg_effect_mc");
			
			initHitEffect();
			initDefenseEffect();
			initSpeicalEffect();
			initBuffEffect();
			initSteelHitEffect();
		}
		
		private function cacheEffects():void {
			for each(var e:EffectVO in _effect) {
				e.cacheBitmapData();
			}
		}
		
		private function initHitEffect():void {
			addHitEffect(HitType.CATCH, "xg_catch_hit", {
				freeze: 400,
				sound : "snd_hit_cache"
			});
			addHitEffect(HitType.KAN, "XG_kan", {
				sound     : "snd_kan1",
				freeze    : 50,
				blendMode : BlendMode.ADD,
				randRotate: true
			});
			addHitEffect(HitType.KAN_HEAVY, "XG_kanx", {
				sound     : "snd_kan2",
				freeze    : 400,
				blendMode : BlendMode.ADD,
				shine     : {
					color: 0xFFFFFF,
					alpha: 0.2
				},
				randRotate: true,
				shake     : {
					pow : 6,
					time: 400
				}
			});
			addHitEffect(HitType.DA, "XG_qdj", {
				sound     : "snd_hit2",
				blendMode : BlendMode.ADD,
				freeze    : 50,
				randRotate: true
			});
			addHitEffect(HitType.DA_HEAVY, "XG_qdjx", {
				sound     : "snd_hit_heavy",
				blendMode : BlendMode.ADD,
				randRotate: true,
				freeze    : 400,
				shine     : {
					color: 0xFFFFFF,
					alpha: 0.2
				},
				shake     : {
					pow : 6,
					time: 400
				}
			});
			addHitEffect(HitType.MAGIC, "XG_mfdj", {
				sound     : "snd_hit2",
				freeze    : 50,
				blendMode : BlendMode.ADD,
				randRotate: true
			});
			addHitEffect(HitType.MAGIC_HEAVY, "XG_mfdjx", {
				sound     : "snd_mfdjx",
				freeze    : 400,
				blendMode : BlendMode.ADD,
				randRotate: true,
				shine     : {
					color: 0xFFFFFF,
					alpha: 0.2
				},
				shake     : {
					pow : 6,
					time: 400
				}
			});
			addHitEffect(HitType.FIRE, "XG_fire", {
				sound          : "snd_hit_fire",
				blendMode      : BlendMode.ADD,
				specialEffectId: "fire_ing",
				freeze         : 400,
				shine          : {
					color: 0xFFFF67,
					alpha: 0.2
				},
				shake          : {
					pow : 6,
					time: 400
				}
			});
			addHitEffect(HitType.ICE, "XG_ice", {
				sound          : "snd_hit_ice",
				blendMode      : BlendMode.ADD,
				specialEffectId: "ice_ing",
				freeze         : 400,
				shine          : {
					color: 0xA3E5F5,
					alpha: 0.2
				},
				shake          : {
					pow : 6,
					time: 400
				}
			});
			addHitEffect(HitType.ELECTRIC, "XG_leidian", {
				sound          : "snd_hit_dian",
				blendMode      : "hardlight",
				specialEffectId: "shock_ing",
				freeze         : 400,
				shine          : {
					color: 0x8288D2,
					alpha: 0.2
				},
				shake          : {
					pow : 6,
					time: 400
				}
			});
		}
		
		private function initDefenseEffect():void {
			addDefenseEffect(HitType.KAN, "XG_fykan", {
				sound       : "snd_fykan",
				freeze      : 50,
				blendMode   : BlendMode.ADD,
				followDirect: true
			});
			addDefenseEffect(HitType.KAN_HEAVY, "XG_fykanx", {
				sound       : "snd_fykanx",
				freeze      : 400,
				blendMode   : BlendMode.ADD,
				shine       : {
					color    : 0xFFFFFF,
					blendMode: "screen",
					alpha    : 0.1
				},
				followDirect: true,
				shake       : {
					pow : 6,
					time: 400
				}
			});
			addDefenseEffect(HitType.DA, "XG_fyq", {
				sound       : "snd_def",
				freeze      : 50,
				blendMode   : BlendMode.ADD,
				followDirect: true
			});
			addDefenseEffect(HitType.DA_HEAVY, "XG_fyqx", {
				sound       : "snd_defx",
				freeze      : 400,
				blendMode   : BlendMode.ADD,
				followDirect: true,
				shine       : {
					color: 0xFFFFFF,
					alpha: 0.1
				},
				shake       : {
					pow : 6,
					time: 400
				}
			});
			addDefenseEffect(HitType.MAGIC, "XG_mffy", {
				sound       : "snd_def",
				freeze      : 50,
				blendMode   : BlendMode.ADD,
				followDirect: true
			});
			addDefenseEffect(HitType.MAGIC_HEAVY, "XG_mffyx", {
				sound       : "snd_defx",
				freeze      : 400,
				blendMode   : BlendMode.ADD,
				followDirect: true,
				shine       : {
					color: 0xFFFFFF,
					alpha: 0.15
				},
				shake       : {
					pow : 6,
					time: 400
				}
			});
			addDefenseEffect(HitType.FIRE, "XG_fire_fy", {
				sound       : "snd_defx",
				freeze      : 400,
				blendMode   : BlendMode.ADD,
				followDirect: true,
				shine       : {
					color: 0xFFFF67,
					alpha: 0.2
				},
				shake       : {
					pow : 6,
					time: 400
				}
			});
			addDefenseEffect(HitType.ICE, "XG_ice_fy", {
				sound       : "snd_defx",
				freeze      : 400,
				blendMode   : BlendMode.ADD,
				followDirect: true,
				shine       : {
					color: 0xA3E5F5,
					alpha: 0.2
				},
				shake       : {
					pow : 6,
					time: 400
				}
			});
			addDefenseEffect(HitType.ELECTRIC, "XG_dian_fy", {
				sound       : "snd_defx",
				freeze      : 400,
				blendMode   : BlendMode.ADD,
				followDirect: true,
				shine       : {
					color: 0x8288D2,
					alpha: 0.2
				},
				shake       : {
					pow : 6,
					time: 400
				}
			});
		}
		
		private function initSpeicalEffect():void {
			_effect["fire_ing"] = new EffectVO("xg_fire_ing", {
				blendMode        : BlendMode.ADD,
				isSpecial        : true,
				targetColorOffset: [-255, -255, -255]
			});
			_effect["ice_ing"] = new EffectVO("xg_ice_ing", {
				blendMode        : BlendMode.ADD,
				isSpecial        : true,
				targetColorOffset: [0, 0, 255]
			});
			_effect["shock_ing"] = new EffectVO("xg_dian_ing", {
				blendMode        : BlendMode.ADD,
				isSpecial        : true,
				targetColorOffset: [50, -75, 255]
			});
		}
		
		private function initBuffEffect():void {
			_effect["buff_effect_speed"] = new EffectVO("xg_buff_effect_speed", {
				blendMode: BlendMode.ADD
			});
			_effect["buff_effect_power"] = new EffectVO("xg_buff_effect_power", {
				blendMode: BlendMode.ADD
			});
			_effect["buff_effect_defense"] = new EffectVO("xg_buff_effect_defense", {
				blendMode: BlendMode.ADD
			});
			
			_effect["buff_speed"] = new EffectVO("xg_buff_speed", {
				blendMode: BlendMode.ADD,
				isBuff   : true/*,
				targetColorOffset: [0, 50, 50]*/
			});
			_effect["buff_power"] = new EffectVO("xg_buff_power", {
				blendMode: BlendMode.ADD,
				isBuff   : true/*,
				targetColorOffset: [50, 0, 0]*/
			});
			_effect["buff_defense"] = new EffectVO("xg_buff_defense", {
				blendMode: BlendMode.ADD,
				isBuff   : true/*,
				targetColorOffset: [50, 25, 0]*/
			});
		}
		
		private function initSteelHitEffect():void {
			_effect["steel_hit_kan"] = new EffectVO("XG_kan", {
				sound     : "snd_hit_steel",
				freeze    : 400,
				blendMode : BlendMode.ADD,
				shine     : {
					color: 0xFFFFFF,
					alpha: 0.2
				},
				randRotate: true,
				isSteelHit: true
			});
			_effect["steel_hit_qdj"] = new EffectVO("XG_qdj", {
				sound     : "snd_hit_steel",
				freeze    : 400,
				blendMode : BlendMode.ADD,
				shine     : {
					color: 0xFFFFFF,
					alpha: 0.2
				},
				randRotate: true,
				isSteelHit: true
			});
			_effect["steel_hit_mfdj"] = new EffectVO("XG_mfdj", {
				sound     : "snd_hit_steel",
				freeze    : 400,
				blendMode : BlendMode.ADD,
				shine     : {
					color: 0xFFFFFF,
					alpha: 0.2
				},
				randRotate: true,
				isSteelHit: true
			});
		}
		
		public function getEffect(id:String):EffectVO {
			return _effect[id];
		}
		
		public function getHitEffect(type:int):EffectVO {
			return _effect["hit_" + type];
		}
		
		public function getDefenseEffect(type:int):EffectVO {
			var effect:EffectVO = _effect["defense_" + type];
			return effect ? effect : _effect["defense_5"];
		}
		
		private function addHitEffect(type:int, className:String, param:Object = null):void {
			var effect:EffectVO = new EffectVO(className, param);
			_effect["hit_" + type] = effect;
		}
		
		private function addDefenseEffect(type:int, className:String, param:Object = null):void {
			var effect:EffectVO = new EffectVO(className, param);
			_effect["defense_" + type] = effect;
		}
	}
}
