/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui.fight {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	import net.play5d.game.obvn.ctrl.AssetManager;
	import net.play5d.game.obvn.fighter.Assister;
	import net.play5d.game.obvn.fighter.FighterMain;
	import net.play5d.game.obvn.ui.GameUI;
	import net.play5d.kyo.utils.KyoUtils;
	
	/**
	 * 气条类
	 */
	public class QiBar {
		
		private var _ui             :MovieClip;
		
		private var _fighter        :FighterMain;
		
		private var _bar            :InsBar;
		private var _fzBar          :InsFzBar;
		
		private var _fzReadyMc      :MovieClip;
		private var _spMc           :MovieClip;
		
		private var _qiRate         :Number  = 0;
		private var _fzRate         :Number  = 0;
		private var _orgPose        :Point;
		private var _tweenSpd       :Number  = 0.5;
		private var _moveFin        :Boolean = true;
		private var _moveType       :int     = 0;
		private var _isFadIn        :Boolean;
		private var _isRenderAnimate:Boolean;
		
		private var _faceBp:Bitmap;
		
		public function QiBar(ui:MovieClip) {
			_ui        = ui;
			_bar       = new InsBar(_ui.barmc);
			_fzBar     = new InsFzBar(_ui.fzqibar);
			_fzReadyMc = _ui.readymc;
			_spMc      = _ui.fzqibar.sp;
			_orgPose   = new Point(_ui.x, _ui.y);
			
			_ui.addEventListener(Event.COMPLETE, uiPlayComplete);
			if (GameUI.BITMAP_UI) {
				_ui.gotoAndStop("fadin_fin");
				_ui.visible = false;
			}
		}
		
		public function destory():void {
			if (_ui) {
				_ui.removeEventListener("complete", uiPlayComplete);
				_ui.gotoAndStop("destory");
				_ui = null;
			}
			if (_faceBp) {
				_faceBp.bitmapData.dispose();
				_faceBp = null;
			}
			_fighter = null;
		}
		
		private function uiPlayComplete(e:Event):void {
			if (_isFadIn) {
				_ui.visible = true;
				setCacheBitmap(true);
			}
			else {
				_ui.visible = false;
			}
		}
		
		public function setFighter(fighter:FighterMain, fuzhu:Assister = null):void {
			_fighter = fighter;
			
			if (fuzhu && fuzhu.data) {
				var face:DisplayObject = AssetManager.I.getFighterFace(fuzhu.data);
				if (face) {
					_ui.facemc.ct.addChild(face);
				}
			}
			
			if (GameUI.BITMAP_UI) {
				_faceBp = KyoUtils.drawDisplay(_ui.facemc);
				_faceBp.x = _ui.facemc.x;
				_faceBp.y = _ui.facemc.y;
				
				_ui.addChild(_faceBp);
				try {
					_ui.removeChild(_ui.facemc);
				}
				catch (e:Error) {
				}
				
				_ui.addChild(_ui.readymc);
			}
		}
		
		private function setCacheBitmap(v:Boolean):void {
			if (GameUI.BITMAP_UI) {
				return;
			}
			
			_ui.facemc.cacheAsBitmap = v;
		}
		
		public function setDirect(v:int):void {
			_bar.setDirect(v);
			_fzReadyMc.mc.scaleX = v > 0 ? 1 : -1;
		}
		
		public function render():void {
			_qiRate = _fighter.qi / 100;
			
			if (_qiRate > 3) {
				_qiRate = 3;
			}
			
			////////////////////////////////////////////////////////////
			/*
			var curQiProc:Number = _bar.getProcess();
			var diff:Number = _qiRate - curQiProc;
			
			if (Math.abs(diff) < 0.01) {
				_bar.setProcess(_qiRate);
			}
			else {
				_bar.setProcess(curQiProc + diff * 0.4);
			}
			*/
			
			_bar.setProcess(_qiRate);
			
			////////////////////////////////////////////////////////////
			
			_fzBar.setProcess(_fighter.fzqi / 100);
			
			var fzVisible:Boolean = _fzBar.getProcess() >= 1;
			if (_fzReadyMc.visible != fzVisible) {
				_fzReadyMc.visible = fzVisible;
				
				if (fzVisible) {
					_fzReadyMc.mc.play();
				}
				else {
					_fzReadyMc.mc.gotoAndStop(1);
				}
			}
			
			var isCanHurtBreak:Boolean = _fighter.getCtrler().getMcCtrl().isCanHurtBreak();
			if (_spMc && _spMc.visible != isCanHurtBreak) {
				_spMc.visible = isCanHurtBreak;
			}
		}
		
		public function renderAnimate():void {
			if (!_isRenderAnimate) {
				return;
			}
			
			var curFrame:String = String(_ui.currentFrameLabel);
			if (curFrame == "fadin_fin" || curFrame == "fadout_fin") {
				_isRenderAnimate = false;
				return;
			}
			
			_ui.nextFrame();
		}
		
		public function fadIn(animate:Boolean = true):void {
			if (_isFadIn) {
				return;
			}
			
			_isFadIn = true;
			_ui.visible = true;
			
			if (GameUI.BITMAP_UI) {
				return;
			}
			
			if (animate) {
				setCacheBitmap(false);
				_ui.gotoAndStop("fadin");
				_isRenderAnimate = true;
			}
			else {
				_ui.gotoAndStop("fadin_fin");
				setCacheBitmap(true);
			}
		}
		
		public function fadOut(animate:Boolean = true):void {
			if (!_isFadIn) {
				return;
			}
			
			_isFadIn = false;
			if (GameUI.BITMAP_UI) {
				_ui.visible = false;
				return;
			}
			
			if (animate) {
				_ui.gotoAndStop("fadout");
				_isRenderAnimate = true;
				setCacheBitmap(false);
			}
			else {
				_ui.visible = false;
			}
		}
		
//		public function moveTo(x:Number, y:Number, scale:Number):void {
//			if (_moveType == 1) {
//				if (_moveFin) {
//					return;
//				}
//			}
//			else {
//				_moveType = 1;
//				_moveFin = false;
//			}
//
//			moving(x, y, scale);
//		}
//
//		public function moveResume():void {
//			if (_moveType == 0) {
//				if (_moveFin) {
//					return;
//				}
//			}
//			else {
//				_moveType = 0;
//				_moveFin = false;
//			}
//			moving(_orgPose.x, _orgPose.y, 1);
//		}
		
		private function moving(x:Number, y:Number, scale:Number):void {
			if (Math.abs(x - _ui.x) < 2 && Math.abs(y - _ui.y) < 2 && Math.abs(scale - _ui.scaleX) < 0.2) {
				_ui.x = x;
				_ui.y = y;
				_ui.scaleX = _ui.scaleY = scale;
				_moveFin = true;
			}
			
			_ui.x += (x - _ui.x) * _tweenSpd;
			_ui.y += (y - _ui.y) * _tweenSpd;
			_ui.scaleX += (scale - _ui.scaleX) * _tweenSpd;
			_ui.scaleY = _ui.scaleX;
		}
		
		public function setPosAndScale(x:Number, y:Number, scale:Number):void {
			_ui.x = x;
			_ui.y = y;
			_ui.scaleX = scale;
			_ui.scaleY = scale;
		}
	}
}

import flash.display.DisplayObject;
import flash.display.MovieClip;

/**
 * 内部条类
 */
class InsBar {
	
	private var _ui:MovieClip;
	private var _process:Number = 0;
	
	public function InsBar(ui:MovieClip) {
		_ui = ui;
		setProcess(0);
	}
	
	public function get ui():DisplayObject {
		return _ui;
	}
	
//	public function getProcess():Number {
//		return _process;
//	}
	
	public function setProcess(v:Number):void {
		_process = v;
		_ui.bar.bar1.visible = v > 0;
		_ui.bar.bar2.visible = v > 1;
		_ui.bar.bar3.visible = v > 2;
		_ui.bar.bar4.visible = v >= 3;
		
		if (v > 2) {
			_ui.bar.bar2.scaleX = 1;
			_ui.bar.bar1.scaleX = 1;
			_ui.bar.bar3.scaleX = v - 2;
		}
		else if (v > 1) {
			_ui.bar.bar1.scaleX = 1;
			_ui.bar.bar2.scaleX = v - 1;
		}
		else {
			_ui.bar.bar1.scaleX = v;
		}
		
		var frame:int = int(v) + 1;
		_ui.txtmc.gotoAndStop(frame);
	}
	
	public function setDirect(v:int):void {
		_ui.txtmc.scaleX = v > 0 ? 1 : -1;
	}
}

import flash.display.DisplayObject;
import flash.geom.Rectangle;

/**
 * 内部辅助条类
 */
class InsFzBar {
	
	private var _ui:MovieClip;
	
	private var _process:Number = 0;
	private var _scroll:Rectangle;
	private var _height:Number;
	
	public function InsFzBar(ui:MovieClip) {
		_ui = ui;
//		var bounds:Rectangle = _ui.barmc.getBounds(_ui.barmc);
		_scroll = new Rectangle(0, 0, _ui.barmc.width, _ui.barmc.height);
		_height = _scroll.height;
		_ui.barmc.scaleY = -1;
		_ui.barmc.y = _ui.barmc.height;
	}
	
	public function get ui():DisplayObject {
		return _ui;
	}
	
	public function getProcess():Number {
		return _process;
	}
	
	public function setProcess(v:Number):void {
		_process = v;
		_scroll.height = v * _height;
		_ui.barmc.scrollRect = _scroll;
	}
}
