package net.gambiter.components
{
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
		public var textField:TextField;
		
		private var _text:String;		
		private var _html:Boolean;		
		private var _hAlign:String;		
		private var _vAlign:String;
        private var _autoSize:Boolean;
		
		public function LabelEx()
		{
			super();
			
			textField = new TextField();			
			addChild(textField);
			
			_html = true;
			_autoSize = true;
			
			_hAlign = Constants.ALIGN_LEFT;
			_vAlign = Constants.ALIGN_TOP;
			
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
		
		override protected function updateRect() : void
        {
			borderRect.x = textField.x;
			borderRect.y = textField.y;
			borderRect.width = textField.width;
			borderRect.height = textField.height;
		}
		
		private function updateText() : void
        {
            if (_text == null || textField == null) return;
            if (_html) textField.htmlText = _text;
			else textField.text = _text;
			updateSize();
        }
		
		private function updateSize() : void
        {
            if (_autoSize)
			{
				
				textField.width = Math.ceil(textField.textWidth + 4);
				textField.height = Math.ceil(textField.textHeight + 2);	
				// Добавить выравнивание по ширине и высоте.
				// if (_align == "left") textField.y = 0;
				// else if (_align == "center") textField.y = Math.round((textField.height - textField.textHeight) * 0.5);
				// else if (_align == "right") textField.y = Math.round(textField.height - textField.textHeight);
				textField.x = 0; // ..
				textField.y = 0; // ..
				
				super.width = textField.width;
				super.height = textField.height;
				
				FlashUI.ui.py_update(alias, {"width": _width, "height": _height});
			}
			else
			{
				textField.x = 0;
				textField.y = 0;
				textField.width = _width;
				textField.height = _height;
			}
        }
				
		public function get text() : String
        {
            return _text;
        }

        public function set text(value:String) : void
        {
            _text = value || "";
			updateText();
        }
		
		public function get html() : Boolean
        {
            return _html;
        }

        public function set html(value:Boolean) : void
        {
            _html = value;
			updateText();
        }
		
		public function get autoSize() : Boolean
        {
            return _autoSize;
        }

        public function set autoSize(value:Boolean) : void
        {
            if (value == _autoSize) return;
            _autoSize = value;
        }
		
		public function get multiline() : Boolean
        {
            return textField.multiline;
        }

        public function set multiline(value:Boolean) : void
        {
            textField.multiline = value;
			updateText();
        }
		
		public function get selectable() : Boolean
        {
            return textField.selectable;
        }

        public function set selectable(value:Boolean) : void
        {
            textField.selectable = value;
			updateText();
        }
		
		public function get condenseWhite() : Boolean
        {
            return textField.condenseWhite;
        }

        public function set condenseWhite(value:Boolean) : void
        {
            textField.condenseWhite = value;
			updateText();
        }
		
		public function set shadow(args:Object):void
		{
			Properties.setShadow(textField, args);
		}
		
		override public function set width(value:Number):void
		{			
			_autoSize = false;
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			_autoSize = false;
			super.height = value;			
		}
	}
}