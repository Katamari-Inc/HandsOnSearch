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

import externals.Service;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

import sh.saqoo.debug.ObjectDumper;

public class PrintingState extends BaseState {

    private static const logger:ILogger = getLogger(PrintingState);

    private var _app:HandsOnSearch;
    private var _view:PrintingPage;
    private var _canceled:Boolean;


    public function PrintingState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            switch (name) {
                case 'query':
                {
                    _view.queryField.text = _app.query;
                    break;
                }
                case 'progress':
                {
                    _view.progressBar.width = 46 + _app.progress * 750;
                    break;
                }
            }
        });
        _view = new PrintingPage();
        _view.queryField.text = _app.query;
        _view.queryField.embedFonts = false;
        _view.statusField.text = '';
        _view.statusField.embedFonts = false;
        _view.progressBar.width = 46;
        _view.cancelButton.addEventListener(MouseEvent.CLICK, function (e:*):void {
            status = "キャンセル中です...";
            _canceled = true;
            _view.cancelButton.visible = false;
            _app.cancel();
        });
        _view.cancelButton.visible = false;
    }


    override public function get from():* {
        return States.SELECT_MODEL;
    }


    override public function enter(event:Event):void {
        _app.container.addChild(_view);

        var data:Object = _app.results[_app.selectedIndex];
        logger.debug(ObjectDumper.dumpToText(data));
        Service.download(data.data_url, _handleDownloadComplete);
        status = '3Dモデルデータをダウンロード中です...';

        _canceled = false;
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
    }


    private function _handleDownloadComplete(file:File):void {
        if (file) {
            status = 'データを準備中です...';
            var data:Object = _app.results[_app.selectedIndex];
            var volume:Number = Config.getVolumeFor(data.preset) || 1000;
            Service.normalizeSTL(file, volume, _handleNormalizeComplete);
        }
    }


    private function _handleNormalizeComplete(file:File):void {
        if (file) {
            var data:Object = _app.results[_app.selectedIndex];
            _app.print(file, Config.getProfileName(data.preset));
        }
    }


    public function set status(value:String):void {
        if (!_canceled) {
            _view.statusField.text = value;
        }
    }


    public function get status():String {
        return _view.statusField.text;
    }


    public function showCancel():void {
        if (!_canceled) {
            _view.cancelButton.visible = true;
        }
    }
}
}
