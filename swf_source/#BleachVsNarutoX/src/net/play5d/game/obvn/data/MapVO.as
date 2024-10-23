/**
 * 已重建完成
 */
package net.play5d.game.obvn.data {
	
	/**
	 * 地图值对象
	 */
	public class MapVO {
		
		public var id:String;
		public var name:String;
		public var fileUrl:String;
		public var picUrl:String;
		public var bgm:String;
		
		public function initByXML(xml:XML):void {
			id = xml.@id;
			name = xml.@name;
			fileUrl = xml.file.@url;
			picUrl = xml.img.@url;
			bgm = xml.bgm.@url;
		}
	}
}
