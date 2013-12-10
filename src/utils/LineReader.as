/**
 * @author Saqoosha
 */
package utils {

import flash.utils.IDataInput;

public class LineReader {
    private var _input:IDataInput;
    private var _buffer:String = '';
    private var _lines:Array = [];

    public function LineReader(input:IDataInput) {
        _input = input;
    }

    public function hasNextLine():Boolean {
        if (_input.bytesAvailable) {
            _buffer += _input.readUTFBytes(_input.bytesAvailable);
            var lines:Array = _buffer.split('\n');
            _buffer = lines.pop();
            _lines = _lines.concat(lines);
        }
        return _lines.length;
    }

    public function getLine():String {
        if (_lines.length) {
            return _lines.shift();
        }
        else {
            return '';
        }
    }
}
}
