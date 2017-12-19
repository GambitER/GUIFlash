package net.gambiter.core
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import net.gambiter.utils.Constants;
	import net.gambiter.utils.Properties;
	
	import net.gambiter.FlashUI;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	
	import scaleform.clik.constants.InvalidationType;
	
	import net.wg.data.constants.Errors;
	import net.wg.data.constants.DragType;
	import net.wg.infrastructure.interfaces.entity.IDraggable;
	
	import scaleform.clik.core.UIComponent;
	
    public class UIComponentEx extends UIComponent implements IDraggable
    {
		protected var borderRect:Rectangle;
		private var borderEx : Shape;
		private var _x : Number;
		private var _y : Number;
		private var _alignX : String;
		private var _alignY : String;
		private var _drag : Boolean;
		private var _isDragging : Boolean;
		private var _border : Boolean;
		private var _tooltip : String;
		private var _alias : String;
		private var _index : Number;

		public function UIComponentEx()
        {
            super();

			borderEx = new Shape();
			addChild(borderEx);			
			borderEx.visible = false;
			borderRect = new Rectangle();

			_x = 0;
			_y = 0;

			_drag = false;
			_isDragging = false;

			_alignX = Constants.ALIGN_LEFT;
			_alignY = Constants.ALIGN_TOP;

			focusable = false;	
        }
		
		override protected function configUI():void
		{
			super.configUI();				
			App.cursor.registerDragging(this);
			addEventListener(Event.RESIZE, onResize, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);			
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);			
		}
		
		override protected function onDispose():void
		{
			App.cursor.unRegisterDragging(this);
			removeEventListener(Event.RESIZE, onResize);
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			super.onDispose();
		}
		
		override protected function draw():void
		{
			super.draw();
		}
		
		public function refresh():void
		{			
			updatePosition();					
		}		
		
		protected function updateRect() : void
        {
			borderRect.x = 0;
			borderRect.y = 0;
			borderRect.width = 0;
			borderRect.height = 0;
		}
		
		private function showBorder():void
		{
			updateRect();
			var color:uint = 10066329;			
			borderEx.graphics.clear();
			borderEx.graphics.beginFill(color, 0.1);
			borderEx.graphics.lineStyle(1, color, 1, true);
			borderEx.graphics.moveTo(borderRect.x, borderRect.y);
			borderEx.graphics.lineTo(borderRect.width, borderRect.y);
			borderEx.graphics.lineTo(borderRect.width, borderRect.height);
			borderEx.graphics.lineTo(borderRect.x, borderRect.height);
			borderEx.graphics.lineTo(borderRect.x, borderRect.y);
			borderEx.graphics.endFill();
			borderEx.visible = true;
		}
		
		private function hideBorder():void
		{			
			if (borderEx.visible) borderEx.visible = false;
		}
		
		private function updateIndex():void
		{			
			parent.setChildIndex(this, _index || parent.numChildren - 1);
		}
		
		private function updatePosition():void
		{			
			if (_alignX == Constants.ALIGN_LEFT) super.x = Math.round(_x);
			else if (_alignX == Constants.ALIGN_CENTER) super.x = Math.round(_x + (parent.width - width) * 0.5);
			else if (_alignX == Constants.ALIGN_RIGHT) super.x = Math.round(_x + parent.width - width);
			
			if (_alignY == Constants.ALIGN_TOP) super.y = Math.round(_y);
			else if (_alignY == Constants.ALIGN_CENTER) super.y = Math.round(_y + (parent.height - height) * 0.5);
			else if (_alignY == Constants.ALIGN_BOTTOM) super.y = Math.round(_y + parent.height - height);
		}
		
		private function getPosition():void
		{			
			if (_alignX == Constants.ALIGN_LEFT) _x = Math.round(super.x);
			else if (_alignX == Constants.ALIGN_CENTER) _x = Math.round(super.x - (parent.width - width) * 0.5);
			else if (_alignX == Constants.ALIGN_RIGHT) _x = Math.round(super.x - parent.width + width);
			
			if (_alignY == Constants.ALIGN_TOP) _y = Math.round(super.y);
			else if (_alignY == Constants.ALIGN_CENTER) _y = Math.round(super.y - (parent.height - height) * 0.5);
			else if (_alignY == Constants.ALIGN_BOTTOM) _y = Math.round(super.y - parent.height + height);
		}
		
		private function onResize(event:Event):void
		{			
			refresh();
		}
		
		public function hideCursor() : void
		{
			App.toolTipMgr.hide();
			onEndDrag();
			hideBorder();
		}
		
		private function onMouseOver(event:MouseEvent) : void
		{
			if (!FlashUI.ui.showCursor) return;
			if (_tooltip && !_isDragging) App.toolTipMgr.show(_tooltip);
			if (_border) showBorder();
		}

		private function onMouseOut(event:MouseEvent) : void
		{
			if (_tooltip) App.toolTipMgr.hide();
			hideBorder();
		}
		
		public function getHitArea() : InteractiveObject
        {
            return this;
        }
		
		public function getDragType() : String
        {
            return DragType.SOFT;
        }

		public function onDragging(_x:Number, _y:Number) : void
		{
			null;
		}
		
		public function onStartDrag() : void
        {
			if (!FlashUI.ui.showCursor) return;
			if (!_drag) return;
			_isDragging = true;
			startDrag();							
			App.toolTipMgr.hide();
		}
		
        public function onEndDrag() : void
        {
			if (!_isDragging) return;
			_isDragging = false;	
			stopDrag();			
			getPosition();			
			FlashUI.ui.py_update(_alias, {"x": _x, "y": _y});
		}
		
		public function set drag(value:Boolean):void
		{
			if (_drag != value) _drag = value;
		}
		
		public function get drag():Boolean
		{
			return _drag;
		}
		
		public function set tooltip(value:String) : void
		{
			if (_tooltip != value) _tooltip = value;
		}
		
		public function get tooltip() : String
		{
			return _tooltip;
		}
		
		public function set alias(value:String) : void
		{
			if (_alias != value) _alias = value;
		}
		
		public function get alias() : String
		{
			return _alias;
		}
		
		public function set border(value:Boolean) : void
		{
			if (value != _border) _border = value;
		}
		
		public function get border() : Boolean
		{
			return _border;
		}
		
		public function set index(value:Number) : void
		{
			if (value == _index) return;
			_index = value;
			updateIndex();
		}
		
		public function get index() : Number
		{
			return _index;
		}
		
		public function set alignX(value:String) : void
		{
			if (value != Constants.ALIGN_LEFT && value != Constants.ALIGN_CENTER && value != Constants.ALIGN_RIGHT) return;
			if (_alignX != value) _alignX = value;
		}
		
		public function get alignX() : String
		{
			return _alignX;
		}
		
		public function set alignY(value:String) : void
		{
			if (value != Constants.ALIGN_TOP && value != Constants.ALIGN_CENTER && value != Constants.ALIGN_BOTTOM) return;
			if (alignY != value) _alignY = value;
		}
		
		public function get alignY() : String
		{
			return _alignY;
		}
		
		override public function set width(value:Number) : void
		{
			super.width = value;
			// refresh();
		}
		
		override public function set height(value:Number) : void
		{
			super.height = value;
			// refresh();
		}
		
		override public function set x(value:Number) : void
		{
			_x = value;
		}
		
		override public function set y(value:Number) : void
		{
			_y = value;
		}
    }
}
