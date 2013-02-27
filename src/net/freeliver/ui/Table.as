package net.freeliver.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextExtent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.external.ExternalInterface;
	import net.freeliver.events.DeleteEvent;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author freeliver
	 */
	public class Table extends Sprite 
	{
		private var _headHeight:uint = 25;
		
		public function get headHeight():uint {
			return this._headHeight;
		}
		
		public function set headHeight(h:uint):void {
			this._headHeight = h;
		}
		private var headColor:uint = 0xFCA636;
		private var columns:Array = new Array(200, 240, 63, 40);//所选文件名称，上传提示条，文件大小，操作
		private var headLabels:Array = new Array('选择的文件', '', '大小', '删除');
		
		private var _bodyColor:uint = 0xFFEDDF;
		public function get bodyColor():uint {
			return this._bodyColor;
		}
		
		public function set bodyColor(c:uint):void {
			this._bodyColor = c;
		}		
		private var _controlbarHeight:uint = 25;
		
		public function get controlbarHeight():uint {
			return this._controlbarHeight;
		}
		
		public function set controlbarHeight(h:uint):void {
			this._controlbarHeight = h;
		}
		
		private var _barColor:uint = 0xFCA636;
		private var _docsNum:uint = 0;
		private var _docsSize:uint = 0;
		public function get barColor():uint {
			return this._barColor;
		}
		
		public function set barColor(c:uint):void {
			this._barColor = c;
		}	
		
		private var _height:uint = 0;
		private var _sw:uint = 0;//stage宽度
		private var _sh:uint = 0;//stage高度
		public function Table(w:uint,h:uint,docNum:uint,docSize:uint,sw:uint,sh:uint,color:uint=0xFFFFFF):void {
			graphics.beginFill(color, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();

			this.width = w;
			this._height = h;
			this._sw = sw;
			this._sh = sh;
			this._docsNum = docNum;
			this._docsSize = docSize;
			this.buildHead();
			this.buildBody();
			this.buildControlBar();
			this.addEventListener(DeleteEvent.DELETE_SELECTED_FILE, onDeleteSelectFileHandler,true);
			super();

		}
		
		
		protected function buildHead():void {
			//列表头部
			var thead:Sprite = new Sprite();
			thead.graphics.beginFill(this.headColor, 1);
			thead.graphics.drawRect(0, 0, this.width, this._headHeight);
			thead.graphics.endFill();
			thead.x = thead.y = 0;
			thead.width = this.width;
			thead.height = this._headHeight;
			thead.name = "thead";
			var _x:uint = 0;
			//头部文字
			for (var i:int = 0; i < this.columns.length; i++) {
				var column:Column = new Column(this.columns[i], this._headHeight,0xFF8426);
				column.x = _x;
				column.y = 0;
				var label:TextField = new TextField();
				var labelFormat:TextFormat = new TextFormat();
				labelFormat.color = 0xFFFFFF;
				labelFormat.bold = true;
				labelFormat.font = '宋体';
				
				label.text = this.headLabels[i];
				label.autoSize = TextFieldAutoSize.LEFT;
				label.x = column.width / 2 - label.width / 2;
				label.y = column.height / 2 - label.height / 2;
				label.setTextFormat(labelFormat);
				column.addChild(label);
				thead.addChild(column);
				_x += this.columns[i];
			}
			this.addChild(thead);
		}
		
		protected function buildBody():void {
			//Table中部
			var tbody:Sprite = new Sprite();
			tbody.graphics.beginFill(this._bodyColor, 1);
			tbody.graphics.drawRect(0, 0, this.width, this._height - this._headHeight-this._controlbarHeight);
			tbody.graphics.endFill();
			tbody.x = 0;
			tbody.y = this._headHeight;
			tbody.width = this.width;
			tbody.name = "tbody";
			this.addChild(tbody);		
		}
		protected function buildControlBar():void {
			//Table底部控制条
			var tbar:Sprite = new Sprite();
			tbar.graphics.beginFill(this._barColor, 1);
			tbar.graphics.drawRect(0, 0, this.width,this._controlbarHeight);
			tbar.graphics.endFill();
			tbar.x = 0;
			tbar.y = this._height - this.controlbarHeight;
			tbar.width = this.width;
			tbar.height = this._controlbarHeight;
			tbar.name = "tbar";
			
			var labelFormat:TextFormat = new TextFormat();
			labelFormat.color = 0xFFFFFF;
			labelFormat.bold = false;
			labelFormat.font = '宋体';		
			
			var total_file:TextField = new TextField();
			total_file.text = '您选择了' + this._docsNum + '份文档';
			total_file.autoSize = TextFieldAutoSize.LEFT;
			total_file.x = 10;
			total_file.y = tbar.height / 2 - total_file.height / 2;
			
			total_file.setTextFormat(labelFormat);
			
			var stat:TextField = new TextField();
			var total_size:String = this._docsSize / (1024 * 1024) < 1?Math.round(100 * (this._docsSize / 1024))/100+' KB':Math.round(100 * (this._docsSize / (1024*1024)))/100+' MB';
			stat.text = '文档总计：' + total_size;
			stat.autoSize = TextFieldAutoSize.RIGHT;
			stat.x = tbar.width - stat.width-20;//右浮动，右侧margin 20 px
			stat.y = tbar.height / 2 - stat.height / 2;
			stat.setTextFormat(labelFormat);
			tbar.addChild(total_file);
			tbar.addChild(stat);
			this.addChild(tbar);
		}
		public function onDeleteSelectFileHandler(e:DeleteEvent):void {
			var main:Object = this.root;
			if(main != null){
				var docsNum:uint = main.getDocsNum();
				var docsSize:uint = main.getDocsSize();
				var total_size:String = docsSize / (1024 * 1024) < 1?Math.round(100 * (docsSize / 1024))/100+' KB':Math.round(100 * (docsSize / (1024*1024)))/100+' MB';
				var tbar:Sprite = this.getChildByName('tbar') as Sprite;
				
				var labelFormat:TextFormat = new TextFormat();
				labelFormat.color = 0xFFFFFF;
				labelFormat.bold = false;
				labelFormat.font = '宋体';	
				var total_file:TextField = tbar.getChildAt(0) as TextField;
				total_file.text = '您选择了' + docsNum + '份文档';
				total_file.setTextFormat(labelFormat);
				
				var stat:TextField = tbar.getChildAt(1) as TextField;
				stat.text = '文档总计：' + total_size;
				stat.setTextFormat(labelFormat);
			}
		}
		
		public function setColumnContent(rowY:uint,data:Array, columnHeight:uint = 20,maxHeight:uint=0):void {
			var tbody:Sprite = this.getChildByName("tbody") as Sprite;
			var row:Row = new Row(this.width, columnHeight,0xFFEDDF);//FFEDDF
			row.x = 0;
			row.y = rowY;
			row.addEventListener(MouseEvent.MOUSE_OVER, onRowMouseOverHandler);
			row.addEventListener(MouseEvent.MOUSE_OUT, onRowMouseOutHandler);
			tbody.addChild(row);
			trace(maxHeight + columnHeight -( this._height - this.headHeight - this._controlbarHeight));
			if (maxHeight+columnHeight >= this._height-this.headHeight-this._controlbarHeight) {  if(ExternalInterface.available) ExternalInterface.call('Uploader_Client.resize_upload_window', this._sw, maxHeight+columnHeight-this._height+this.headHeight+this.controlbarHeight+this._sh); }
			var _x:uint = 0;
			for (var i:int = 0; i < this.columns.length; i++) {
				var column:Column = new Column(this.columns[i], columnHeight);
				column.x = _x;
				column.y = 0;
				_x += this.columns[i];
				if (data[i] is DeleteButton) {
					(data[i] as DeleteButton).setRow(row);
				}
				column.addChild(data[i]);
				row.addChild(column);
				
			}			
		}
		
		private function onRowMouseOverHandler(e:MouseEvent):void {
			var row:Row = e.currentTarget as Row;
			row.graphics.clear();
			row.graphics.beginFill(0xFFDA9B, 1);
			row.graphics.drawRect(0, 0, this.width,20);
			row.graphics.endFill();	
			e.stopImmediatePropagation();
		}
		
		private function onRowMouseOutHandler(e:MouseEvent):void {
			var row:Row = e.currentTarget as Row;
			row.graphics.clear();
			row.graphics.beginFill(0xFFEDDF, 1);
			row.graphics.drawRect(0, 0, this.width, 20);
			row.graphics.endFill();	
			e.stopImmediatePropagation();
		}
		
	}
	
}
