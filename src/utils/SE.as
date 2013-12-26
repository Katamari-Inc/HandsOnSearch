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
