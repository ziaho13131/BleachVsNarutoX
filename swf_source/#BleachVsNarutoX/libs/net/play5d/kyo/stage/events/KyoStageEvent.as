/**
 * 已重建完成
 */
package net.play5d.kyo.stage.events {
	import flash.events.Event;
	
	import net.play5d.kyo.stage.IStage;
	
	/**
	 * 场景事件
	 */
	public class KyoStageEvent extends Event {
		
		public static const CHANGE_STATE:String = "CHANGE_STATE";
		
		
		public var stage:IStage;
		
		public function KyoStageEvent(type:String, stage:IStage, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.stage = stage;
		}
	}
}
