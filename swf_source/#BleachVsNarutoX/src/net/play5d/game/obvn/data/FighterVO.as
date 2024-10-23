/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	import net.play5d.kyo.utils.KyoRandom;
	
	/**
	 * 人物值对象
	 */
	public class FighterVO {
		
		public var id:String;
		public var name:String;
		public var comicType:int;
		public var fileUrl:String;
		public var startFrame:int;
		public var faceCls:String;
		public var faceBigCls:String;
		public var faceBarCls:String;
		public var faceWinCls:String;
		public var says:Array;
		public var bgm:String;
		public var bgmRate:Number = 1;
		
		private var _cloneKey:Array = [
			"id", "name", "comicType", 
			"fileUrl", "startFrame", "faceCls", "says", "faceBigCls", "faceBarCls", 
			"bgm", "bgmRate"
		];
		
		public function initByXML(xml:XML):void {
			id = xml.@id;
			name = xml.@name;
			comicType = int(xml.@comic_type);
			fileUrl = xml.file.@url;
			startFrame = int(xml.file.@startFrame);
			faceCls = xml.face.@cls;
			faceBigCls = xml.face.@big_cls;
			faceBarCls = xml.face.@bar_cls;
			faceWinCls = xml.face.@win_cls;
			bgm = xml.bgm.@url;
			bgmRate = Number(xml.bgm.@rate) / 100;
			says = [];
			
			for each(var i:XML in xml.says.say_item) {
				says.push(i.children().toString());
			}
			
			if (startFrame != 0 && !bgm) {
				trace(id + " : not define BGM!");
			}
		}
		
		public function getRandSay():String {
			return KyoRandom.getRandomInArray(says);
		}
		
		public function clone():FighterVO {
			var fv:FighterVO = new FighterVO();
			
			for each (var i:String in _cloneKey) {
				fv[i] = this[i];
			}
			
			return fv;
		}
	}
}
