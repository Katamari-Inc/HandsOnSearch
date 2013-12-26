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

package states {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class NotFoundState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:NotFoundPage;
    private var _timer:Timer;


    public function NotFoundState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            if (name == 'query') {
                _view.queryField.text = _app.query;
            }
        });
        _view = new NotFoundPage();
        _view.queryField.text = _app.query;
        _view.queryField.embedFonts = false;
        _view.retryButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.INPUT_QUERY);
        });
        _timer = new Timer(10000, 1);
        _timer.addEventListener(TimerEvent.TIMER, _handleTimer);
    }


    override public function enter(event:Event):void {
        _app.container.addChild(_view);
        _timer.reset();
        _timer.start();
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
        _timer.stop();
    }


    private function _handleTimer(event:TimerEvent):void {
        _app.changeState(States.INPUT_QUERY);
    }
}
}
