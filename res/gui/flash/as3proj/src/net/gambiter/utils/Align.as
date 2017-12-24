package net.gambiter.utils
{
	
	public final class Align
	{
		public static const NONE:String = "none";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const CENTER:String = "center";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		public static function isValid(align:String):Boolean
		{
			return align == LEFT || align == RIGHT || align == CENTER || align == TOP || align == BOTTOM;
		}
		
		public static function isValidH(align:String):Boolean
		{
			return align == LEFT || align == CENTER || align == RIGHT;
		}
		
		public static function isValidV(align:String):Boolean
		{
			return align == TOP || align == CENTER || align == BOTTOM;
		}
	}
}