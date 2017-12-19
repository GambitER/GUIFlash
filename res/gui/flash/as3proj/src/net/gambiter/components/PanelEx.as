package net.gambiter.components
{
	import net.gambiter.core.UIComponentEx;
	
    public class PanelEx extends UIComponentEx
    {
		
		public function PanelEx()
        {
            super();
        }
		
		override protected function updateRect() : void
        {
			borderRect = getRect(parent);
			borderRect.x = Math.round(borderRect.x - x);
			borderRect.y = Math.round(borderRect.y - y);
			borderRect.width = Math.round(borderRect.x + borderRect.width);
			borderRect.height = Math.round(borderRect.y + borderRect.height);
		}
    }
}
