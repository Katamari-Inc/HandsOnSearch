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

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.filesystem.File;

import org.as3commons.logging.api.getLogger;

public class Say {

//    static private var current:NativeProcess = null;
    static private var procs:Vector.<NativeProcess> = new <NativeProcess>[];


    static public function say(message:String):void {
        getLogger(Say).debug(message);
        if (message.match(/[^\s]+/)) {
            stopAll();

            var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            info.executable = new File('/usr/bin/say');
            info.arguments = new <String>[
                '--progress',
                '-v',
                'Kyoko',
                message
            ];
            var process:NativeProcess = new NativeProcess();
//            process.addEventListener(NativeProcessExitEvent.EXIT, function (e:NativeProcessExitEvent):void
//            {
//                process.removeEventListener(NativeProcessExitEvent.EXIT, arguments.callee);
//            });
            process.start(info);
            procs.push(process);
        }
    }


    static public function stopAll():void {
        for each (var proc:NativeProcess in procs) {
            proc.exit(true);
        }
        procs = new <NativeProcess>[];
    }
}
}
