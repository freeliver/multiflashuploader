package net.freeliver.ui
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author freeliver
	 */
	public class Row extends Sprite 
	{
		public function Row(w:uint,h:uint,color:uint=0xFFFFFF):void {
			super();
			graphics.beginFill(color, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();	
			this.width = w;
			this.height = h;
		}
		
	}
	
}
