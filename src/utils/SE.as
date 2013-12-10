/**
 * @author Saqoosha
 */
package utils {

import flash.filesystem.File;
import flash.media.Sound;
import flash.net.URLRequest;

public class SE {
    private static var OK:Sound = new Sound();
    private static var NG:Sound = new Sound();
    private static var SUCCEEDED:Sound = new Sound();

    public static function init():void {
        var assets:File = File.applicationDirectory.resolvePath('resources/sounds');
        OK.load(new URLRequest(assets.resolvePath('OK.mp3').url));
        NG.load(new URLRequest(assets.resolvePath('NG.mp3').url));
        SUCCEEDED.load(new URLRequest(assets.resolvePath('SUCCEEDED.mp3').url));
    }

    public static function ok():Number {
        OK.play();
        return OK.length;
    }

    public static function ng():Number {
        NG.play();
        return NG.length;
    }

    public static function succeeded():Number {
        SUCCEEDED.play();
        return SUCCEEDED.length;
    }
}
}
