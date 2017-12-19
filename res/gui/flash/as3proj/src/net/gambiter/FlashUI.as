package net.gambiter
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	import net.wg.infrastructure.base.AbstractView;
	import net.wg.gui.components.containers.MainViewContainer;	
	import net.wg.infrastructure.managers.impl.ContainerManagerBase;
	import net.wg.data.constants.ContainerTypes;

	import net.gambiter.utils.Properties;
	import net.gambiter.utils.Components;
    
	public class FlashUI extends AbstractView
	{
		public static var ui:FlashUI = null;
		
		private var viewContainer:MainViewContainer = null;
		
		private var viewPage:DisplayObjectContainer = null;
		
		public var py_update:Function;
		
		public var py_log:Function;
		
		private var components:Object = null;
		
		public var showCursor:Boolean = false;
		
		public var showFullStats:Boolean = false;
		
		public var showRadialMenu:Boolean = false;
        
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
		}
		
		override protected function onPopulate() : void
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

		override protected function onDispose() : void
        {
			super.onDispose();
        }
		
		public function as_cursor(arg:Boolean) : void
		{
			if (arg != showCursor) showCursor = arg;
			if (showCursor) null; // Проверить пересечение курсора с компонентами. App.cursor.loader.hitTestObject App.cursor.loader.hitTestPoint
			else for (var alias:String in components) components[alias].hideCursor();
		}
		
		public function as_fullStats(arg:Boolean) : void
		{
			if (arg != showFullStats) showFullStats = arg;
			for (var alias:String in components) components[alias].visible = !(showFullStats || showRadialMenu);
		}
		
		public function as_radialMenu(arg:Boolean) : void
		{
			if (arg != showRadialMenu) showRadialMenu = arg;
			for (var alias:String in components) components[alias].visible = !(showFullStats || showRadialMenu);
		}
		
		public function as_create(alias:String, type:String, props:Object) : void		
        {
			try
			{
				if (viewPage) this.createComponent(alias, type, props);
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
        }
		
		public function as_update(alias:String, props:Object) : void		
        {
			try
			{
				if (viewPage) this.updateComponent(alias, props);
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
        }
        
        public function as_delete(alias:String) : void
        {
			try
			{
				if (viewPage) this.deleteComponent(alias);
			}
			catch (error:Error)
			{
				py_log(error.getStackTrace());
			}
        }
		
		private function createComponent(alias:String, type:String, props:Object) : void
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
		
		private function updateComponent(alias:String, props:Object) : void
        {
			if (components.hasOwnProperty(alias)) Properties.setProperty(components[alias], props);
			else Properties.setProperty(Properties.getComponentByPath(viewPage, alias.split(".")), props);
        }
        
        private function deleteComponent(alias:String) : void
        {
			if (components.hasOwnProperty(alias))
			{
				components[alias].parent.removeChild(components[alias]);
				delete components[alias];
			}
        }
	}
}