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
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class Service {

    private static const logger:ILogger = getLogger(Service);


    public static function download(url:String, callback:Function):void {
        logger.info('Download file from {0}', [url]);
        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, function (event:Event):void {
            var temp:File = new File(File.createTempFile().nativePath + '.stl');
            var stream:FileStream = new FileStream();
            stream.open(temp, FileMode.WRITE);
            stream.writeBytes(loader.data);
            stream.close();
            logger.info('Downloaded data stored here: {0}', [temp.nativePath]);
            callback(temp);
        });
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
            logger.error('Download error: {0}', [event.toString()]);
            callback(null);
        });
        loader.load(new URLRequest(url));
    }


    public static function normalizeSTL(stlFile:File, volume:Number, callback:Function):void {
        logger.info('Normalize STL: {0} with volume {1}', [stlFile.nativePath, volume]);
        var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        info.executable = File.applicationDirectory.resolvePath('resources/stlexport');
        info.arguments = new <String>[
            stlFile.nativePath,
            volume.toString()
        ];
        var proc:NativeProcess = new NativeProcess();
        var json:String = '';
        proc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function (e:*):void {
            json += proc.standardOutput.readUTFBytes(proc.standardOutput.bytesAvailable);
        });
        proc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function (e:*):void {
            var line:String = proc.standardError.readUTFBytes(proc.standardError.bytesAvailable);
            logger.info('Normalize stderr: {0}', [line]);
        });
        proc.addEventListener(NativeProcessExitEvent.EXIT, function (e:NativeProcessExitEvent):void {
            var file:File = null;
            try {
                var data:Object = JSON.parse(json);
                file = new File(data.filepath);
                if (!file.exists) {
                    logger.error('Normalized file doesn\'t exist: {0}', [file.nativePath]);
                    file = null;
                }
                else {
                    logger.info('Normalized succeeded: {0}', [file.nativePath]);
                }
            }
            catch (e:Error) {
                logger.error('Normalize result parse error: {0}', [e.toString()]);
            }
            callback(file);
        });
        proc.start(info);
    }
}
}
