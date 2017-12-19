package net.gambiter.components
{
	import flash.geom.Rectangle;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	
	import scaleform.gfx.TextFieldEx;
	
	import net.gambiter.FlashUI;
	import net.gambiter.utils.Constants;
	import net.gambiter.utils.Properties;
	import net.gambiter.core.UIComponentEx;
	
	public class LabelEx extends UIComponentEx
	{
		private var textField:TextField;
		
		private var _text:String;
		private var _isHtml:Boolean;
		private var _autoSize:Boolean;
		private var _textAlignX:String;
		private var _textAlignY:String;
		
		public function LabelEx()
		{
			super();
			
			textField = new TextField();
			textField.name = "textField";
			addChild(textField);
			
			_isHtml = true;
			_autoSize = true;
			_textAlignX = Constants.ALIGN_LEFT;
			_textAlignY = Constants.ALIGN_TOP;
			
			textField.multiline = false;
			textField.embedFonts = true;
			textField.selectable = false;
			textField.tabEnabled = false;
			textField.mouseEnabled = false;
			textField.condenseWhite = false;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.defaultTextFormat = new TextFormat("$UniversCondC", 12, 0xFFFFFF, false, false, false, "", "", "left", 0, 0, 0, 0);
			Properties.setShadow(textField, {"distance": 4, "angle": 45, "color": 0, "alpha": 1, "blurX": 4, "blurY": 4, "strength": 1, "quality": 1});
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function onDispose():void
		{
			super.onDispose();
		}
		
		override public function refresh():void
		{
			updateSize();
			super.refresh();
		}
		
		override protected function updateRect():void
		{
			_rect.x = 0;
			_rect.y = 0;
			_rect.width = width;
			_rect.height = height;
		}
		
		private function updateText():void
		{
			if (_text == null || textField == null) return;
			if (_isHtml) textField.htmlText = _text;
			else textField.text = _text;
		}
		
		private function updateSize():void
		{
			textField.x = 1;
			textField.y = 1;
			textField.width = _originalWidth;
			textField.height = _originalHeight;
			
			if (_autoSize) textField.autoSize = Constants.ALIGN_LEFT;
			else
			{
				textField.autoSize = _textAlignX;
				TextFieldEx.setVerticalAlign(textField, _textAlignY);
			}			
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			_text = value || "";
			updateText();
		}
		
		public function get isHtml():Boolean
		{
			return _isHtml;
		}
		
		public function set isHtml(value:Boolean):void
		{
			_isHtml = value;
			updateText();
		}
		
		public function get autoSize():Boolean
		{
			return _autoSize;
		}
		
		public function set autoSize(value:Boolean):void
		{
			if (value == _autoSize) return;
			_autoSize = value;
		}
		
		public function get textAlignX():String
		{
			return _textAlignX;
		}
		
		public function set textAlignX(value:String):void
		{
			if (value == _textAlignX) return;
			_textAlignX = value;
		}
		
		public function get textAlignY():String
		{
			return _textAlignY;
		}
		
		public function set textAlignY(value:String):void
		{
			if (value == _textAlignY) return;
			_textAlignY = value;
		}
		
		public function get multiline():Boolean
		{
			return textField.multiline;
		}
		
		public function set multiline(value:Boolean):void
		{
			if (value == textField.multiline) return;
			textField.multiline = value;
		}
		
		public function get selectable():Boolean
		{
			return textField.selectable;
		}
		
		public function set selectable(value:Boolean):void
		{
			if (value == textField.selectable) return;
			textField.selectable = value;
		}
		
		public function get condenseWhite():Boolean
		{
			return textField.condenseWhite;
		}
		
		public function set condenseWhite(value:Boolean):void
		{
			if (value == textField.condenseWhite) return;
			textField.condenseWhite = value;
		}
		
		public function set shadow(args:Object):void
		{
			Properties.setShadow(textField, args);
		}
		
		override public function set width(value:Number):void
		{
			_autoSize = false;
			_originalWidth = value;
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			_autoSize = false;
			_originalHeight = value;
			super.height = value;
		}
	}
}