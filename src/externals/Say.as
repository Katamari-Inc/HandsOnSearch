/**
 * @author Saqoosha
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
