package net.gambiter.utils
{
	import flash.display.DisplayObject;
	
	import net.gambiter.components.PanelEx;
	import net.gambiter.components.LabelEx;
	import net.gambiter.components.ImageEx;
	
	// import net.gambiter.components.ScopeEx;
	
	public class Components
	{
		public static const COMPONENT_TYPE_PANEL:String = "panel";
		public static const COMPONENT_TYPE_LABEL:String = "label";
		public static const COMPONENT_TYPE_IMAGE:String = "image";
		public static const COMPONENT_TYPE_SCOPE:String = "scope";
		
		public static function getClass(value:String):DisplayObject
		{
			switch (value.toLowerCase())
			{
			case COMPONENT_TYPE_PANEL: 
				return new PanelEx();
			case COMPONENT_TYPE_LABEL: 
				return new LabelEx();
			case COMPONENT_TYPE_IMAGE: 
				return new ImageEx();
			// case COMPONENT_TYPE_SCOPE: return new ScopeEx();
			default: 
				return null;
			}
		}
	}
}