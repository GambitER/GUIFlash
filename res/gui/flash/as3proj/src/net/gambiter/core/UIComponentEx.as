package net.gambiter.core
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	
	import net.wg.data.constants.DragType;
	import net.wg.infrastructure.interfaces.entity.IDraggable;
	
	import net.gambiter.FlashUI;
	import net.gambiter.utils.Constants;
	
	import scaleform.clik.core.UIComponent;
	
	public class UIComponentEx extends UIComponent implements IDraggable
	{
		private var borderEx:Shape;
		
		private var _x:Number;
		private var _y:Number;
		private var _alignX:String;
		private var _alignY:String;
		private var _drag:Boolean;
		private var _isDragging:Boolean;
		private var _border:Boolean;
		private var _tooltip:String;
		private var _alias:String;
		private var _index:Number;
		
		protected var _rect:Rectangle;
		
		public function UIComponentEx()
		{
			super();
			
			borderEx = new Shape();
			borderEx.visible = false;
			addChild(borderEx);
			
			_rect = new Rectangle();
			
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
		
		protected function updateRect():void
		{
			_rect = getBounds(parent);
			_rect.x = Math.round(_rect.x - x);
			_rect.y = Math.round(_rect.y - y);
			_rect.width = Math.round(_rect.width);
			_rect.height = Math.round(_rect.height);
		}
		
		private function showBorder():void
		{
			borderEx.graphics.clear();
			
			updateRect();
			
			borderEx.graphics.beginFill(0x999999, 0.1);
			borderEx.graphics.lineStyle(1, 0x999999, 1, true);
			borderEx.graphics.drawRect(_rect.x, _rect.y, _rect.width, _rect.height);
			borderEx.graphics.endFill();
			
			borderEx.visible = true;
		}
		
		private function hideBorder():void
		{
			if (borderEx.visible) borderEx.visible = false;
		}
		
		private function updateProps(props:Object):void
		{
			FlashUI.ui.py_update(_alias, props);
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
			var _x_:Number = _x;
			var _y_:Number = _y;
			
			if (_alignX == Constants.ALIGN_LEFT) _x = Math.round(super.x);
			else if (_alignX == Constants.ALIGN_CENTER) _x = Math.round(super.x - (parent.width - width) * 0.5);
			else if (_alignX == Constants.ALIGN_RIGHT) _x = Math.round(super.x - parent.width + width);
			
			if (_alignY == Constants.ALIGN_TOP) _y = Math.round(super.y);
			else if (_alignY == Constants.ALIGN_CENTER) _y = Math.round(super.y - (parent.height - height) * 0.5);
			else if (_alignY == Constants.ALIGN_BOTTOM) _y = Math.round(super.y - parent.height + height);
			
			if ((_x != _x_) || (_y != _y_)) updateProps({"x": _x, "y": _y});
		}
		
		private function onResize(event:Event):void
		{
			refresh();
		}
		
		public function hideCursor():void
		{
			App.toolTipMgr.hide();
			onEndDrag();
			hideBorder();
		}
		
		private function onMouseOver(event:MouseEvent):void
		{
			if (!FlashUI.ui.showCursor) return;
			if (_tooltip && !_isDragging) App.toolTipMgr.show(_tooltip);
			if (_border) showBorder();
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			if (_tooltip) App.toolTipMgr.hide();
			hideBorder();
		}
		
		public function getHitArea():InteractiveObject
		{
			return this;
		}
		
		public function getDragType():String
		{
			return DragType.SOFT;
		}
		
		public function onDragging(_x:Number, _y:Number):void
		{
			null;
		}
		
		public function onStartDrag():void
		{
			if (!FlashUI.ui.showCursor) return;
			if (!_drag) return;
			_isDragging = true;
			startDrag();
			App.toolTipMgr.hide();
		}
		
		public function onEndDrag():void
		{
			if (!_isDragging) return;
			_isDragging = false;
			stopDrag();
			getPosition();
		}
		
		public function set drag(value:Boolean):void
		{
			if (_drag != value) _drag = value;
		}
		
		public function get drag():Boolean
		{
			return _drag;
		}
		
		public function set tooltip(value:String):void
		{
			if (_tooltip != value) _tooltip = value;
		}
		
		public function get tooltip():String
		{
			return _tooltip;
		}
		
		public function set alias(value:String):void
		{
			if (_alias != value) _alias = value;
		}
		
		public function get alias():String
		{
			return _alias;
		}
		
		public function set border(value:Boolean):void
		{
			if (value != _border) _border = value;
		}
		
		public function get border():Boolean
		{
			return _border;
		}
		
		public function set index(value:Number):void
		{
			if (value == _index) return;
			_index = value;
			updateIndex();
		}
		
		public function get index():Number
		{
			return _index;
		}
		
		public function set alignX(value:String):void
		{
			if (value != Constants.ALIGN_LEFT && value != Constants.ALIGN_CENTER && value != Constants.ALIGN_RIGHT) return;
			if (_alignX != value) _alignX = value;
		}
		
		public function get alignX():String
		{
			return _alignX;
		}
		
		public function set alignY(value:String):void
		{
			if (value != Constants.ALIGN_TOP && value != Constants.ALIGN_CENTER && value != Constants.ALIGN_BOTTOM) return;
			if (alignY != value) _alignY = value;
		}
		
		public function get alignY():String
		{
			return _alignY;
		}
		
		override public function set x(value:Number):void
		{
			_x = value;
		}
		
		override public function set y(value:Number):void
		{
			_y = value;
		}
	}
}
