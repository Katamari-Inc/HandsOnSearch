/**
 * @author Saqoosha
 */
package externals {

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;
import org.osflash.signals.Signal;

public class Thingiverse {

    private static const API_KEY_NAME:String = 'thingiverse_access_token';
    private static const logger:ILogger = getLogger(Thingiverse);

    private var _searchResult:Object = null;
    private var _thingName:String;
    private var _stlFiles:Array = null;
    private var _completed:Signal = new Signal(Array);


    public function Thingiverse() {
    }


    public function search(query:String):void {
        var req:URLRequest = new URLRequest('http://api.thingiverse.com/search/' + encodeURIComponent(query));
        req.requestHeaders = [new URLRequestHeader('Authorization', 'Bearer ' + Config.getValue(API_KEY_NAME))];
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, _handleSearch);
        loader.addEventListener(IOErrorEvent.IO_ERROR, _handleSearchError);
        loader.load(req);
    }


    private function _handleSearch(e:Event):void {
        var loader:URLLoader = URLLoader(e.target);
        _searchResult = null;
        try {
            var data:Object = JSON.parse(loader.data);
            if (data is Array) {
                _searchResult = data;
            }
        } catch (e:*) {
            logger.error('Search result parse error: {0}', [e.toString()]);
        }
        if (_searchResult && _searchResult.length) {
            _stlFiles = [];
            var th:Object = _searchResult.shift();
            _thingName = th.name;
            files(th.id);
        } else {
            _completed.dispatch(null);
        }
    }


    private function _handleSearchError(e:ErrorEvent):void {
        logger.error('Search error', [e.toString()]);
        _completed.dispatch(null);
    }


    public function fileInfo(id:Number):void {
        var req:URLRequest = new URLRequest('http://api.thingiverse.com/files/' + id);
        req.requestHeaders = [new URLRequestHeader('Authorization', 'Bearer ' + Config.getValue(API_KEY_NAME))];
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, _handleFileInfo);
        loader.addEventListener(IOErrorEvent.IO_ERROR, _handleFileInfoError);
        loader.load(req);
    }


    private function _handleFileInfo(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        var data:Object = null;
        try {
            data = JSON.parse(loader.data) as Object;
            data.thumbnail_url = data.thumbnail;
            data.data_url = data.public_url;
            data.preset = 0;
        }
        catch (e:*) {
            logger.error('File info result parse error: {0}', [e.toString()]);
        }
        _completed.dispatch([data]);
    }


    private function _handleFileInfoError(event:IOErrorEvent):void {
        logger.error('File info error: {0}', [event.toString()]);
        _completed.dispatch(_stlFiles);
    }


    public function files(id:Number):void {
        var req:URLRequest = new URLRequest('http://api.thingiverse.com/things/' + id + '/files');
        req.requestHeaders = [new URLRequestHeader('Authorization', 'Bearer ' + Config.getValue(API_KEY_NAME))];
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.TEXT;
        loader.addEventListener(Event.COMPLETE, _handleFiles);
        loader.addEventListener(IOErrorEvent.IO_ERROR, _handleFilesError);
        loader.load(req);
    }


    private function _handleFiles(event:Event):void {
        var loader:URLLoader = URLLoader(event.target);
        var data:Array = null;
        try {
            data = JSON.parse(loader.data) as Array;
        }
        catch (e:*) {
            logger.error('Files result parse error: {0}', [e.toString()]);
        }

        if (data) {
            for each (var item:Object in data) {
                if (item.name.match(/\.stl$/i)) {
                    item.name = _thingName;
                    item.thumbnail_url = item.thumbnail;
                    item.data_url = item.public_url;
                    item.preset = 0;
                    _stlFiles.push(item);
                }
            }
        }

        if (_stlFiles.length < 10 && _searchResult.length) {
            var th:Object = _searchResult.shift();
            _thingName = th.name;
            files(th.id);
        }
        else {
            _completed.dispatch(_stlFiles);
        }
    }


    private function _handleFilesError(e:ErrorEvent):void {
        logger.error('Files error: {0}', [e.toString()]);
        _completed.dispatch(_stlFiles);
    }


    public function get completed():Signal {
        return _completed;
    }
}
}
