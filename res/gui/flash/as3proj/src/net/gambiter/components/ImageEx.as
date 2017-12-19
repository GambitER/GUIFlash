package net.gambiter.components
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	
	import scaleform.clik.constants.InvalidationType;
	
	import net.gambiter.FlashUI;
	
	import net.gambiter.core.UIComponentEx;
	
	public class ImageEx extends UIComponentEx
	{		
		public var loader:Loader;
		
		private var _source:String;		
		private var _sourceAlt:String;
		private var _autoSize:Boolean;		
		private var _loadFailed:Boolean;		
		private var _loadInProgress:Boolean;		
		private var _previousContentUnloaded:Boolean;
		
		public function ImageEx()
		{
			super();
			
			loader = new Loader();
			addChild(loader);
			
			_source = "";
			_sourceAlt = "";
			
			_autoSize = true;
			
			_loadFailed = false;
			_loadInProgress = false;
			
			_previousContentUnloaded = true;
			
			addLoaderListener();
		}
		
		override protected function configUI():void
		{
			super.configUI();
		}
		
		override protected function onDispose():void
		{			
			if (loader != null)
			{
				removeLoaderListener();
				unload();
				removeChild(loader);
				loader = null;
			}
			super.onDispose();
		}

		
		override public function refresh():void
		{			
			if (_loadFailed || _loadInProgress) return;			
			if (_autoSize)
			{
				loader.width = _originalWidth;
				loader.height = _originalHeight;
			}
			else
			{
				loader.width = _width || _originalWidth;
				loader.height = _height || _originalHeight;
			}
			super.refresh();
		}
		
		override protected function updateRect() : void
        {
			borderRect.x = loader.x;
			borderRect.y = loader.y;
			borderRect.width = loader.width;
			borderRect.height = loader.height;
		}
		
		private function startLoad(url:String):void
		{
			_source = url;
			if (!_previousContentUnloaded) loader.unload();
			loader.visible = false;
			_loadInProgress = true;
			_previousContentUnloaded = false;
			loader.load(new URLRequest(url));
		}
		
		private function startLoadAlt():void
		{
			startLoad(_sourceAlt);
		}
		
		private function loadComplete():void
		{
			loader.visible = true;
		}
		
		private function unload():void
		{
			if (_loadInProgress) loader.close();
			loader.unload();
			_source = null;
		}
		
		private function addLoaderListener():void
		{
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIoErrorHandler);
			loader.contentLoaderInfo.addEventListener(Event.UNLOAD, onLoaderUnloadHandler);
		}
		
		private function removeLoaderListener():void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderIoErrorHandler);
			loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, onLoaderUnloadHandler);
		}
		
		override public function set width(arg:Number):void
		{
			_autoSize = false;
			super.width = arg;
		}
		
		override public function set height(arg:Number):void
		{
			_autoSize = false;
			super._height = arg;
		}
		
		public function get autoSize():Boolean
		{
			return _autoSize;
		}
		
		public function set autoSize(arg:Boolean):void
		{
			_autoSize = arg;
		}
		
		public function get image():String
		{
			return source;
		}
		
		public function set image(url:String):void
		{
			source = url;
		}
		
		public function get imageAlt():String
		{
			return sourceAlt;
		}
		
		public function set imageAlt(url:String):void
		{
			sourceAlt = url;
		}
		
		public function get source():String
		{
			return _source;
		}
		
		public function set source(url:String):void
		{
			_loadFailed = false;
			if (!url || url == _source) return;
			startLoad(url);
		}
		
		public function get sourceAlt():String
		{
			return _sourceAlt;
		}
		
		public function set sourceAlt(url:String):void
		{
			if (!url || _sourceAlt == url) return;
			_sourceAlt = url;
			if (_loadFailed) startLoad(url);
		}
		
		private function onLoaderCompleteHandler(e:Event):void
		{
			_loadFailed = false;
			_loadInProgress = false;					
			initialize();
			refresh();
			loadComplete();
		}
		
		private function onLoaderIoErrorHandler(e:IOErrorEvent):void
		{
			if (!_loadFailed && _sourceAlt)
			{
				_loadFailed = true;
				startLoad(_sourceAlt);
			}
			else _loadInProgress = false;
		}
		
		private function onLoaderUnloadHandler(e:Event):void
		{
			_previousContentUnloaded = true;
		}
	}
}