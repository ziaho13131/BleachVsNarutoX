/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	
	/**
	 * 设置按钮线
	 */
	public class SetBtnLine extends Sprite {
		
		private var _txt:TextField;
		private var _line:Sprite;
		
		public function SetBtnLine() {
			mouseChildren = mouseEnabled = false;
			
			_line = new Sprite();
			addChild(_line);
			
			if (GameUI.SHOW_CN_TEXT) {
				_txt = new TextField();
				UIUtils.formatText(_txt, {
					color: 0xFDED65,
					size : 20,
					font : "KaiTi",
					align: TextFormatAlign.RIGHT
				});
				_txt.y = 4;
				addChild(_txt);
			}
		}
		
		public function show(width:Number, text:String):void {
			_line.graphics.clear();
			_line.graphics.lineStyle(1, 0xfded65, 1);
			_line.graphics.lineTo(width, 0);
			
			_line.scaleX = 0.1;
			TweenLite.to(_line, 0.3, {
				scaleX: 1
			});
			
			visible = true;
			if (_txt) {
				_txt.width = width;
				_txt.text = text;
			}
		}
		
		public function hide():void {
			visible = false;
			if (_txt) {
				_txt.text = "";
			}
		}
	}
}
