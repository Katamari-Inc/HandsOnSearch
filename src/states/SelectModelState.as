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

public class SelectModelState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:SelectModelPage;


    public function SelectModelState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            switch (name) {
                case 'query':
                {
                    _view.queryField.text = _app.query;
                    break;
                }
                case 'results':
                {
                    _app.selectedIndex = 0;
                    _updateButtons();
                    if (_app.results.length) {
                        _showImage();
                    }
                    break;
                }
            }
        });
        _view = new SelectModelPage();
        _view.queryField.text = '';
        _view.queryField.embedFonts = false;
        _view.prevButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.selectedIndex--;
            _updateButtons();
            _showImage();
        });
        _view.nextButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.selectedIndex++;
            _updateButtons();
            _showImage();
        });
        _updateButtons();
        _view.printButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.PRINTING);
        });
        _view.retryButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.INPUT_QUERY);
        });
    }


    private function _updateButtons():void {
        _view.prevButton.visible = _app.selectedIndex > 0;
        _view.nextButton.visible = _app.selectedIndex < _app.results.length - 1;
    }


    private function _showImage():void {
        var data:Object = _app.results[_app.selectedIndex];
        _app.showImage(data.thumbnail_url);
    }


    override public function enter(event:Event):void {
        _app.container.addChild(_view);
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
    }
}
}
