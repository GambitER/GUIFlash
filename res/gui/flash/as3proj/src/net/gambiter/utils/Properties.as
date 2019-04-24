package net.gambiter.utils
{	
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.filters.DropShadowFilter;
	
	import mx.utils.ObjectUtil;
	
	import net.gambiter.FlashUI;
	import net.gambiter.core.UIComponentEx;
	import net.gambiter.components.ImageEx;
	
	public class Properties
	{		
		public static function getBound(obj:DisplayObject):Rectangle
		{			
			var objRect:Rectangle = obj.getRect(obj);
			var objPoint:Point = obj.localToGlobal(new Point(0, 0));			
			return new Rectangle(
				obj.x - objPoint.x - objRect.x,
				obj.y - objPoint.y - objRect.y,
				FlashUI.ui.screenSize.width - objRect.width,
				FlashUI.ui.screenSize.height - objRect.height
			);
		}
		
		public static function getLimiter(obj:DisplayObject, obj_x:Number, obj_y:Number):Object
		{
			var point:Object = {x: obj_x, y: obj_y};
			var rect:Rectangle = getBound(obj);
			point.x = Math.max(point.x, rect.x);
			point.y = Math.max(point.y, rect.y);
			point.x = Math.min(point.x, rect.width);
			point.y = Math.min(point.y, rect.height);
			return point;
		}
		
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
			if (obj is UIComponentEx && !(obj is ImageEx)) (obj as UIComponentEx).refresh();
		}
		public static function animateProperty(obj:DisplayObject, delay:Number, args:Object, from:Boolean):void
		{
			if (!obj || !args) return;
			var arg:String = null;
			var new_args:Object = {};
			for (arg in args)
			{
				if (obj.hasOwnProperty(arg))
				{
					new_args[((arg == "x") || (arg == "y"))?("_" + arg):arg] = args[arg];
					continue;
				}
				FlashUI.ui.py_log("Object with linkage \'" + obj.name + "\' doesn`t contain property " + "with name \'" + arg + "\'.");
			}
			if (ObjectUtil.getClassInfo(new_args).properties.length > 0)
			{
				new_args.ease = Linear.easeNone;
				if (obj is UIComponentEx) new_args.onUpdate = (obj as UIComponentEx).refresh;
				if (from) TweenLite.from(obj, delay, new_args);
				else TweenLite.to(obj, delay, new_args);
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
		
		public static function traceDisplayList(container:DisplayObjectContainer, indent:String = ""):void
		{
			for (var i:uint = 0; i < container.numChildren; i++)
			{
				var component:DisplayObject = container.getChildAt(i);
				FlashUI.ui.py_log(indent, i, component.name);
				if (container.getChildAt(i) is DisplayObjectContainer) traceDisplayList(component as DisplayObjectContainer, indent + " --| ")
			}
		}
	}
}