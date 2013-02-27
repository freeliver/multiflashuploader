package net.freeliver.ui
{
	import net.freeliver.events.DeleteEvent;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	
	/**
	 * 作为测试使用的一个button UI组件
	 * @author freeliver
	 */
	public class DeleteButton extends SimpleButton 
	{
		private var down_state:Bitmap;
		private var up_state:Bitmap;
		private var over_state:Bitmap;
		private var hit_state:Shape;
		private var disabled_state:Bitmap;
		private var  BUTTON_WIDTH:uint = 30;
		public var  BUTTON_HEIGHT:uint = 25;
		
		[Embed(source = "../../../assets/delete_bg.png")]
		private var _bg:Class;
		
		[Embed(source = "../../../assets/delete_over_bg.png")]
		private var _over_bg:Class;
		
		[Embed(source = "../../../assets/delete_disabled_bg.png")]
		private var _disabled_bg:Class;
		
		private var _row:Sprite;
		
		
		public function DeleteButton(width:uint=12, height:uint=11):void {
			this.BUTTON_WIDTH = width;
			this.BUTTON_HEIGHT = height;
			down_state	=	new _bg() as Bitmap;
			up_state	=	new _bg() as Bitmap;
			over_state	=	new _over_bg() as Bitmap;
			disabled_state = new _disabled_bg() as Bitmap;
			hit_state	=	new Shape();
			this.useHandCursor	=	true;
			this.enabled = true;
			this.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			this.drawButtons();
		}
		
		override public function set enabled(b:Boolean):void {
			super.enabled = b;
			this.upState = this.enabled ? up_state : disabled_state;
			if (b == false) {
				this.removeEventListener(MouseEvent.CLICK, onMouseClickHandler);
			}else {
				this.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			}
		}
		
		public function setRow(row:Sprite):void {
			this._row = row;
		}
		
		protected function onMouseClickHandler(e:MouseEvent):void {
			this.dispatchEvent(new DeleteEvent(this._row));
		}

		
		protected function drawButtons():void {
			//绘制状态
			
			hit_state.graphics.beginFill(0xFFAA00, 0.8);
			hit_state.graphics.drawRect(0, 0, this.BUTTON_WIDTH, this.BUTTON_HEIGHT);
			hit_state.graphics.endFill();
			hit_state.x = hit_state.y = 0;
			
			//设置鼠标状态
			this.downState = down_state;
			this.upState = up_state;
			this.overState = over_state;
			this.hitTestState = hit_state;
		}
		
		
		
	}
	
}
