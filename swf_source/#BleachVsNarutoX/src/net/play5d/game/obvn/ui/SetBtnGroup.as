/**
 * 已重建完成
 */
package net.play5d.game.obvn.ui {
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	
	import net.play5d.game.obvn.ctrl.GameRender;
	import net.play5d.game.obvn.ctrl.SoundCtrl;
	import net.play5d.game.obvn.data.ConfigVO;
	import net.play5d.game.obvn.data.GameData;
	import net.play5d.game.obvn.event.SetBtnEvent;
	import net.play5d.game.obvn.input.GameInputType;
	import net.play5d.game.obvn.input.GameInputer;
	import net.play5d.game.obvn.interfaces.GameInterface;
	import net.play5d.game.obvn.utils.ResUtils;
	
	/**
	 * 设置按钮组类
	 */
	public class SetBtnGroup extends Sprite {
		
		public var keyEnable:Boolean = true;
		
		public var startX:Number = 100;
		public var startY:Number = 50;
		public var endY:Number = 0;
		
		public var gap:Number = 75;
		public var direct:int = 1;
		
		public var gameInputType:String = GameInputType.MENU;
		
		private var _btns:Vector.<SetBtn>;
		private var _arrow:MovieClip;
		private var _arrowIndex:int = -1;
		private var _scrollRect:Rectangle;
		
		public function initScroll(W:Number, H:Number):void {
			_scrollRect = new Rectangle(0, 0, W, H);
			scrollRect = _scrollRect;
		}
		
		public function initMainSet():void {
			initMainBtns();
			initArrow();
			
			GameRender.add(render, this);
			
			GameInputer.focus();
			GameInputer.enabled = true;
		}
		
		public function initKeySet():void {
			setBtnData([{
				label: "SET ALL",
				cn   : "设置全部"
			}, {
				label: "SET DEFAULT",
				cn   : "还原默认按键"
			}, {
				label: "APPLY",
				cn   : "应用"
			}, {
				label: "CANCEL",
				cn   : "取消"
			}]);
		}
		
		public function setBtnData(v:Array, defaultSelect:int = 0):void {
			_btns = new Vector.<SetBtn>();
			
			for (var i:int = 0; i < v.length; i++) {
				var o:Object = v[i];
				var btn:SetBtn = addBtn(o.label, o.cn, o.options);
				
				if (o.optoinKey != undefined) {
					btn.optionKey = o.optoinKey;
				}
				if (o.optionValue != undefined) {
					btn.setOptionByValue(o.optionValue);
				}
			}
			
			initArrow(defaultSelect);
			
			GameRender.add(render, this);
			GameInputer.focus();
			GameInputer.enabled = true;
		}
		
		public function destory():void {
			if (_btns) {
				for each(var b:SetBtn in _btns) {
					b.destory();
					b.removeEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
					b.removeEventListener(MouseEvent.CLICK, mouseHandler);
					b.removeEventListener(SetBtnEvent.OPTION_CHANGE, onChangeOption);
					b.removeEventListener(SetBtnEvent.SELECT, onSelect);
				}
				_btns = null;
			}
			
			GameRender.remove(render, this);
		}
		
		private function initMainBtns():void {
			_btns = new Vector.<SetBtn>();
			
			var settingMenu:Array = GameInterface.instance.getSettingMenu();
			if (!settingMenu) {
				settingMenu = [{
					txt: "P1 KEY SET",
					cn : "玩家1 按键设置"
				}, {
					txt: "P2 KEY SET",
					cn : "玩家2 按键设置"
				}, {
					txt      : "COM LEVEL",
					cn       : "电脑等级",
					options  : [{
						label: "VERY EASY",
						cn   : "非常简单",
						value: 1
					}, {
						label: "EASY",
						cn   : "简单",
						value: 2
					}, {
						label: "NORMAL",
						cn   : "正常",
						value: 3
					}, {
						label: "HARD",
						cn   : "困难",
						value: 4
					}, {
						label: "VERY HARD",
						cn   : "非常困难",
						value: 5
					}, {
						label: "HELL",
						cn   : "地狱",
						value: 6
					}
					],
					optoinKey: "AI_level"
				}, {
					txt      : "OPERATE MODE",
					cn       : "按键操作模式",
					options  : [{
						label: "NORMAL",
						cn   : "正常模式",
						value: 0
					}, {
						label: "CLASSIC",
						cn   : "经典模式",
						value: 1
					}
					],
					optoinKey: "keyInputMode"
				}, {
					txt      : "LIFE",
					cn       : "生命值",
					options  : [{
						label: "50%",
						cn   : "50%",
						value: 0.5
					}, {
						label: "100%",
						cn   : "100%",
						value: 1
					}, {
						label: "200%",
						cn   : "200%",
						value: 2
					}, {
						label: "300%",
						cn   : "300%",
						value: 3
					}, {
						label: "500%",
						cn   : "500%",
						value: 5
					}
					],
					optoinKey: "fighterHP"
				}, {
					txt      : "TIME",
					cn       : "对战时间",
					options  : [{
						label: "30s",
						cn   : "30秒",
						value: 30
					}, {
						label: "60s",
						cn   : "60秒",
						value: 60
					}, {
						label: "90s",
						cn   : "90秒",
						value: 90
					}, {
						label: "∞",
						cn   : "无限制",
						value: -1
					}
					],
					optoinKey: "fightTime"
				}, {
					txt      : "SOUND",
					cn       : "游戏音效",
					options  : [{
						label: "0%",
						cn   : "0%",
						value: 0
					}, {
						label: "10%",
						cn   : "10%",
						value: 0.1
					}, {
						label: "30%",
						cn   : "30%",
						value: 0.3
					}, {
						label: "50%",
						cn   : "50%",
						value: 0.5
					}, {
						label: "70%",
						cn   : "70%",
						value: 0.7
					}, {
						label: "100%",
						cn   : "100%",
						value: 1
					}
					],
					optoinKey: "soundVolume"
				}, {
					txt      : "BGM",
					cn       : "背景音乐",
					options  : [{
						label: "0%",
						cn   : "0%",
						value: 0
					}, {
						label: "10%",
						cn   : "10%",
						value: 0.1
					}, {
						label: "30%",
						cn   : "30%",
						value: 0.3
					}, {
						label: "50%",
						cn   : "50%",
						value: 0.5
					}, {
						label: "70%",
						cn   : "70%",
						value: 0.7
					}, {
						label: "100%",
						cn   : "100%",
						value: 1
					}
					],
					optoinKey: "bgmVolume"
				}, {
					txt      : "QUALITY",
					cn       : "画质等级",
					options  : [{
						label: "LOW",
						cn   : "低",
						value: "low"
					}, {
						label: "MEDIUM",
						cn   : "中",
						value: "medium"
					}, {
						label: "HIGH",
						cn   : "高",
						value: "high"
					}, {
						label: "BEST",
						cn   : "最高",
						value: "best"
					}
					],
					optoinKey: "quality"
				}];
			}
			
			var config:ConfigVO = GameData.I.config;
			for (var i:int = 0; i < settingMenu.length; i++) {
				var o:Object = settingMenu[i];
				var btn:SetBtn = addBtn(o.txt, o.cn, o.options);
				
				if (o.select) {
					btn.onSelect = o.select;
				}
				
				btn.optionKey = o.optoinKey;
				if (btn.optionKey) {
					btn.setOptionByValue(config.getValueByKey(btn.optionKey));
				}
			}
			
			addBtn("APPLY", "应用");
		}
		
		private function addBtn(label:String, cn:String, options:Array = null):SetBtn {
			var btn:SetBtn = new SetBtn(label, cn);
			btn.addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			btn.addEventListener(MouseEvent.CLICK, mouseHandler);
			
			switch (direct) {
				case 0:
					btn.x = startX + gap * _btns.length;
					btn.y = startY;
					break;
				case 1:
					btn.x = startX;
					btn.y = startY + gap * _btns.length;
			}
			
			addChild(btn);
			if (options) {
				btn.setOption(options);
				btn.addEventListener(SetBtnEvent.OPTION_CHANGE, onChangeOption);
			}
			else {
				btn.addEventListener(SetBtnEvent.SELECT, onSelect);
			}
			
			_btns.push(btn);
			return btn;
		}
		
//		private function touchHandler(e:TouchEvent):void {
//			if (!keyEnable) {
//				return;
//			}
//
//			var btn:SetBtn = e.currentTarget as SetBtn;
//			var index:int = _btns.indexOf(btn);
//			if (index == -1) {
//				return;
//			}
//
//			var option:Object = btn.getOption();
//			if (index == _arrowIndex) {
//				if (option) {
//					btn.nextOption();
//				}
//				else {
//					btn.select();
//				}
//				return;
//			}
//
//			setArrowIndex(index, true);
//		}
		
		private function mouseHandler(e:MouseEvent):void {
			var index:int = 0;
			if (!keyEnable) {
				return;
			}
			
			var btn:SetBtn = e.currentTarget as SetBtn;
			loop0:
			switch (e.type) {
				case MouseEvent.MOUSE_OVER:
					index = _btns.indexOf(btn);
					if (index != -1) {
						setArrowIndex(index);
						break;
					}
					break;
				case MouseEvent.CLICK:
					if (btn.getOption() == null) {
						btn.select();
						break;
					}
					if (e.target) {
						switch (e.target.name) {
							case "prevArrow":
								btn.prevOption();
								break loop0;
							case "nextArrow":
								btn.nextOption();
						}
					}
					break;
			}
		}
		
		private function initArrow(index:int = 0):void {
			_arrow = ResUtils.I.createDisplayObject(ResUtils.I.common_ui, "select_arrow_mc");
			addChild(_arrow);
			
			setArrowIndex(index);
		}
		
		public function setArrowIndex(id:int, sound:Boolean = true):void {
			if (_arrowIndex == id) {
				return;
			}
			if (id < 0) {
				id = _btns.length - 1;
			}
			if (id > _btns.length - 1) {
				id = 0;
			}
			
			var btn:SetBtn = _btns[id] as SetBtn;
			_arrowIndex = id;
			_arrow.x = btn.x - 10;
			_arrow.y = btn.y + 15;
			_btns.every(function (item:SetBtn, i:int, v:Vector.<SetBtn>):Boolean {
				if (btn == item) {
					item.hover();
				}
				else {
					item.hoverOut();
				}
				return true;
			});
			if (sound) {
				SoundCtrl.I.sndSelect();
			}
			
			moveScroll();
		}
		
		private function moveScroll():void {
			if (!_scrollRect) {
				return;
			}
			
			if (direct == 1) {
				if (_btns.length < 8) {
					return;
				}
				
				var H:Number = endY != 0 ? endY : _scrollRect.height;
				var H2:Number = this.height;
				if (H2 < H) {
					return;
				}
				
				var H3:Number = H - startY;
				var step:Number = H3 / _btns.length;
				var offsetY:Number = -_arrowIndex * (step - gap);
				
				TweenLite.to(_scrollRect, 0.2, {
					y       : offsetY,
					onUpdate: updateScroll
				});
			}
		}
		
		private function updateScroll():void {
			scrollRect = _scrollRect;
		}
		
		private function render():void {
			if (!keyEnable) {
				return;
			}
			if (!_btns || _btns.length < 1) {
				return;
			}
			
			var btn:SetBtn = _btns[_arrowIndex];
			if (GameInputer.up(gameInputType, 1)) {
				if (direct == 1) {
					setArrowIndex(_arrowIndex - 1);
				}
			}
			if (GameInputer.down(gameInputType, 1)) {
				if (direct == 1) {
					setArrowIndex(_arrowIndex + 1);
				}
			}
			if (GameInputer.left(gameInputType, 1)) {
				if (direct == 0) {
					setArrowIndex(_arrowIndex - 1);
				}
				if (direct == 1) {
					btn.prevOption();
				}
			}
			if (GameInputer.right(gameInputType, 1)) {
				if (direct == 0) {
					setArrowIndex(_arrowIndex + 1);
				}
				if (direct == 1) {
					btn.nextOption();
				}
			}

//			if (GameInputer.select(gameInputType, 1)) {
			if (GameInputer.attack(gameInputType, 1)) {
				btn.select();
			}
		}
		
		private function onChangeOption(e:SetBtnEvent):void {
			dispatchEvent(e.newEvent());
		}
		
		private function onSelect(e:SetBtnEvent):void {
			var btn:SetBtn = e.currentTarget as SetBtn;
			if (btn.onSelect != null) {
				btn.onSelect();
			}
			
			dispatchEvent(e.newEvent());
		}
	}
}
