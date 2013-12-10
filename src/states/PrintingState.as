/**
 * @author Saqoosha
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
