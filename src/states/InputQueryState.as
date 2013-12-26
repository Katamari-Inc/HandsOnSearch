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
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

public class InputQueryState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:InputQueryPage;


    public function InputQueryState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            if (name == 'query') {
                _view.queryField.text = _app.query;
            }
        });
        _view = new InputQueryPage();
        _view.queryField.text = _app.query;
        _view.queryField.embedFonts = false;
        _view.searchButton.addEventListener(MouseEvent.CLICK, _handleSearchClick);
    }


    override public function enter(event:Event):void {
        _app.query = '';
        _app.container.addChild(_view);
        _app.stage.focus = _view.queryField;
        _view.queryField.addEventListener(KeyboardEvent.KEY_DOWN, _handleKeyDown);
        _view.queryField.addEventListener(Event.CHANGE, _handleChange);
    }


    private function _handleChange(event:Event):void {
        trace(_view.queryField.text);
    }


    private function _handleKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case Keyboard.ENTER:
                event.preventDefault();
                event.stopPropagation();
                _handleSearchClick(null);
                break;
        }
    }


    private function _handleSearchClick(event:MouseEvent):void {
        var q:String = _view.queryField.text.replace(/\s+/g, '');
        if (q.length) {
            _app.search(q);
        }
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
        _view.queryField.removeEventListener(KeyboardEvent.KEY_DOWN, _handleKeyDown);
    }
}
}
