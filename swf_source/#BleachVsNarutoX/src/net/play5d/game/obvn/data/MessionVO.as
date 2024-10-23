/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	
	/**
	 * 小队模式每关值对象
	 */
	public class MessionVO {
		
		public var comicType:int;
		public var gameMode:int;						// 游戏模式
		
		public var stageList:Vector.<MessionStageVO>;
		
		public function initByXML(xml:XML):void {
			stageList = new Vector.<MessionStageVO>();
			comicType = xml.@comicType;
			gameMode = xml.@gameMode;
			
			for (var i:int = 0; i < xml.stage.length(); i++) {
				var sx:Object = xml.stage[i];
				var fighter:String = sx.@fighter;
				var msv:MessionStageVO = new MessionStageVO();
				
				msv.mession = this;
				msv.assister = sx.@assister;
				msv.fighters = fighter.split(",");
				msv.map = sx.@map;
				msv.hpRate = Number(sx.@hpRate) > 0 ? Number(sx.@hpRate) : 1;
				msv.attackRate = Number(sx.@attackRate) > 0 ? Number(sx.@attackRate) : 1;
				
				stageList.push(msv);
			}
		}
	}
}
