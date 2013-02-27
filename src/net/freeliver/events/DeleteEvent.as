package net.freeliver.events
{
	import flash.events.Event;
	import flash.display.Sprite;
	
	/**
	 * 删除选择文件事件
	 * @author freeliver<freeliver204@gmail.com>
	 */
	public class DeleteEvent extends Event 
	{
		public static const DELETE_SELECTED_FILE:String = 'delete_selected_file';
		private var _row:Sprite = null;
		public function DeleteEvent(row:Sprite):void {
			this._row = row;
			super(DELETE_SELECTED_FILE,false,true);
		}
		
		public function getRow():Sprite {
			return this._row;
		}
	}
	
}
