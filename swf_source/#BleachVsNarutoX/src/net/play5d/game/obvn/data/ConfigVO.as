/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import flash.display.StageQuality;
	
	import net.play5d.game.obvn.GameConfig;
	import net.play5d.game.obvn.GameQuality;
	import net.play5d.game.obvn.MainGame;
	import net.play5d.game.obvn.ctrl.EffectCtrl;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.interfaces.GameInterface;
	import net.play5d.kyo.input.KyoKeyCode;
	import net.play5d.kyo.utils.KyoUtils;
	
	public class ConfigVO {
		
		// 按键 - 菜单模式
		private const KEY_MENU:int = 0;
		// 按键 - p1模式
		private const KEY_P1:int = 1;
		// 按键 - p2模式
		private const KEY_P2:int = 2;
		
		public const key_menu:KeyConfigVO = new KeyConfigVO(KEY_MENU);
		public const key_p1:KeyConfigVO = new KeyConfigVO(KEY_P1);
		public const key_p2:KeyConfigVO = new KeyConfigVO(KEY_P2);
		
		public var select_config:SelectStageConfigVO;
		
		public var AI_level    :int = 1;
		public var fighterHP   :Number = 1;
		public var fightTime   :int = 60;
		public var quality     :String = GameQuality.LOW;
		public var soundVolume :Number = 1;
		public var bgmVolume   :Number = 1;
		public var keyInputMode:int = 1;
		
//		public var extendConfig:IExtendConfig;
		
		public function ConfigVO() {
			select_config = new SelectStageConfigVO();
			super();
//			extendConfig = GameInterface.instance.getConfigExtend();
			setDefaultConfig(key_menu);
			setDefaultConfig(key_p1);
			setDefaultConfig(key_p2);
		}
		
		public function setDefaultConfig(keyConfig:KeyConfigVO):void {
			switch (keyConfig.id) {
				case KEY_MENU:
					keyConfig.setKeys(
						KyoKeyCode.W.code, KyoKeyCode.S.code, KyoKeyCode.A.code, KyoKeyCode.D.code, 
						KyoKeyCode.J.code, KyoKeyCode.K.code, KyoKeyCode.L.code, 
						KyoKeyCode.U.code, KyoKeyCode.I.code, KyoKeyCode.O.code
					);
					keyConfig.selects = [
						KyoKeyCode.J.code, KyoKeyCode.K.code, KyoKeyCode.L.code, 
						KyoKeyCode.U.code, KyoKeyCode.I.code, KyoKeyCode.O.code
					];
					break;
				case KEY_P1:
					keyConfig.setKeys(KyoKeyCode.W.code, KyoKeyCode.S.code, KyoKeyCode.A.code, KyoKeyCode.D.code, 
						KyoKeyCode.J.code, KyoKeyCode.K.code, KyoKeyCode.L.code,
						KyoKeyCode.U.code, KyoKeyCode.I.code, KyoKeyCode.O.code
					);
					break;
				case KEY_P2:
					keyConfig.setKeys(
						KyoKeyCode.UP.code, KyoKeyCode.DOWN.code, KyoKeyCode.LEFT.code, KyoKeyCode.RIGHT.code, 
						KyoKeyCode.Num1.code, KyoKeyCode.Num2.code, KyoKeyCode.Num3.code, 
						KyoKeyCode.Num4.code, KyoKeyCode.Num5.code, KyoKeyCode.Num6.code
					);
			}
		}
		
		public function toSaveObj():Object {
			var o:Object = {};
			o.key_p1 = key_p1.toSaveObj();
			o.key_p2 = key_p2.toSaveObj();
			o.AI_level = AI_level;
			o.fighterHP = fighterHP;
			o.fightTime = fightTime;
			o.quality = quality;
			o.keyInputMode = keyInputMode;
			o.soundVolume = soundVolume;
			o.bgmVolume = bgmVolume;
			
//			if (extendConfig) {
//				o.extend_config = extendConfig.toSaveObj();
//			}
			return o;
		}
		
		public function readSaveObj(o:Object):void {
			key_p1.readSaveObj(o.key_p1);
			key_p2.readSaveObj(o.key_p2);
//			if (o.extend_config && extendConfig) {
//				extendConfig.readSaveObj(o.extend_config);
//			}
			delete o["key_p1"];
			delete o["key_p2"];
			
			KyoUtils.setValueByObject(this, o);
		}
		
		public function getValueByKey(key:String):* {
			if (this.hasOwnProperty(key)) {
				return this[key];
			}
//			if (extendConfig) {
//				try {
//					return extendConfig[key];
//				}
//				catch (e:Error) {
//					trace(e);
//				}
//			}
			return null;
		}
		
		public function setValueByKey(key:String, value:*):void {
			if (this.hasOwnProperty(key)) {
				this[key] = value;
				
				switch (key) {
					case "bgmVolume":
						SoundCtrl.I.setBgmVolumn(bgmVolume);
						break;
					case "soundVolume":
						SoundCtrl.I.setSoundVolumn(soundVolume);
				}
//				return;
			}
//			if (extendConfig) {
//				try {
//					extendConfig[key] = value;
//				}
//				catch (e:Error) {
//					trace(e);
//				}
//			}
		}
		
		public function applyConfig():void {
			switch (quality) {
				case GameQuality.LOW:
					MainGame.I.stage.quality = StageQuality.LOW;
					GameConfig.setGameFps(30);
					GameConfig.FPS_SHINE_EFFECT = 15;
					EffectCtrl.EFFECT_SMOOTHING = false;
					break;
				case GameQuality.MEDIUM:
					MainGame.I.stage.quality = StageQuality.LOW;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 30;
					EffectCtrl.EFFECT_SMOOTHING = false;
					break;
				case GameQuality.HIGH:
					MainGame.I.stage.quality = StageQuality.MEDIUM;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 30;
					EffectCtrl.EFFECT_SMOOTHING = false;
					break;
				case GameQuality.HIGHER:
					MainGame.I.stage.quality = StageQuality.HIGH;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 30;
					EffectCtrl.EFFECT_SMOOTHING = true;
					break;
				case GameQuality.BEST:
					MainGame.I.stage.quality = StageQuality.HIGH;
					GameConfig.setGameFps(60);
					GameConfig.FPS_SHINE_EFFECT = 60;
					EffectCtrl.EFFECT_SMOOTHING = true;
			}
			
			GameInterface.instance.applyConfig(this);
			SoundCtrl.I.setBgmVolumn(bgmVolume);
			SoundCtrl.I.setSoundVolumn(soundVolume);
		}
	}
}
