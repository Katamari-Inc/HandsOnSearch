/**
 * @author Saqoosha
 */
package externals {

import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Timer;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;
import org.osflash.signals.Signal;

import utils.GCodeAnalyzer;

public class ConveyorClient {

    private static const logger:ILogger = getLogger(ConveyorClient);

    private var _state:String = 'DISCONNECTED';
    private var _machineSerial:String = null;
    private var _watchTimer:Timer;
    private var _runningCommands:Vector.<ConveyorCommand> = new <ConveyorCommand>[];
    private var _estimated:Number = 0;

    private var _stateChanged:Signal = new Signal(String);
    private var _progress:Signal = new Signal(String, Number);
    private var _complete:Signal = new Signal(String, int);


    public function ConveyorClient() {
        _watchTimer = new Timer(1000);
        _watchTimer.addEventListener(TimerEvent.TIMER, _handleWatchTimer);

        var ports:PortsCommand = new PortsCommand();
        ports.completed.addOnce(function (ports:Array):void {
            if (ports.length) {
                _machineSerial = ports[0]['iserial'];
                logger.info('Machine port: {0}', [_machineSerial]);
                connect();
                _startWatch();
            }
            else {
                logger.error('No port available...');
            }
        });
        _execCommand(ports);
    }


    private function _execCommand(command:ConveyorCommand):void {
        command.exit.addOnce(function (command:ConveyorCommand, code:int):void {
            var index:int = _runningCommands.indexOf(command);
            if (index >= 0) {
                _runningCommands.splice(index, 1);
            }
        });
        _runningCommands.push(command);
        command.start();
    }


    public function stopAllRunningCommands():void {
        _watchTimer.stop();
        for each (var command:ConveyorCommand in _runningCommands) {
            command.stop();
        }
    }


    private function _startWatch():void {
        if (!_watchTimer.running) {
            _watchTimer.start();
        }
    }


    private function _stopWatch():void {
        _watchTimer.stop();
    }


    private function _handleWatchTimer(event:TimerEvent):void {
        var command:PrintersCommand = new PrintersCommand();
        command.completed.add(function (printers:Object):void {
            for each (var printer:Object in printers) {
                if (printer.name.indexOf(_machineSerial) >= 0) {
                    var state:String = printer.state;
                    if (state != _state) {
                        logger.info('Conveyor state changed to {0}', [_state]);
                        _state = state;
                        _stateChanged.dispatch(_state);
                    }
                    break;
                }
            }
        });
        _execCommand(command);
    }


    public function connect():void {
        _execCommand(new ConnectCommand());
    }


    public function print(profile:String, stlFile:File):void {
        var command:PrintCommand = new PrintCommand(profile, stlFile);
        command.progress.add(function (name:String, progress:Number):void {
            logger.info('Print progress: {0}: {1}', [name, progress]);
            _progress.dispatch(name, progress);
        });
        command.exit.addOnce(function (c:ConveyorCommand, code:int):void {
            logger.info('Print completed');
            _complete.dispatch('print', code);
        });
        _execCommand(command);
    }


//    public function print(profile:String, stlFile:File):void {
//        logger.info('Print: {0} using profile {1}', [stlFile.nativePath, profile]);
//        var gcodeFile:File = new File(stlFile.nativePath.replace(/\.stl$/i, '.gcode'));
//        var command:SliceCommand = new SliceCommand(profile, stlFile, gcodeFile);
//        command.progress.add(function (name:String, progress:Number):void {
//            logger.info('Slicing progress: {0}: {1}', [name, progress]);
//            _progress.dispatch(name, progress);
//        });
//        command.exit.addOnce(function (command:ConveyorCommand, code:int):void {
//            _complete.dispatch('slice', code);
//            if (code == 0) {
//                logger.info('Slicing complete succeeded');
//                _repairPermission(gcodeFile, function (success:Boolean):void {
//                    if (success) {
//                        logger.info('Repair permission succeeded.');
//                        var stream:FileStream = new FileStream();
//                        stream.open(gcodeFile, FileMode.READ);
//                        var gcode:String = stream.readUTFBytes(stream.bytesAvailable);
//                        var analyzer:GCodeAnalyzer = new GCodeAnalyzer();
//                        _estimated = analyzer.analyze(gcode) * 1.3;
//                        logger.info('Estimated print time(seconds): {0}', [_estimated]);
//                        var command:PrintCommand = new PrintCommand(profile, gcodeFile);
//                        command.progress.add(function (name:String, progress:Number):void {
//                            logger.info('Print progress: {0}: {1}', [name, progress]);
//                            _progress.dispatch(name, progress);
//                        });
//                        command.exit.addOnce(function (c:ConveyorCommand, code:int):void {
//                            logger.info('Print completed');
//                            _complete.dispatch('print', code);
//                        });
//                        _execCommand(command);
//                    }
//                    else {
//                        logger.error('Repair permission failed.');
//                    }
//                    _complete.dispatch('prepare', int(success));
//                });
//            }
//            else {
//                logger.error('Slicing failed with exit code: {0}', [code]);
//            }
//        });
//        _execCommand(command);
//    }


    private function _repairPermission(file:File, callback:Function):void {
        var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        info.executable = new File('/usr/bin/sudo');
        info.arguments = new <String>[
            '-u', '_conveyor',
            'chmod', 'a+rw', file.nativePath
        ];
        var proc:NativeProcess = new NativeProcess();
        proc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function (e:Event):void {
            var text:String = proc.standardOutput.readUTFBytes(proc.standardOutput.bytesAvailable);
            logger.info('Repair permission stdout: ' + text);
        });
        proc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function (e:Event):void {
            var text:String = proc.standardError.readUTFBytes(proc.standardError.bytesAvailable);
            logger.error('Repair permission stderr: ' + text);
        });
        proc.addEventListener(NativeProcessExitEvent.EXIT, function (e:NativeProcessExitEvent):void {
            callback(e.exitCode == 0);
        });
        proc.start(info);
    }


    public function cancelJobs():void {
        var jobs:JobsCommand = new JobsCommand();
        jobs.exit.addOnce(function (command:ConveyorCommand, code:int):void {
            if (jobs.data) {
                for each (var stat:Object in jobs.data) {
                    if (stat.state == 'RUNNING') {
                        logger.info('Canceling job id ' + stat.id);
                        trace('canceling', stat.id);
                        _execCommand(new CancelCommand(stat.id));
                    }
                }
            }
        });
        _execCommand(jobs);
    }


    public function get stateChanged():Signal {
        return _stateChanged;
    }


    public function get progress():Signal {
        return _progress;
    }


    public function get complete():Signal {
        return _complete;
    }


    public function get state():String {
        return _state;
    }


    public function get estimated():Number {
        return _estimated;
    }
}
}


import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.filesystem.File;

import org.as3commons.logging.api.getLogger;
import org.osflash.signals.Signal;

import sh.saqoo.logging.dump;

import utils.LineReader;

class ConveyorCommand {

    private var _info:NativeProcessStartupInfo;
    private var _proc:NativeProcess;
    private var _stdoutLineReader:LineReader;
    private var _stderrLineReader:LineReader;
    private var _exit:Signal = new Signal(ConveyorCommand, int);


    public function ConveyorCommand(args:Vector.<String> = null) {
        _info = new NativeProcessStartupInfo();
        _info.executable = File.applicationDirectory.resolvePath('resources/conveyor-client.py');
        _info.arguments = args;
        _proc = new NativeProcess();
        _stdoutLineReader = new LineReader(_proc.standardOutput);
        _proc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function (e:Event):void {
            while (_stdoutLineReader.hasNextLine()) {
                handleSTDOUT(_stdoutLineReader.getLine());
            }
        });
        _stderrLineReader = new LineReader(_proc.standardError);
        _proc.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, function (e:Event):void {
            while (_stderrLineReader.hasNextLine()) {
                handleSTDERR(_stderrLineReader.getLine());
            }
        });
        _proc.addEventListener(NativeProcessExitEvent.EXIT, handleExit);
    }


    public function start():void {
        _proc.start(_info);
    }


    public function stop():void {
        _proc.exit(true);
    }


    public function handleSTDOUT(line:String):void {
    }


    public function handleSTDERR(line:String):void {
        getLogger(this).info('Unhandled stderr: {0}', [line]);
    }


    public function handleExit(event:NativeProcessExitEvent):void {
        _exit.dispatch(this, isNaN(event.exitCode) ? 0 : event.exitCode);
    }


    public function get exit():Signal {
        return _exit;
    }
}


class JSONCommand extends ConveyorCommand {
    public function JSONCommand(args:Vector.<String>) {
        super(args);
    }


    override public function handleSTDOUT(line:String):void {
        var data:Object = null;
        try {
            data = JSON.parse(line.replace(/u'([^']*?)'/g, '"$1"'));
        }
        catch (e:*) {
            if (!line.match('exit code 0')) {
//                trace('not json? >> ', line);
                getLogger(this).error('parse error: ' + line);
            }
        }
        if (data) {
            handleJSON(data);
        }
    }


    public function handleJSON(data:Object):void {
        dump(data);
    }
}


class PortsCommand extends JSONCommand {
    private var _completed:Signal = new Signal(Object);


    public function PortsCommand() {
        super(new <String>['ports', '-j']);
    }


    override public function handleJSON(data:Object):void {
        _completed.dispatch(data);
    }


    public function get completed():Signal {
        return _completed;
    }
}


class PrintersCommand extends JSONCommand {
    private var _completed:Signal = new Signal(Object);


    function PrintersCommand() {
        super(new <String>['printers', '-j']);
    }


    override public function handleJSON(data:Object):void {
        _completed.dispatch(data);
    }


    public function get completed():Signal {
        return _completed;
    }
}


class SliceCommand extends JSONCommand {
    private var _progress:Signal = new Signal(String, Number);


    public function SliceCommand(profile:String, inFile:File, outFile:File) {
        super(new <String>[
            'slice',
            '-S', File.applicationDirectory.resolvePath('resources/Profiles/' + profile + '/miracle.json').nativePath,
            inFile.nativePath,
            outFile.nativePath
        ]);
    }


    override public function handleJSON(data:Object):void {
        _progress.dispatch(data.name, data.progress);
    }


    public function get progress():Signal {
        return _progress;
    }
}


class PrintCommand extends JSONCommand {
    private var _progress:Signal = new Signal(String, Number);


    public function PrintCommand(profile:String, file:File) {
        super(new <String>[
            'print',
//            '-S', '/Applications/Profiles/' + profile + '/miracle.json',
            '-S', File.applicationDirectory.resolvePath('resources/Profiles/' + profile + '/miracle.json').nativePath,
            file.nativePath
        ]);
    }


    override public function handleJSON(data:Object):void {
        _progress.dispatch(data.name, data.progress);
    }


    public function get progress():Signal {
        return _progress;
    }
}


class ConnectCommand extends ConveyorCommand {
    public function ConnectCommand() {
        super(new <String>['connect']);
    }
}


class JobsCommand extends ConveyorCommand {
    public var data:Object = null;


    public function JobsCommand() {
        super(new <String>[
            'jobs', '-j'
        ]);
    }


    override public function handleSTDOUT(line:String):void {
        try {
            data = JSON.parse(line);
        }
        catch (e:*) {
            if (!line.match('exit code 0')) {
                getLogger(this).error('parse error: ' + line);
            }
        }
    }
}


class CancelCommand extends ConveyorCommand {
    public function CancelCommand(id:int) {
        super(new <String>[
            'cancel', id.toString()
        ]);
    }
}
