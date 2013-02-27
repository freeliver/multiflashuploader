package net.freeliver.ui
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author freeliver
	 */
	public class ProgressBar extends Sprite 
	{
		private var barWidth:uint;
		private var barHeight:uint;
		[Embed(source = "../../../assets/progress_orange.gif")]
		private var barClass:Class;
		private var _bar:Bitmap;
		private var _label:TextField;
		private var bar:Sprite;
		public function ProgressBar(w:uint,h:uint=10):void {
			super();
			this._bar = new this.barClass() as Bitmap;
			this.bar = new Sprite();
			this.barWidth = w;
			this.barHeight = h;
			this.graphics.beginFill(0xFFFFFF, 0);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
			this.width = w;
			this.height = h;
			this.createChildren();
		}
		
		public function createChildren():void {
			var labelContainer:Sprite = new Sprite();
			_label = new TextField();
			var labelFormat:TextFormat = new TextFormat();
			labelFormat.color = 0x999999;
			labelFormat.bold = false;
			labelFormat.font = '宋体';		
			labelFormat.size = 10;
			_label.htmlText = '0%';
			_label.visible = false;
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.defaultTextFormat = labelFormat;
			_label.setTextFormat(labelFormat);
			labelContainer.addChild(_label);
			labelContainer.x = 0;
			labelContainer.y = 0;	
			labelContainer.height = this.barHeight;
			labelContainer.width = 40;
			_label.width = labelContainer.width;
			_label.height = labelContainer.height;
			_label.x = 0;
			_label.y = labelContainer.height / 2 - _label.height / 2;
			this.addChild(labelContainer);
			
			this.barWidth -= (labelContainer.width+10);
			this.bar.x = labelContainer.width+10;
			this.bar.y = this.height/2-this.bar.height/2;
			this.bar.graphics.beginFill(0XFFEDDF,0);
			this.bar.graphics.drawRect(0, 0, this.barWidth, this.barHeight);
			this.bar.graphics.endFill();	
			this.bar.height = this.barHeight;
			this.barWidth = this.barWidth;
			this.addChild(this.bar);
		}
		
		public function draw(bytesLoaded:uint, bytesTotal:uint):void {
			var _width:uint = Math.ceil((bytesLoaded / bytesTotal) * this.barWidth);
			this.bar.graphics.clear();
			this.bar.graphics.beginBitmapFill(_bar.bitmapData,null, true, true);
			this.bar.graphics.drawRect(0, 0, _width, 10);
			this.bar.graphics.endFill();
			_label.visible = true;
			_label.text = Math.ceil((bytesLoaded / bytesTotal) * 100)+'%';
		}
	}
	
}
