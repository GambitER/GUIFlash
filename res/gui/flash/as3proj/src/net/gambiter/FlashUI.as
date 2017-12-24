package net.gambiter
{
	import flash.display.DisplayObjectContainer;
	
	import net.gambiter.utils.Components;
	import net.gambiter.utils.Properties;
	
	import net.wg.infrastructure.managers.impl.ContainerManagerBase;
	import net.wg.gui.components.containers.MainViewContainer;
	import net.wg.data.constants.ContainerTypes;
	import net.wg.infrastructure.base.AbstractView;
	
	public class FlashUI extends AbstractView
	{
		public static var ui:FlashUI;
		
		public var py_log:Function;
		public var py_update:Function;
		
		public var showCursor:Boolean;
		public var showFullStats:Boolean;
		public var showRadialMenu:Boolean;
		
		private var viewContainer:MainViewContainer;
		private var viewPage:DisplayObjectContainer;
		
		private var components:Object;
		
		public function FlashUI()
		{
			super();
			
			ui = this;
			components = {};
		}
		
		override protected function configUI():void
		{
			super.configUI();
			
			visible = false;
			focusable = false;
			tabEnabled = false;
			tabChildren = false;
			mouseEnabled = false;
			
			showCursor = false;
			showFullStats = false;
			showRadialMenu = false;
		}
		
		override protected function onPopulate():void
		{
			super.onPopulate();
			
			try
			{
				parent.removeChild(this);
				viewContainer = (App.containerMgr as ContainerManagerBase).containersMap[ContainerTypes.VIEW];
				viewContainer.setFocusedView(viewContainer.getTopmostView());
				viewPage = viewContainer.getChildByName("main") as DisplayObjectContainer;
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
		}
		
		override protected function onDispose():void
		{
			super.onDispose();
		}
		
		public function as_cursor(arg:Boolean):void
		{
			if (arg != showCursor) showCursor = arg;
			if (showCursor) null; // App.cursor.loader.hitTestObject / App.cursor.loader.hitTestPoint
			else
				for (var alias:String in components) components[alias].hideCursor();
		}
		
		public function as_fullStats(arg:Boolean):void
		{
			if (arg != showFullStats) showFullStats = arg;
			for (var alias:String in components) components[alias].updateVisible();
		}
		
		public function as_radialMenu(arg:Boolean):void
		{
			if (arg != showRadialMenu) showRadialMenu = arg;
			for (var alias:String in components) components[alias].updateVisible();
		}
		
		public function as_create(alias:String, type:String, props:Object):void
		{
			if (viewPage) this.createComponent(alias, type, props);
		}
		
		public function as_update(alias:String, props:Object):void
		{
			if (viewPage) this.updateComponent(alias, props);
		}
		
		public function as_delete(alias:String):void
		{
			if (viewPage) this.deleteComponent(alias);
		}
		
		private function createComponent(alias:String, type:String, props:Object):void
		{
			try
			{
				var _path:Array = alias.split(".");
				var _name:String = _path.pop();
				var _container:DisplayObjectContainer = Properties.getComponentByPath(viewPage, _path) as DisplayObjectContainer;
				
				if (!components.hasOwnProperty(alias) && _container && !_container.getChildByName(_name))
				{
					components[alias] = Components.getClass(type);
					components[alias].name = _name;
					components[alias].alias = alias;
					_container.addChild(components[alias]);
					Properties.setProperty(components[alias], props);
				}
				else py_log("Error creating component '" + _name + "' (" + alias + ")!");
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
		}
		
		private function updateComponent(alias:String, props:Object):void
		{
			try
			{
				if (components.hasOwnProperty(alias)) Properties.setProperty(components[alias], props);
				else Properties.setProperty(Properties.getComponentByPath(viewPage, alias.split(".")), props);
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
		}
		
		private function deleteComponent(alias:String):void
		{
			try
			{
				if (components.hasOwnProperty(alias))
				{
					components[alias].parent.removeChild(components[alias]);
					delete components[alias];
				}
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
		}
	}
}