/**
 * @author Saqoosha
 */
package ui {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

public class ImageViewer extends Sprite {

    private var _width:int;
    private var _height:int;
    private var _loader:Loader;


    public function ImageViewer(width:int, height:int) {
        _width = width;
        _height = height;
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _handleLoadComplete);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _handleLoadError);

        graphics.beginFill(0xcccccc);
        graphics.drawRect(-2, -2, _width + 4, _height + 4);
        graphics.endFill();
        graphics.beginFill(0xffffff);
        graphics.drawRect(0, 0, _width, _height);
        graphics.endFill();
    }


    public function load(url:String):void {
        _loader.load(new URLRequest(url));
    }


    private function _handleLoadComplete(event:Event):void {
        var b:Bitmap = Bitmap(_loader.content);
        b.smoothing = true;
        var s:Number = Math.min(_width / b.width, _height / b.height);
        _loader.scaleX = _loader.scaleY = s;
        _loader.x = (_width - _loader.width) / 2;
        _loader.y = (_height - _loader.height) / 2;
        addChild(_loader);
    }


    private function _handleLoadError(event:IOErrorEvent):void {
    }


    public function clear():void {
        if (_loader.parent) {
            _loader.parent.removeChild(_loader);
            _loader.unload();
        }
    }
}
}
