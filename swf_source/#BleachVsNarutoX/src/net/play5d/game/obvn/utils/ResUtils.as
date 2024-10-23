/**
 * 已重建完成
 */
package net.play5d.game.obvn.utils {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import net.play5d.game.obvn.data.GameData;
	
	/**
	 * 自身资源管理工具
	 */
	public class ResUtils {
		
		private static var _i:ResUtils;
		
		public static var SETTING        :String = "stg_set_ui";
		public static var CONGRATULATIONS:String = "mc_congratulations";
		public static var WINNER         :String = "winner_stg_mc";
		public static var TITLE          :String = "stg_title";
		public static var GAME_OVER      :String = "stg_gameover_mc";
		public static var SELECT         :String = "stg_select";
		
		[Embed(source="/../swfs/common_ui.swf")]
		public var common_ui:Class;
		[Embed(source="/../swfs/fight.swf")]
		public var fight:Class;
		[Embed(source="/../swfs/gameover.swf")]
		public var gameover:Class;
		[Embed(source="/../swfs/howtoplay.swf")]
		public var howtoplay:Class;
		[Embed(source="/../swfs/loading.swf")]
		public var loading:Class;
		[Embed(source="/../swfs/select.swf")]
		public var select:Class;
		[Embed(source="/../swfs/setting.swf")]
		public var setting:Class;
		[Embed(source="/../swfs/title.swf")]
		public var title:Class;
		
		private var _swfPool:Dictionary;
		
		private var _initBack:Function;
		private var _initError:Function;
		
		private var _inited:Boolean;
		private var _initing:Boolean;
		
		public static function get I():ResUtils {
			_i ||= new ResUtils();
			
			return _i;
		}
		
		/**
		 * 初始化
		 */
		public function initalize(back:Function = null, error:Function = null):void {
			if (_initing) {
				throw new Error("Initialization is in progress and cannot be initalized again!");
			}
			if (_inited) {
				if (back != null) {
					back();
				}
				return;
			}
			
			_inited = true;
			_initing = true;
			_swfPool = new Dictionary();
			_initBack = back;
			_initError = error;
			
			var xml:XML = describeType(this);
			for each(var j:XML in xml.variable) {
				var k:String = j.@name;
				var cls:Class = this[k];
				var swf:InsSwf = new InsSwf(cls);
				
				swf.ready = swfReadyBack;
				swf.error = swfErrorBack;
				
				_swfPool[cls] = swf;
			}
		}
		
		private function swfReadyBack(target:InsSwf):void {
			for each(var i:InsSwf in _swfPool) {
				if (!i.isReady) {
					return;
				}
			}
			
			finish();
		}
		
		private function swfErrorBack(msg:String):void {
			if (_initError != null) {
				_initError();
			}
		}
		
		private function finish():void {
			_initing = false;
			
			if (_initBack != null) {
				_initBack();
				_initBack = null;
			}
		}
		
		/**
		 * 创建可视对象
		 * @param embedSwf 嵌入的swf类
		 * @param itemName 要创建的元件链接名
		 */
		public function createDisplayObject(embedSwf:Class, itemName:String):* {
			var cls:Class = getItemClass(embedSwf, itemName);
			if (cls) {
				var d:DisplayObject = new cls();
				if (d is Sprite) {
					var mc:Sprite = d as Sprite;
					var st:SoundTransform = mc.soundTransform;
					st.volume = GameData.I.config.soundVolume;
					mc.soundTransform = st;
					return mc;
				}
				
				return d;
			}
		}
		
		public function createBitmapData(embedSwf:Class, itemName:String, width:int, height:int):BitmapData {
			var cls:Class = getItemClass(embedSwf, itemName);
			if (!cls) {
				return null;
			}
			
			return new cls(width, height);
		}
		
		public function getItemClass(embedSwf:Class, itemName:String):Class {
			if (!_swfPool) {
				throw new Error("Not initialized!");
			}
			
			var swf:InsSwf = _swfPool[embedSwf];
			if (!swf) {
				throw new Error("swf is undefined!");
			}
			
			return swf.getClass(itemName);
		}
	}
}

import flash.compiler.embed.EmbeddedMovieClip;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

/**
 * 内部 SWF 类
 */
class InsSwf {
	
	
	private var _swf:EmbeddedMovieClip;					// 嵌入数据
	private var _domain:ApplicationDomain;				// 可执行域
	
	public var isReady:Boolean;
	
	public var ready:Function;
	public var error:Function;
	
	public function InsSwf(swfClass:Class) {
		_swf = new swfClass();
		var bytes:ByteArray = _swf.movieClipData;
		if (!bytes) {
			error("SWF movieClipData not found!");
			throw new Error("SWF movieClipData not found!");
		}
		
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
		var lc:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		lc.allowCodeImport = true;						// 允许执行代码
		
		loader.loadBytes(bytes, lc);
	}
	
	public function getClass(name:String):Class {
		return _domain.getDefinition(name) as Class;
	}
	
	private function loadComplete(e:Event):void {
		var l:LoaderInfo = e.currentTarget as LoaderInfo;
		_domain = l.applicationDomain;
		isReady = true;
		
		if (ready != null) {
			ready(this);
			ready = null;
		}
	}
}
