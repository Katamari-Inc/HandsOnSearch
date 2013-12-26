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

package utils {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class ScreenSaver extends Sprite {
    private static const TIMEOUT:Number = 10;
    private var _enabled:Boolean = false;
    private var _timer:Timer = new Timer(TIMEOUT * 60000, 1);

    public function ScreenSaver() {
        visible = false;
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, 1024, 768);
        graphics.endFill();

        _timer.stop();
        _timer.addEventListener(TimerEvent.TIMER, _handleTimer);
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        if (_enabled != value) {
            _enabled = value;
            if (_enabled) {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleAction);
                stage.addEventListener(MouseEvent.MOUSE_DOWN, _handleAction);
                stage.addEventListener(KeyboardEvent.KEY_DOWN, _handleAction);
                _timer.start();
            }
            else {
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleAction);
                stage.removeEventListener(MouseEvent.MOUSE_DOWN, _handleAction);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, _handleAction);
                _timer.stop();
            }
        }
    }

    public function get saving():Boolean {
        return visible;
    }

    public function action():void {
        _handleAction(null);
    }

    private function _handleAction(e:Event):void {
        visible = false;
        _timer.reset();
        _timer.start();
    }

    public function _handleTimer(e:TimerEvent):void {
        visible = true;
    }
}
}
