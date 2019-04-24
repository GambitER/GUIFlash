package net.gambiter
{
	import flash.display.DisplayObjectContainer;
	
	import net.gambiter.utils.Components;
	import net.gambiter.utils.Properties;
	
	import net.wg.infrastructure.managers.impl.ContainerManagerBase;
	import net.wg.gui.components.containers.MainViewContainer;
	import net.wg.infrastructure.base.AbstractView;
	import net.wg.data.constants.generated.APP_CONTAINERS_NAMES;
	
	public class FlashUI extends AbstractView
	{
		private static const SCREEN_WIDTH:Number = 1024;
		private static const SCREEN_HEIGHT:Number = 768;
		
		private static const NAME_MAIN:String = "main";
		
		public static var ui:FlashUI;
		
		public var py_log:Function;
		public var py_update:Function;
		
		public var showCursor:Boolean;
		public var showRadialMenu:Boolean;
		public var showFullStats:Boolean;
		public var showFullStatsQuestProgress:Boolean;
		
		public var screenSize:Object;
		
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
			showRadialMenu = false;
			showFullStats = false;
			showFullStatsQuestProgress = false;
			
			screenSize = {width: SCREEN_WIDTH, height: SCREEN_HEIGHT};
		}
		
		override protected function onPopulate():void
		{
			super.onPopulate();
			
			try
			{
				parent.removeChild(this);
				viewContainer = (App.containerMgr as ContainerManagerBase).containersMap[APP_CONTAINERS_NAMES.VIEWS];
				viewContainer.setFocusedView(viewContainer.getTopmostView());
				viewPage = viewContainer.getChildByName(NAME_MAIN) as DisplayObjectContainer;
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
		
		public function as_resize(screenWidth:Number, screenHeight:Number):void
		{
			screenSize = {width: screenWidth, height: screenHeight};
			for (var alias:String in components) components[alias].updatePosition();
		}
		
		public function as_cursor(arg:Boolean):void
		{
			if (arg != showCursor) showCursor = arg;
			if (!showCursor) for (var alias:String in components) components[alias].hideCursor();
		}
		
		public function as_radialMenu(arg:Boolean):void
		{
			if (arg != showRadialMenu) showRadialMenu = arg;
			for (var alias:String in components) components[alias].updateVisible();
		}
		
		public function as_fullStats(arg:Boolean):void
		{
			if (arg != showFullStats) showFullStats = arg;
			for (var alias:String in components) components[alias].updateVisible();
		}
		
		public function as_fullStatsQuestProgress(arg:Boolean):void
		{
			if (arg != showFullStatsQuestProgress) showFullStatsQuestProgress = arg;
			for (var alias:String in components) components[alias].updateVisible();			 
		}
				
		public function as_create(alias:String, type:String, props:Object):void
		{
			if (viewPage) createComponent(alias, type, props);
		}
		
		public function as_update(alias:String, props:Object):void
		{
			if (viewPage) updateComponent(alias, props);
		}
		
		public function as_animate(alias:String, delay:Number, props:Object, from:Boolean):void
		{
			if (viewPage) this.animateComponent(alias, delay, props, from);
		}
		
		public function as_delete(alias:String):void
		{
			if (viewPage) deleteComponent(alias);
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
		
		private function animateComponent(alias:String, delay:Number, props:Object, from:Boolean):void
		{
			try
			{
				if (components.hasOwnProperty(alias)) Properties.animateProperty(components[alias], delay, props, from);
				else Properties.animateProperty(Properties.getComponentByPath(viewPage, alias.split(".")), delay, props, from);
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