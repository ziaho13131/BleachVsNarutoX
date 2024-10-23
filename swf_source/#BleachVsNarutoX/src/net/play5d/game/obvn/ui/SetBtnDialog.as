/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.utils.ResUtils;
	import net.play5d.kyo.display.bitmap.BitmapFontText;
	
	import flash.display.MovieClip;
	
	/**
	 * 设置按钮对话框类
	 */
	public class SetBtnDialog {
		
		public var ui:MovieClip;
		
		public var isShow:Boolean = true;
		
		private var _pushTxt:BitmapFontText;
		private var _keyNameTxt:BitmapFontText;
		
		private var _cntxt:TextField;
		
		public function SetBtnDialog() {
			ui = ResUtils.I.createDisplayObject(ResUtils.I.setting, "key_set_dialog_mc");
			ui.visible = false;
			
			_pushTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
			_keyNameTxt = new BitmapFontText(AssetManager.I.getFont("font1"));
			
			_keyNameTxt.y = -30;
			_pushTxt.y = -30;
			_pushTxt.text = "PUSH A KEY FOR";
			_pushTxt.x = -_pushTxt.width / 2;
			
			ui.ct_msg.addChild(_pushTxt);
			ui.ct_keyname.addChild(_keyNameTxt);
			
			_cntxt = ui.txt;
			_cntxt.defaultTextFormat = new TextFormat("KaiTi", 20);
		}
		
		public function show(name:String, cn:String):void {
			ui.visible = true;
			
			_keyNameTxt.text = name;
			_keyNameTxt.x = -_keyNameTxt.width / 2;
			
			_cntxt.text = "请按下一个键设置【" + cn + "】";
			isShow = true;
		}
		
		public function hide():void {
			ui.visible = false;
			isShow = false;
		}
	}
}
