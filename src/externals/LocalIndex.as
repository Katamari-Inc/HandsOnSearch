/**
 * @author Saqoosha
 */
package externals {

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

public class LocalIndex {

    private var _index:Dictionary = new Dictionary();


    public function LocalIndex() {
    }


    public function init():void {
        var stream:FileStream = new FileStream();
        stream.open(File.applicationDirectory.resolvePath('resources/data.tsv'), FileMode.READ);
        var data:String = stream.readUTFBytes(stream.bytesAvailable);
        stream.close();

        for each (var line:String in data.split('\n')) {
            var info:ThingInfo = new ThingInfo(line);
            for each (var tag:String in info.tags) {
                tag = tag.replace(/\s/, '');
                if (tag.length == 0) {
                    continue;
                }
                if (_index.hasOwnProperty(tag)) {
                    _index[tag].push(info);
                } else {
                    _index[tag] = [info];
                }
            }
        }

        for (var key:String in _index) {
            if (_index[key].length > 1) {
                _index[key].sort(_sortByPriority);
            }
        }
    }


    private static function _sortByPriority(a:ThingInfo, b:ThingInfo):int {
        return a.priority - b.priority;
    }


    public function search(query:String):Array {
        return _index[query] || null;
    }
}
}


class ThingInfo {

    public var name:String;
    public var url:String;
    public var tags:Array;
    public var priority:int;
    public var preset:int;


    public function ThingInfo(data:String) {
        var fields:Array = data.split('\t');
        name = fields[0];
        url = fields[2];
        tags = fields[3].split(' ');
        priority = parseInt(fields[4]) || 1000;
        preset = parseInt(fields[5]) || 0;
    }


    public function toString():String {
        return '[ThingInfo name="' + name + ' url="' + url + ' tags="' + tags + '" priority="' + priority + '"]';
    }
}
