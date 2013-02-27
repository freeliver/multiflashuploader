package net.freeliver.ui
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.filters.*;
	
	/**
	 * 上传Button
	 * @author freeliver
	 */
	public class UploadButton extends SimpleButton 
	{
		private var down_state:Bitmap;
		private var up_state:Bitmap;
		private var over_state:Bitmap;
		private var hit_state:Shape;
		
		[Embed(source = "../../../assets/button_bg.png")]
		private var _bg:Class;
		[Embed(source = "../../../assets/button_bg_over.png")]
		private var _bg_over:Class;
		
		private var _img:Bitmap;
		private var _img_over:Bitmap;

		public function UploadButton(_width:uint=163, _height:uint=31):void {

			this._img = new _bg() as Bitmap;
			this._img_over = new _bg_over() as Bitmap;
			this.useHandCursor	=	true;
			this.enabled	=	true;
			down_state	=	this._img;
			up_state	=	this._img;
			over_state	=	this._img_over;
			
			hit_state	=	new Shape();
			
			this.drawButtons(_width,_height);
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
