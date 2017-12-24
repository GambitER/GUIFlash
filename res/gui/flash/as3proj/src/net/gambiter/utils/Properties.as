package net.gambiter.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.DropShadowFilter;
	
	import net.gambiter.FlashUI;
	import net.gambiter.core.UIComponentEx;
	
	public class Properties
	{
		public static function setShadow(obj:DisplayObject, args:Object):void
		{
			if (!obj || !args) return;
			var shadow:DropShadowFilter = new DropShadowFilter();
			var arg:String = null;
			if (args)
			{
				for (arg in args)
					if (shadow.hasOwnProperty(arg)) shadow[arg] = args[arg];
				obj.filters = [shadow];
			}
			else obj.filters = null;
		}
		
		public static function setProperty(obj:DisplayObject, args:Object):void
		{
			if (!obj || !args) return;
			var arg:String = null;
			for (arg in args)
			{
				if (obj.hasOwnProperty(arg))
				{
					obj[arg] = args[arg];
					continue;
				}
				FlashUI.ui.py_log("Object with linkage \'" + obj.name + "\' doesn`t contain property " + "with name \'" + arg + "\'.");
			}
			if (obj is UIComponentEx) (obj as UIComponentEx).refresh();
		}
		
		public static function traceDisplayList(container:DisplayObjectContainer, indent:String = ""):void
		{
			for (var i:uint = 0; i < container.numChildren; i++)
			{
				var component:DisplayObject = container.getChildAt(i);
				FlashUI.ui.py_log(indent, i, component.name);
				if (container.getChildAt(i) is DisplayObjectContainer) traceDisplayList(component as DisplayObjectContainer, indent + " --| ")
			}
		}
		
		public static function getComponentByPath(container:DisplayObjectContainer, path:Array):DisplayObject
		{
			var component:DisplayObject = container as DisplayObject;
			for each (var item:String in path)
			{
				if (!container) break;
				component = container.getChildByName(item);
				if (!component) break;
				container = component as DisplayObjectContainer;
			}
			return component;
		}
	}
}