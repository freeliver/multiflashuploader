package net.freeliver{
  import net.freeliver.ui.Column;
  import net.freeliver.ui.ReUploadButton;
  import net.freeliver.ui.StartUploadButton;
  import net.freeliver.ui.Table;
  import flash.display.Sprite;
  import flash.external.ExternalInterface;
  import flash.net.FileReferenceList;
  import flash.net.FileReference;
  import flash.net.FileFilter;
  import flash.events.*;
  import flash.system.Security;
  import flash.text.TextField;
  import flash.text.TextFormatAlign;
  import flash.text.TextFormat;
  import flash.text.TextFieldAutoSize;
  import flash.net.URLRequest;
  import flash.ui.ContextMenu;
  import flash.ui.ContextMenuItem;
  import flash.utils.Timer;
  import flash.display.*;
  import net.freeliver.ui.UploadButton;
  import net.freeliver.ui.DeleteButton;
  import net.freeliver.ui.ProgressBar;
  import net.freeliver.events.DeleteEvent;
  import net.freeliver.ui.Row;
  import flash.net.navigateToURL;
  import flash.net.URLRequestMethod;
  import flash.utils.setTimeout;
  import flash.utils.clearTimeout;
  import flash.net.URLVariables;

  /**
    *MultiFlashUploader 多文件上传组件Flash端
    *@author freeliver<freeliver204@gmail.com>
    *@lastModifiedDate 2010-11-23 13:57
  */
  [Swf(width="573",height="150")]
  public class Main extends Sprite {
    private var _fileReferList:FileReferenceList = null;
    private var _fileFilter:Array  = null;
	private var _files:Array;
    private var _upload_url:String = 'http://www.freeliver.net/test/upload';
	private var _help_url:String = 'http://www.freeliver.net/127';
    private var _debug:Boolean  = true;
    private var _lock:Boolean = false;
    private var _process:uint = 0;
    private var _total_file_count:uint  = 0;
    private var _request:URLRequest = null;
	private var _progressBars:Array = new Array();
	private var _deleteButtons:Array = new Array();
	private var _complete_queue:Array =  new Array();//完成队列
    private var _wait_queue:Array = new Array();//等待队列
	private var _cookie:String;
	private var _reselect:Boolean = false;
	private var _allow_suffix:Array = new Array();//所支持的后缀名称
	private var _allow_max_size:uint = 20971520;//文档上传最大bytes
	private var _delay_id:int = 0;
	
	public static const PADDING_LEFT:uint = 15;
	public static const PADDING_TOP:uint = 15;
	public static const PADDING_BOTTOM:uint = 60;
	private var _columnHeight:uint = 20;
	

    /**
      *构造函数
    */
  
    public function Main():void {

      Security.allowDomain('freeliver.net');
      Security.allowDomain('test.freeliver.net');
	  
	  this.initContextmenu();
      this.initUI();
      this.initFileReferenceList();
      this._request = new URLRequest(this._upload_url);
	  this._allow_suffix	= ['.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx', '.pot', '.potx', '.pps', '.rtf', '.wps', '.et', '.dps', '.pdw', '.pxl', '.psw', '.txt', '.xml', '.eml', '.bmp', '.gif', '.jpg', '.tif', '.jpeg', '.png', '.tiff', '.pdf','.png'];
	  if (ExternalInterface.available) {
			this._cookie = ExternalInterface.call('Uploader_Client.get_cookie');
	  }	  
	  this.stage.addEventListener(Event.RESIZE, onChangeHeight);
	  
    }
	
	/**
	 * 设置上下文菜单
	 * @param	void
	 */
	
	protected function initContextmenu():void {
		var _contextmenu:ContextMenu = new ContextMenu();
		_contextmenu.hideBuiltInItems();
		var _help:ContextMenuItem = new ContextMenuItem('上传帮助');
		_contextmenu.customItems.push(_help);
		_help.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemSelectHandler);
		this.contextMenu = _contextmenu;
		
	}	
	
	private function onItemSelectHandler(e:ContextMenuEvent):void {
		navigateToURL(new URLRequest(this._help_url), '_blank');
	}	
	/**
	 * *当窗口大小改变时重新绘制UI
	 * @param	Event e
	 */
	protected function onChangeHeight(e:Event):void {
		this.repeatUI();
	}	

    /**
      *初始化UI界面
    */

    protected function initUI():void {
		this.stage.align	= StageAlign.TOP_LEFT;
		this.stage.scaleMode	= StageScaleMode.NO_SCALE;
		this.graphics.beginFill(0xFFF9F1, 1);
		this.graphics.drawRoundRect(0, 0, this.stage.stageWidth, this.stage.stageHeight,2,2);
		this.graphics.endFill();
		
		var upload_button:UploadButton = new UploadButton();
		upload_button.x = /*this.stage.stageWidth / 2*/573/2 - upload_button.width / 2;
		upload_button.y = /*this.stage.stageHeight / 2*/150/2 - upload_button.height / 2;
		upload_button.addEventListener(MouseEvent.CLICK, toSelectFileHandler);
		upload_button.name = "upload_button";
		this.addChild(upload_button); 
		
		var container:Sprite = new Sprite();
		container.graphics.beginFill(0xFFF9F1, 1);
		container.graphics.drawRect(0, 0, this.stage.stageWidth - 2*PADDING_LEFT, this.stage.stageHeight - PADDING_TOP-PADDING_BOTTOM);
		container.graphics.endFill();
		container.x = PADDING_LEFT;
		container.y = PADDING_TOP;
		container.width = this.stage.stageWidth - 2 * PADDING_LEFT;
		container.visible = false;
		container.name = "container";
		this.addChild(container);
		
		var startUploadButton:StartUploadButton = new StartUploadButton();
		startUploadButton.x = this.stage.stageWidth / 2 - startUploadButton.width / 2;
		startUploadButton.y = this.stage.stageHeight-36;
		startUploadButton.addEventListener(MouseEvent.CLICK, toUploadAllFileHandler);
		startUploadButton.visible = false;
		startUploadButton.name = "start_upload_button";
		this.addChild(startUploadButton); 		
    }
	
	/**
	 * 重新绘制UI界面
	 */
	protected function repeatUI():void {
		this.graphics.clear();
		this.graphics.beginFill(0xFFF9F1, 1);
		this.graphics.drawRoundRect(0, 0, this.stage.stageWidth, this.stage.stageHeight,2,2);
		this.graphics.endFill();	
		
		var container:Sprite = this.getChildByName("container") as Sprite;
		container.graphics.clear();
		container.graphics.beginFill(0xFFF9F1, 1);
		container.graphics.drawRect(0, 0, this.stage.stageWidth - 2*PADDING_LEFT, this.stage.stageHeight - PADDING_TOP-PADDING_BOTTOM);
		container.graphics.endFill();
		
		var table:Table = container.getChildByName("table") as Table;
		if(table != null){
			table.graphics.clear();
			table.graphics.beginFill(0xFFF9F1, 1);
			table.graphics.drawRect(0, 0, this.stage.stageWidth - 2*PADDING_LEFT, this.stage.stageHeight - PADDING_TOP-PADDING_BOTTOM);
			table.graphics.endFill();	
		
			var tbody:Sprite = table.getChildByName("tbody") as Sprite;
			var tbar:Sprite = table.getChildByName("tbar") as Sprite;
			if(tbody != null ){
				tbody.graphics.clear();
				tbody.graphics.beginFill(0xFFEDDF, 1);
				tbody.graphics.drawRect(0, 0, this.stage.stageWidth - 2*PADDING_LEFT , this.stage.stageHeight -  PADDING_TOP-PADDING_BOTTOM - table.headHeight-table.controlbarHeight);
				tbody.graphics.endFill();
			}
			if(tbar != null){
				tbar.x = 0;
				tbar.y = this.stage.stageHeight - PADDING_TOP-PADDING_BOTTOM-table.controlbarHeight;
			}
		}
		
		var startUploadButton:StartUploadButton = this.getChildByName("start_upload_button") as StartUploadButton;
		startUploadButton.x = this.stage.stageWidth / 2 - startUploadButton.width / 2;
		startUploadButton.y = this.stage.stageHeight - PADDING_TOP - PADDING_BOTTOM + container.y + 25;
		
		var msg:TextField	= this.getChildByName('overflow_msg') as TextField;
		if(msg !=null){
			msg.x = this.stage.stageWidth / 2 - msg.width / 2;
			msg.y = startUploadButton.y - 20;
			msg.visible = true;
		}
		
	}
	
	protected function repeatBodyUI():void {
		var tbody:Sprite = ((getChildByName('container') as Sprite).getChildByName('table') as Sprite).getChildByName("tbody") as Sprite;
		for (var i:uint = 0; i < tbody.numChildren; i++) {
			var row:Row = tbody.getChildAt(i) as Row;
			row.x = 0;
			row.y = i * this._columnHeight;
		}
	}	
    
    /**
      *初始化文件选择对象
    */

    protected function initFileReferenceList():void{
      this._fileReferList =  new FileReferenceList();
      this._fileFilter  = new Array(new FileFilter('上传客户端支持全部格式', '*.doc;*.DOC;*.DOCX;*.PPT;*.PPTX;*.XLS;*.XLSX;*.POT;*.docx;*.ppt;*.pptx;*.xls;*.xlsx;*.pot;*.potx;*.POTX;*.PPS;*.RTF;*.pps;*.rtf;*.gif;*.GIF;*.JPG;*.jpeg;*.JPEG;*.jpg;*.WPS;*.ET;*.DPS;*.wps;*.et;*.dps;*.pdw;*.PDW;*.PXL;*.TXT;*.XML;*.EML;*.PDF;*.PNG;*.pxl;*.psw;*.txt;*.xml;*.eml;*.pdf;*.png'));
	  this._fileFilter.push(new FileFilter('WPS文档', '*.wps;*.et;*.dps;*.DPS;*.ET;*.WPS'));
	  this._fileFilter.push(new FileFilter('图片系列', '*.gif;*.jpg;*.png;*.PNG;*.GIF;*.JPEG;*.JPG;*.jpeg'));
	  this._fileFilter.push(new FileFilter('Office系列', '*.doc;*.DOC;*.DOCX;*.PPT;*.PPTX;*.XLS;*.XLSX;*.POT;*.docx;*.ppt;*.pptx;*.xls;*.xlsx;*.pot;*.POTX;*.PPS;*.RTF;*.potx;*.pps;*.rtf'));
	  this._fileFilter.push(new FileFilter('PocketOffice','*.pdw;*.pxl;*.psw;.PDW;*.PXL;*.PSW'));
	  this._fileFilter.push(new FileFilter('其他文档', '*.pdf;*.txt;*.xml;*.eml;*.PDF;*.TXT;*.XML;*.EML'));
      this._fileReferList.addEventListener(Event.SELECT,onFileSelectedHandler);
      this._fileReferList.addEventListener(Event.CANCEL,onFileSelectCancelHandler);
    }
    
    /**
      *浏览文件
      *@param MouseEvent e default null
    */

    public function toSelectFileHandler(e:MouseEvent = null):void {
		//var button:SimpleButton = e.target as SimpleButton;
		//button.removeEventListener(MouseEvent.CLICK, toSelectFileHandler);
        this._fileReferList.browse(this._fileFilter);
    }
    
    /**
      *文件选择完毕时的监听器
    */

    private function onFileSelectedHandler(e:Event):void{
      var fileReferenceList:FileReferenceList = e.target as FileReferenceList;
      this._wait_queue  = fileReferenceList.fileList;
	  var msg:TextField = this.getChildByName("overflow_msg") as TextField;
	  if (msg != null) {
		 this.removeChild(msg);
	  }
	  //一次只能选择选取10个文档
	  if (this._wait_queue.length > 10) {
		  this._wait_queue.splice(10, this._wait_queue.length);
		  this.setErrorMsg('您选择的部分文档将不会被上传，一次只能选择上传十个文档，您可以分批上传！');
	  } 
      this._files  = new Array();
	  if (this._complete_queue.length != 0) {
		 this._complete_queue = new Array();
	  }
	  this._progressBars	= new Array();
	  this._deleteButtons	= new Array();
	  this._process	= 0;
	  this._lock = false;
      var i:int = 0;
	  var old_len:int = this._wait_queue.length;
      for (var index:String in this._wait_queue) {
		  if (this._allow_suffix.indexOf((this._wait_queue[index].type as String).toLowerCase()) == -1 || this._wait_queue[index].size>this._allow_max_size) {//文件后缀不合或者超出规定大小
			 this._wait_queue.splice(parseInt(index), 1);
		  }
		  
		  if (this._wait_queue[index] != null) {
			  var formatSize:String = this._wait_queue[index].size/(1024*1024)<1?(Math.round((this._wait_queue[index].size/1024)*100)/100)+' KB':(Math.round((this._wait_queue[index].size/(1024*1024))*100)/100)+' MB'; 
			   this._files[i] = { 'name':this._wait_queue[index].name, 'size':this._wait_queue[index].size, 'docid':0, 'md5':'', 'formatSize':formatSize, 'type':this._wait_queue[index].type, 'status':false, 'error_id':0, 'error_msg':'' };
		  }
		  i++;

		  
      }

	  if (this._files.length != old_len) {
		  this.setErrorMsg('您选择的部分文档将不会被上传，可能是格式不支持或者超过20M');	  
		  if (this._files.length == 0 && ExternalInterface.available) {			
				ExternalInterface.call('Uploader_Client.show_flash_error', '您选择的部分文档将不会被上传，可能是格式不支持或者超过20M');
		  }
	  }
	  if(this._files.length!=0){
		  this._total_file_count  = this._wait_queue.length;
		  this.showSelectFile();
	  }
    }
	
	private function setErrorMsg(m:String,isShow:Boolean = false):void {
		var msg:TextField = new TextField();
		msg.autoSize = TextFieldAutoSize.CENTER;
		msg.htmlText = '<font color="#FF0000" size="12" >'+m+'</font>';
		msg.x = this.stage.stageWidth / 2 - msg.width / 2;
		msg.y = (this.getChildByName("start_upload_button") as StartUploadButton).y - 20;
		msg.name = "overflow_msg";
		msg.visible = isShow;
		this.addChild(msg);		
	}	
	
	private function onDeleteSelectFileHandler(e:DeleteEvent):void {
		var row:Row = e.getRow() as Row;
		var tbody:Sprite = row.parent as Sprite;
		var fileID:int = tbody.getChildIndex(row);
		this._wait_queue.splice(fileID, 1);
		this._files.splice(fileID, 1);
		this._progressBars.splice(fileID, 1);
		this._deleteButtons.splice(fileID, 1);
		tbody.removeChildAt(fileID);
		this._total_file_count--;
		if (this._wait_queue.length != 0) {
			if (ExternalInterface.available&&this.stage.stageHeight>150) ExternalInterface.call('Uploader_Client.resize_upload_window', this.stage.stageWidth, this.stage.stageHeight - this._columnHeight);
			repeatBodyUI();
		}else {
			var container:Sprite = this.getChildByName('container') as Sprite;
			var startUploadButton:StartUploadButton = this.getChildByName('start_upload_button') as StartUploadButton;
			var uploadButton:UploadButton = this.getChildByName('upload_button') as UploadButton;
			container.visible = false;
			container.removeChild(container.getChildByName('table'));
			startUploadButton.visible=false;
			uploadButton.visible = true;
			var overflow_msg:TextField=this.getChildByName('overflow_msg') as TextField
			if(overflow_msg)this.removeChild(overflow_msg);
			this.removeEventListener(DeleteEvent.DELETE_SELECTED_FILE, onDeleteSelectFileHandler, true);
			startUploadButton.addEventListener(MouseEvent.CLICK, toUploadAllFileHandler);
			uploadButton.addEventListener(MouseEvent.CLICK, toSelectFileHandler);
		}
	}
	
	private function showSelectFile():void {
		var container:Sprite = this.getChildByName("container") as Sprite;
		var startButton:StartUploadButton = this.getChildByName("start_upload_button") as StartUploadButton;
		var uploadButton:UploadButton = this.getChildByName("upload_button") as UploadButton;
		var reUploadButton:ReUploadButton = this.getChildByName('reuploadbutton') as ReUploadButton;
		var docsSize:uint = 0;
		for each(var row:Object in this._files) {
			docsSize += row.size;
		}
		
		var temp:Sprite = container.getChildByName('table') as Sprite;
		if (temp) {
			container.removeChild(temp);
		}
		
		if (reUploadButton != null) {
			this.removeChild(reUploadButton);
		}
		
		var table:Table = new Table(container.width,container.height,this._files.length,docsSize,this.stage.stageWidth,this.stage.stageHeight);
		table.name = "table";
		var _y:uint = 0;
		var step:uint = 0;
		var maxHeight:uint = 0;
		for (var index:String in this._files) {		
			var fileName:TextField = new TextField();
			fileName.width = 200;
			fileName.height = this._columnHeight;

			fileName.text = this._files[index].name;
			fileName.x = 5;
			fileName.y = this._columnHeight / 2 - 10;
			var fileSize:TextField = new TextField();
			fileSize.htmlText = this._files[index].formatSize;
			var progressBar:ProgressBar = new ProgressBar(240,  this._columnHeight);
			progressBar.y = this._columnHeight / 2 - progressBar.height / 2;
			var delButton:DeleteButton = new DeleteButton();
			delButton.x = 25 - delButton.width / 2;//此处使用具体的列宽度来定位删除按钮居中显示
			delButton.y = this._columnHeight / 2 - 5;
			step++;
			if (step == this._files.length) {
				maxHeight = _y;
			}
			table.setColumnContent(_y, new Array(fileName, progressBar, fileSize, delButton), this._columnHeight,maxHeight);
			this._progressBars[index] = progressBar;
			this._deleteButtons[index] = delButton;
			_y += this._columnHeight;
		}
		
		if (ExternalInterface.available && this.stage.stageHeight > 150 && this._reselect) {
			this._reselect = false;
			ExternalInterface.call('Uploader_Client.resize_upload_window', this.stage.stageWidth, 150+(step-1)*this._columnHeight);		
		}
		container.addChild(table);			
		container.visible = true;
		startButton.visible = true;
		startButton.enabled = true;
		uploadButton.visible = false;

		
		this.addEventListener(DeleteEvent.DELETE_SELECTED_FILE, onDeleteSelectFileHandler,true);
		
		
	}	
    
    /**
      *取消选择文件
    */

    private function onFileSelectCancelHandler(e:Event):void {
			var uploadButton:UploadButton = this.getChildByName('upload_button') as UploadButton;
			uploadButton.addEventListener(MouseEvent.CLICK, toSelectFileHandler);
    }

    /**
      *上传一个文件
      *@param uint fileID 上传的文件ID
    */

    public function toUploadFileHandler(fileID:uint):void {
		clearTimeout(this._delay_id);
		var data:URLVariables = new URLVariables();
        data.fname = this._files[fileID].name;
		data.fsize = this._files[fileID].size;
		data.ftype = this._files[fileID].type;
		data.cookie = this._cookie;
		this._request.data = data;
		this._request.method = URLRequestMethod.POST;
		trace(fileID);
		this._wait_queue[fileID].addEventListener(ProgressEvent.PROGRESS,onProgressHandler);
        this._wait_queue[fileID].addEventListener(Event.COMPLETE,onCompleteHandler);
        this._wait_queue[fileID].addEventListener(SecurityErrorEvent.SECURITY_ERROR,onErrorHandler);
        this._wait_queue[fileID].addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
	    this._wait_queue[fileID].addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onServerReponseHandler);
		this._wait_queue[fileID].addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandler);
        this._wait_queue[fileID].upload(this._request, 'doc_upload');
    }
    
    /**
      *上传所有文件
    */

    public function toUploadAllFileHandler(e:MouseEvent):void {
		for each(var btn:DeleteButton in this._deleteButtons) {
			btn.enabled = false;
		}
		var startButton:SimpleButton = e.target as SimpleButton;
		startButton.removeEventListener(MouseEvent.CLICK, toUploadAllFileHandler);
		startButton.enabled = false;
        var timer:Timer = new Timer(30);
        timer.addEventListener(TimerEvent.TIMER,onUploadingHandler);
        timer.start();
    }
    
    /**
      *上传所有文件监视器
    */

    private function onUploadingHandler(e:TimerEvent):void {
      if(this._process == this._total_file_count){
        var timer:Timer = e.target as Timer;
        timer.reset();
		var is_success:Boolean	= false;
		for each(var row:Object in this._complete_queue) {
			if (row.status == true) {
				is_success = true;
			}
			
		}	
		if (is_success == false) {//全部上传不成功！
			this._reselect = true;
			
			for each(var btn:DeleteButton in this._deleteButtons) {
				btn.visible = false;
			}
			var startUploadButton:StartUploadButton = this.getChildByName('start_upload_button') as StartUploadButton;
			var _x:uint = startUploadButton.x;
			var _y:uint = startUploadButton.y;
			startUploadButton.visible = false;
			startUploadButton.addEventListener(MouseEvent.CLICK, toUploadAllFileHandler);
			
			var reUploadButton:ReUploadButton = new ReUploadButton();
			reUploadButton.x = _x;
			reUploadButton.y = _y;
			reUploadButton.name = "reuploadbutton";
			this.addChild(reUploadButton);
			reUploadButton.addEventListener(MouseEvent.CLICK, toSelectFileHandler);
	
			
		}
		if(ExternalInterface.available) ExternalInterface.call('Uploader_Client.get_upload_files',this._complete_queue);
		this._lock = false;
		return void;
      }

      if (this._lock == false) {
		 this._lock = true;
         this._delay_id = setTimeout(this.toUploadFileHandler,1000,this._process);		  		 		  
      }else {
		 return void;
	  }
    }
    
    /**
      *上传进行中
    */

    public function onProgressHandler(e:ProgressEvent):void {
		var bar:ProgressBar = this._progressBars[this._process] as ProgressBar;
		bar.draw(e.bytesLoaded, e.bytesTotal);
    }
	
	/**
	 * 检查Http status
	 * @param	e
	 */
	
	public function onHttpStatusHandler(e:HTTPStatusEvent):void {
		trace(e.status + '::' + e.type);
		sendClientMsg('server http status:'+e.status+':::'+e.type);
	}	
    
	/**
      *上传完毕
    */

    public function onCompleteHandler(e:Event=null):void {
	  this._wait_queue[this._process].removeEventListener(ProgressEvent.PROGRESS,onProgressHandler);
	  this._wait_queue[this._process].removeEventListener(Event.COMPLETE,onCompleteHandler);
	  this._wait_queue[this._process].removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onErrorHandler);
	  this._wait_queue[this._process].removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
    }
	
	/**
	 * 服务器应答监听
	 * @param	DataEvent e
	 */
	public function onServerReponseHandler(e:DataEvent):void {
		trace(e.data);
		var row:Object = this._files[this._process] as Object;
		if(e.data.indexOf('ok_')!=-1){
			row.status = true;
			var info:String = e.data.substr(('ok_').length);
			row.docid = info.substr(info.lastIndexOf('_') + 1);
			row.md5 = info.substr(0, info.lastIndexOf('_'));
		}else {
			row.status = false;
			
			var bar:ProgressBar = this._progressBars[this._process] as ProgressBar;
			var bar_parent:Sprite = bar.parent as Sprite;
			bar_parent.removeChild(bar);

			var error:TextField = new TextField();
			error.autoSize = TextFieldAutoSize.LEFT;
			error.x = 20;
			
			if(e.data=='3'){				
				row.error_id = 3;//服务端判定文件大小超过限制
				row.error_msg = 'file size is greater than the maxsize ';
				error.htmlText = '<font color="#FF0000">上传失败：文件大于规定的限制</font>';
			}else if (e.data == '4') {
				row.error_id = 4;//表示服务器判定文件后缀名称不正确
				row.error_msg = 'file suffix type error';
				error.htmlText = '<font color="#FF0000">上传失败：文件类型不正确</font>';				
			}else if (e.data == '5') {
				row.error_id = 5;//表示服务器判定文件类型不正确
				row.error_msg = 'file type error';
				error.htmlText = '<font color="#FF0000">上传失败：文件类型不正确</font>';				
			}else if (e.data.indexOf('errorid_6') != -1) {
				row.error_id = 6;//表示服务器判定此文件已经存在，不予上传
				var einfo:String = e.data.substr(('errorid_6_').length);
				row.docid = einfo.substr(einfo.lastIndexOf('_') + 1);
				row.md5 = einfo.substr(0, einfo.lastIndexOf('_'));				
				row.error_msg = 'server upload error';
				error.htmlText = '<font color="#FF0000">上传失败：上传的文件已经存在</font>';				
			}else if (e.data == '7') {
				row.error_id = 7;//表示服务器处理错误,移动文件失败
				row.error_msg = 'server upload error';
				error.htmlText = '<font color="#FF0000">上传失败：服务器内部错误</font>';				
			}else if (e.data == '8') {
				row.error_id = 8;//表示服务器处理错误,复制文件失败
				row.error_msg = 'server upload error';
				error.htmlText = '<font color="#FF0000">上传失败：服务器内部错误</font>';				
			}else if (e.data == '9') {
				row.error_id = 9;//表示不是上传文件
				row.error_msg = 'is not uploaded file';
				error.htmlText = '<font color="#FF0000">上传失败：不是上传文件</font>';					
			}else if (e.data == '10') {
				row.error_id = 10;//表示未登录
				row.error_msg = 'user is not login';
				error.htmlText = '<font color="#FF0000">上传失败：请先登录</font>';					
			}else if (e.data == '11') {
				row.error_id = 11;//表示管理员设置此账户禁止上传
				row.error_msg = 'you is forbidden to upload file!';
				error.htmlText = '<font color="#FF0000">上传失败：此账户被禁止上传文件！</font>';
			}else if (e.data == '12') {
				row.error_id = 12;//表示管理员设置此账户被锁定
				row.error_msg = 'your account is locked!';
				error.htmlText = '<font color="#FF0000">上传失败：此账户已经被锁定！</font>';
			}else if (e.data == '13') {
				row.error_id = 13;//表示管理员设置此账户禁止上传
				row.error_msg = 'max upload files is happened!';
				error.htmlText = '<font color="#FF0000">上传失败：已达到今天的最大上传数目！</font>';
			}else if (e.data == '14') {
				row.error_id = 14;//表示更新数据库信息错误
				row.error_msg = 'database do information error!';
				error.htmlText = '<font color="#FF0000">上传失败：更新数据库信息错误！</font>';
			}else if (e.data == '15') {
				row.error_id = 15;//表示上传数据为空
				row.error_msg = 'server upload limit because configure !';
				error.htmlText = '<font color="#FF0000">上传失败：上传数据为空，请重新上传！</font>';
			}else if (e.data == '16') {
				row.error_id = 16;//表示上传数据为空
				row.error_msg = 'server upload error because user group check error!';
				error.htmlText = '<font color="#FF0000">上传失败：检测用户权限错误！</font>';
			}
			bar_parent.addChild(error);
		}
		
		this._process++;
		this._complete_queue.push(row);	 
		sendClientMsg('server response :'+e.data+';current process :'+this._process+';total_files:'+this._total_file_count);
		this._lock  =  false;	
	}	
	
    /**
      *错误监听器
    */

    private function onErrorHandler(e:Event):void {
		trace(e);
		this._wait_queue[this._process].removeEventListener(ProgressEvent.PROGRESS,onProgressHandler);
		this._wait_queue[this._process].removeEventListener(Event.COMPLETE,onCompleteHandler);
		this._wait_queue[this._process].removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onErrorHandler);
		this._wait_queue[this._process].removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);
		
		var bar:ProgressBar = this._progressBars[this._process] as ProgressBar;
		var bar_parent:Sprite = bar.parent as Sprite;
		bar_parent.removeChild(bar);	  
		var row:Object = this._files[this._process] as Object;
		row.status = false;
		
		var error:TextField = new TextField();
		error.autoSize = TextFieldAutoSize.LEFT;
		error.x = 20;	
		
		if (e is IOErrorEvent) {
			row.error_id = 1;//1 表示IO错误
			row.error_msg =  (e as IOErrorEvent).text;
			error.htmlText = '<font color="#FF0000">Flash上传失败：客户端IO错误</font>';
		}else if (e is SecurityErrorEvent) {
			row.error_id = 2;//2 表示安全错误
			row.error_msg =  (e as SecurityErrorEvent).text;
			error.htmlText = '<font color="#FF0000">Flash通讯失败：安全沙箱错误</font>';
		}
		bar_parent.addChild(error);
		sendClientMsg('client error:'+e.toString());	
		this._complete_queue.push(row);
		this._process++;
		this._lock  =  false;
    }
	
	public function getDocsNum():uint {
		return this._files.length;
	}
	public function getDocsSize():uint {
		var docsSize:uint = 0;
		for each(var row:Object in this._files) {
			docsSize += row.size;
		}
		return docsSize;
	}	
	
	public function getFiles():Array {
		return this._files;
	}	

    /**
      *向JS客户端发送信息
    */

    public function sendClientMsg(msg:String):void{
      if(ExternalInterface.available) ExternalInterface.call('Uploader_Client.get_msg',msg);
    }

  }
}
