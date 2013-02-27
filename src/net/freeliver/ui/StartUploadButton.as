package net.freeliver.ui
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.filters.*;
	
	/**
	 * 
	 * @author freeliver
	 */
	public class StartUploadButton extends SimpleButton 
	{
		private var down_state:Bitmap;
		private var up_state:Bitmap;
		private var over_state:Bitmap;
		private var disabled_state:Bitmap;
		private var hit_state:Shape;
		
		[Embed(source = "../../../assets/upload_button_bg.png")]
		private var _bg:Class;
		[Embed(source = "../../../assets/upload_button_bg_over.png")]
		private var _bg_over:Class;
		[Embed(source = "../../../assets/upload_button_disabled_bg.png")]
		private var _bg_disabled:Class;		
		private var _img:Bitmap;
		private var _img_over:Bitmap;

		public function StartUploadButton(_width:uint=113, _height:uint=31):void {

			this._img = new _bg() as Bitmap;
			this._img_over = new _bg_over() as Bitmap;
			disabled_state = new _bg_disabled() as Bitmap;
			this.useHandCursor	=	true;
			down_state	=	this._img;
			up_state	=	this._img;
			over_state	=	this._img_over;
			hit_state	=	new Shape();
			
			this.drawButtons(_width,_height);
		}
		
		override public function set enabled(b:Boolean):void {
			super.enabled = b;
			this.upState = this.enabled ? up_state : disabled_state;
		}	
		
		protected function drawButtons(w:uint,h:uint):void {
			//绘制状态			
			hit_state.graphics.beginFill(0xFFAA00, 0);
			hit_state.graphics.drawRect(0, 0, w, h);
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
