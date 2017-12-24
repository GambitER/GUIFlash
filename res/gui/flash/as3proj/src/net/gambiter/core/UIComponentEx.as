package net.gambiter.core
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.InteractiveObject;
	
	import net.wg.data.constants.DragType;
	import net.wg.infrastructure.interfaces.entity.IDraggable;
	
	import net.gambiter.FlashUI;
	import net.gambiter.utils.Align;	
	import net.gambiter.core.UIBorderEx;	
	import scaleform.clik.core.UIComponent;
	
	public class UIComponentEx extends UIComponent implements IDraggable
	{
		protected var borderEx:UIBorderEx;
		
		private var _x:Number;
		private var _y:Number;
		private var _autoSize:Boolean;
		private var _alignX:String;
		private var _alignY:String;
		private var _drag:Boolean;
		private var _isDragging:Boolean;
		private var _border:Boolean;
		private var _tooltip:String;
		private var _alias:String;
		private var _index:Number;		
		
		private var _visible:Boolean;
		private var _fullStats:Boolean;
		private var _radialMenu:Boolean;
		
		public function UIComponentEx()
		{
			super();
			
			borderEx = new UIBorderEx();
			addChild(borderEx);
			
			_x = 0;
			_y = 0;
			_drag = false;
			_border = false;
			_autoSize = true;
			_isDragging = false;
			_alignX = Align.LEFT;
			_alignY = Align.TOP;
			
			_visible = true;
			_fullStats = false;
			_radialMenu = false;
			
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
			updateVisible();
			updateIndex();
			updateSize();
			updateBorder();
			updatePosition();
		}
		
		public function updateVisible():void
		{
			super.visible = _visible && (!FlashUI.ui.showFullStats || _fullStats) && (!FlashUI.ui.showRadialMenu || _radialMenu);
			
			FlashUI.ui.py_log(alias, super.visible);
		}
		
		private function updateIndex():void
		{
			if (_index) parent.setChildIndex(this, Math.min(_index, parent.numChildren - 1));
		}
		
		protected function updateSize():void
		{
			null;
		}
		
		protected function updateBorder():void
		{
			null;
		}
		
		private function updatePosition():void
		{
			if (_alignX == Align.LEFT) super.x = Math.round(_x);
			else if (_alignX == Align.CENTER) super.x = Math.round(_x + (parent.width - width) * 0.5);
			else if (_alignX == Align.RIGHT) super.x = Math.round(_x + parent.width - width);
			
			if (_alignY == Align.TOP) super.y = Math.round(_y);
			else if (_alignY == Align.CENTER) super.y = Math.round(_y + (parent.height - height) * 0.5);
			else if (_alignY == Align.BOTTOM) super.y = Math.round(_y + parent.height - height);
		}
		
		private function updateProps():void
		{
			var _x_:Number = _x;
			var _y_:Number = _y;
			
			if (_alignX == Align.LEFT) _x = Math.round(super.x);
			else if (_alignX == Align.CENTER) _x = Math.round(super.x - (parent.width - width) * 0.5);
			else if (_alignX == Align.RIGHT) _x = Math.round(super.x - parent.width + width);
			
			if (_alignY == Align.TOP) _y = Math.round(super.y);
			else if (_alignY == Align.CENTER) _y = Math.round(super.y - (parent.height - height) * 0.5);
			else if (_alignY == Align.BOTTOM) _y = Math.round(super.y - parent.height + height);
			
			if ((_x != _x_) || (_y != _y_)) py_updateProps({"x": _x, "y": _y});
		}
		
		private function py_updateProps(props:Object):void
		{
			FlashUI.ui.py_update(alias, props);
		}
		
		private function onResize(event:Event):void
		{
			refresh();
		}
		
		public function hideCursor():void
		{
			App.toolTipMgr.hide();
			borderEx.hide();
			onEndDrag();
		}
		
		private function onMouseOver(event:MouseEvent):void
		{
			if (!FlashUI.ui.showCursor) return;
			if (_tooltip && !_isDragging) App.toolTipMgr.show(_tooltip);
			if (_border) borderEx.show();
		}
		
		private function onMouseOut(event:MouseEvent):void
		{
			if (_tooltip) App.toolTipMgr.hide();
			if (_border) borderEx.hide();
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
			updateProps();
		}
		
		public function get drag():Boolean
		{
			return _drag;
		}
		
		public function set drag(value:Boolean):void
		{
			if (value != _drag) _drag = value;
		}
		
		public function get tooltip():String
		{
			return _tooltip;
		}
		
		public function set tooltip(value:String):void
		{
			if (value != _tooltip) _tooltip = value;
		}
		
		public function get alias():String
		{
			return _alias;
		}
		
		public function set alias(value:String):void
		{
			if (value != _alias) _alias = value;
		}
		
		public function get border():Boolean
		{
			return _border;
		}
		
		public function set border(value:Boolean):void
		{
			if (value != _border) _border = value;
		}
		
		public function get index():Number
		{
			return _index;
		}
		
		public function set index(value:Number):void
		{
			if (value != _index) _index = value;
		}
		
		public function get alignX():String
		{
			return _alignX;
		}
		
		public function set alignX(value:String):void
		{
			if ((Align.isValidH(value)) && (value != _alignX)) _alignX = value;
		}
		
		public function get alignY():String
		{
			return _alignY;
		}
		
		public function set alignY(value:String):void
		{
			if ((Align.isValidV(value)) && (value != _alignY)) _alignY = value;
		}
		
		public function get autoSize():Boolean
		{
			return _autoSize;
		}
		
		public function set autoSize(value:Boolean):void
		{
			if (value != _autoSize) _autoSize = value;
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
		
		override public function set x(value:Number):void
		{
			_x = value;
		}
		
		override public function set y(value:Number):void
		{
			_y = value;
		}
		
		override public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		public function get fullStats():Boolean
		{
			return _fullStats;
		}
		
		public function set fullStats(value:Boolean):void
		{
			if (value != _fullStats) _fullStats = value;
		}
		
		public function get radialMenu():Boolean
		{
			return _radialMenu;
		}
		
		public function set radialMenu(value:Boolean):void
		{
			if (value != _radialMenu) _radialMenu = value;
		}
	}
}
