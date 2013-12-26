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
