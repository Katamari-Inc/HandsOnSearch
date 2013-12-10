/**
 * @author Saqoosha
 */
package {

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class Config {

    private static const logger:ILogger = getLogger(Config);
    private static var data:Object;


    public static function init():void {
        var stream:FileStream = new FileStream();
        stream.open(File.applicationDirectory.resolvePath('resources/config.json'), FileMode.READ);
        data = JSON.parse(stream.readUTFBytes(stream.bytesAvailable));
        stream.close();
    }


    public static function getValue(key:String):* {
        return data[key];
    }


    public static function getVolumeFor(preset:String):Number {
        return data.presets[preset].volume;
    }


    public static function getProfileName(preset:String):String {
        return data.presets[preset].name;
    }
}
}
