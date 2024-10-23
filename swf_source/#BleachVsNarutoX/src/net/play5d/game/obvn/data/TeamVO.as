/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import net.play5d.game.obvn.interfaces.BaseGameSprite;
	import net.play5d.game.obvn.interfaces.IGameSprite;
	
	/**
	 * 队伍值对象
	 */
	public class TeamVO {
		
		public var id:int;
		public var name:String;
		public var children:Vector.<IGameSprite> = new Vector.<IGameSprite>();
		
		public function TeamVO(id:int, name:String = null) {
			this.id = id;
			this.name = name;
		}
		
		public function getAliveChildren():Vector.<IGameSprite> {
			var result:Vector.<IGameSprite> = new Vector.<IGameSprite>();
			
			for each(var sp:IGameSprite in children) {
				if (sp is BaseGameSprite) {
					if ((sp as BaseGameSprite).isAlive) {
						result.push(sp);
					}
				}
				else {
					result.push(sp);
				}
			}
			
			return result;
		}
		
		public function addChild(v:IGameSprite):void {
			var index:int = this.children.indexOf(v);
			if (index == -1) {
				children.push(v);
			}
		}
		
		public function removeChild(v:IGameSprite):void {
			var index:int = this.children.indexOf(v);
			if (index != -1) {
				children.splice(index, 1);
			}
		}
	}
}
