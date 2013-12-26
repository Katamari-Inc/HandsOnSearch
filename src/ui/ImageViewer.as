/**
 Copyright (c) 2013, Yahoo Japan Corporation
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.

 3. Neither the name of  Yahoo Japan Corporation nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
