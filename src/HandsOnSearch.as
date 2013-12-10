/**
 * @author Saqoosha
 */
package {

import externals.ConveyorClient;
import externals.LocalIndex;
import externals.Say;
import externals.Thingiverse;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.filesystem.File;
import flash.ui.Mouse;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.LOGGER_FACTORY;
import org.as3commons.logging.api.getLogger;
import org.as3commons.logging.setup.SimpleTargetSetup;
import org.as3commons.logging.setup.target.AirFileTarget;
import org.as3commons.logging.setup.target.TraceTarget;
import org.as3commons.logging.setup.target.mergeTargets;
import org.osflash.signals.Signal;

import stateMachine.StateMachine;
import stateMachine.StateMachineEvent;

import states.CompleteState;
import states.InputQueryState;
import states.NotFoundState;
import states.PrintingState;
import states.SelectModelState;
import states.States;

import ui.ImageViewer;
import ui.PrinterStatusWindow;

import utils.SE;
import utils.ScreenSaver;
import utils.ScreenUpdater;

[SWF(width="1024", height="768", backgroundColor="0xf6f6f6", frameRate="30")]
public class HandsOnSearch extends Sprite {

    private static const logger:ILogger = getLogger(HandsOnSearch);

    private static const NO_BUTTON_MODE:Boolean = true;

    private var _stateMachine:StateMachine;
    private var _printingState:PrintingState;

    private var _query:String = '';
    private var _results:Array = [];
    private var _selectedIndex:int = 0;
    private var _progress:Number = 0;
    private var _startTime:int = 0;

    private var _modelChanged:Signal = new Signal(String);

    private var _container:Sprite;
    private var _currentImage:ImageViewer;
    private var _screenSaver:ScreenSaver;

    private var _conveyor:ConveyorClient;
    private var _localIndex:LocalIndex;
    private var _thingiverse:Thingiverse;

    private var _statusWindow:PrinterStatusWindow;


    public function HandsOnSearch() {
        LOGGER_FACTORY.setup = new SimpleTargetSetup(mergeTargets(new TraceTarget(), new AirFileTarget()));

        logger.info('Application started');

        Config.init();
        SE.init();

        stage.scaleMode = StageScaleMode.SHOW_ALL;
        stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;

        _container = new Sprite();
        addChild(_container);

        _currentImage = new ImageViewer(240, 175);
        _currentImage.x = 390;
        _currentImage.y = 290;

        _statusWindow = new PrinterStatusWindow(this);
        _statusWindow.visible = false;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, _handleKeyDown);

        _screenSaver = new ScreenSaver();
        stage.addChild(_screenSaver);
        stage.addChild(new ScreenUpdater());

        _conveyor = new ConveyorClient();
        _conveyor.stateChanged.add(_handleConveyorStateChanged);
        _conveyor.progress.add(_handleConveyorProgress);
        _conveyor.complete.add(_handleConveyorComplete);
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, function (e:Event):void {
            _conveyor.stopAllRunningCommands();
        });
        setTimeout(function ():void {
            _conveyor.cancelJobs();
        }, 1000);

        _localIndex = new LocalIndex();
        _localIndex.init();

        _thingiverse = new Thingiverse();
//        _thingiverse.fileInfo(342867);

        _stateMachine = new StateMachine();
        _stateMachine.addState(States.INPUT_QUERY, new InputQueryState(this));
        _stateMachine.addState(States.SELECT_MODEL, new SelectModelState(this));
        _stateMachine.addState(States.NOT_FOUND, new NotFoundState(this));
        _stateMachine.addState(States.PRINTING, _printingState = new PrintingState(this));
        _stateMachine.addState(States.COMPLETE, new CompleteState(this));
        _stateMachine.addEventListener(StateMachineEvent.TRANSITION_COMPLETE, _handleTransitionComplete);
        _stateMachine.initialState = States.INPUT_QUERY;
    }


    private function _handleKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case 27: // ESC
                _statusWindow.visible = !_statusWindow.visible;
                if (!NO_BUTTON_MODE) {
                    if (_statusWindow.visible) {
                        Mouse.show();
                    }
                    else {
                        Mouse.hide();
                    }
                }
                break;
            default:
                if (!NO_BUTTON_MODE) {
                    Say.say('こんにちは、さわれる検索です。左の○ボタンを押しながら、キミのさわりたいものを教えてね？');
                }
                break;
        }
    }


    private function _handleConveyorStateChanged(state:String):void {
        _statusWindow.state = state;
        switch (state) {
            case 'IDLE':
                progress = 0;
                if (_stateMachine.state == States.PRINTING) {
                    changeState(States.COMPLETE);
                }
                break;
        }
    }


    private function _handleConveyorProgress(name:String, value:Number):void {
        if (name == 'print') {
            progress = value / 100;
            var elapsed:Number = (getTimer() - _startTime) / 1000;
            var total:Number = elapsed + (1 - progress) * (_conveyor.estimated + 120);
            var left:Number = total - elapsed;
            var m:int = Math.round(left / 60);
            if (m) {
                _printingState.status = 'さわれるまであと' + m + '分ぐらいだよ。完成までもう少し待っていてね。';
            }
            else {
                _printingState.status = 'さわれるまでもうちょっとだよ。';
            }
            _printingState.showCancel();
        }
        _statusWindow.state = name;
        _statusWindow.progress = value / 100;
    }


    private function _handleConveyorComplete(command:String, code:int):void {
        switch (command) {
            case 'slice':
                _startTime = getTimer();
                break;
            case 'prepare':
                Say.say('さわれるまで' + Math.round((_conveyor.estimated + 120) / 60) + '分ぐらいだよ？完成まで待っていてね？');
                break;
        }
    }


    private function _handleTransitionComplete(event:StateMachineEvent):void {
        var voiceEnabled:Boolean = false;
        var imageVisible:Boolean = false;
        switch (event.toState) {
            case States.INPUT_QUERY:
                switch (event.fromState) {
                    case null:
                    case States.COMPLETE:
                        var text:String;
                        if (NO_BUTTON_MODE) {
                            text = 'こんにちは、さわれる検索です。キミのさわりたいものを教えてね？';
                        }
                        else {
                            text = 'こんにちは、さわれる検索です。左の○ボタンを押しながら、キミのさわりたいものを教えてね？';
                        }
                        Say.say(text);
                        break;
                }
                voiceEnabled = true;
                _screenSaver.enabled = true;
                break;

            case States.SELECT_MODEL:
                voiceEnabled = true;
                imageVisible = true;
                _screenSaver.enabled = true;
                break;

            case States.NOT_FOUND:
                voiceEnabled = true;
                break;

            case States.PRINTING:
                imageVisible = true;
                _screenSaver.enabled = false;
                break;

            case States.COMPLETE:
                setTimeout(function ():void {
                    Say.say('「' + _query + '」が完成したよ？先生に安全に取り出してもらってね？');
                }, 4000);
                _screenSaver.enabled = true;
                break;
        }
        if (imageVisible) {
            addChild(_currentImage);
        }
        else if (_currentImage.parent) {
            removeChild(_currentImage);
        }
    }


    private function _handleLargeButtonPress(buttonId:int):void {
        if (_screenSaver.saving) {
            _screenSaver.action();
            return;
        }

        switch (buttonId) {
            case 0:
                switch (_stateMachine.state) {
                    case States.INPUT_QUERY:
                    case States.NOT_FOUND:
                    case States.SELECT_MODEL:
                        changeState(States.INPUT_QUERY);
                        Say.stopAll();
//                        _dummyQueryField.text = '';
//                        stage.focus = _dummyQueryField;
//                        setTimeout(LargeButton.keyStroke, 100, 0x3f);
//                        setTimeout(LargeButton.keyStroke, 150, 0x3f);
                        break;

                    case States.PRINTING:
                        Say.say(_printingState.status.replace(/。/g, '？'));
                        break;

                    case States.COMPLETE:
                        Say.say('「' + _query + '」が完成したよ？先生に安全に取り出してもらってね？');
                        break;
                }
                break;
            case 1:
                switch (_stateMachine.state) {
                    case States.INPUT_QUERY:
                    case States.NOT_FOUND:
                        if (NO_BUTTON_MODE) {
                            Say.say('キミのさわりたいものを教えてね？');
                        }
                        else {
                            Say.say('左の○ボタンを押しながら、キミのさわりたいものを教えてね？');
                        }
                        break;

                    case States.SELECT_MODEL:
                        Say.say(_query + 'をプリントするよ？');
                        changeState(States.PRINTING);
                        break;

                    case States.PRINTING:
                        Say.say(_printingState.status.replace(/。/g, '？'));
                        break;

                    case States.COMPLETE:
                        Say.say('「' + _query + '」が完成したよ？先生に安全に取り出してもらってね？');
                        break;
                }
                break;
        }
    }


    private function _handleLargeButtonRelease(buttonId:int):void {
        switch (buttonId) {
            case 0:
//                LargeButton.keyStroke(0x3f);
                break;
        }
    }


    public function search(query:String):void {
        this.query = query;
        var result:Array = _localIndex.search(query);
        if (result) {
            _thingiverse.completed.addOnce(function (value:Array):void {
                value[0].name = result[0].name;
                value[0].preset = result[0].preset;
                _handleSearchResult(value);
            });
            _thingiverse.fileInfo(result[0].url.split(':').pop());
        } else {
            _thingiverse.completed.addOnce(_handleSearchResult);
            _thingiverse.search(query);
        }
    }


    private function _handleSearchResult(value:Array):void {
        results = value || [];
        if (results.length) {
            query = value[0].name;
            SE.ok();
            setTimeout(function ():void {
                var text:String = '「' + _query + '」がみつかったよ？';
                Say.say(text);
            }, 1000);
            changeState(States.SELECT_MODEL);
        } else {
            SE.ng();
            setTimeout(function ():void {
                var text:String = 'ごめんなさい、「' + _query + '」が見つかりませんでした。';
                Say.say(text);
            }, 1000);
            changeState(States.NOT_FOUND);
        }
    }


    public function showImage(url:String):void {
        _currentImage.load(url);
    }


    public function print(file:File, profile:String):void {
        _conveyor.print(profile, file);
    }


    public function cancel():void {
        _conveyor.cancelJobs();
    }


    public function changeState(state:String):void {
        _stateMachine.changeState(state);
    }


    public function get container():Sprite {
        return _container;
    }


    public function get modelChanged():Signal {
        return _modelChanged;
    }


    public function get query():String {
        return _query;
    }


    public function set query(value:String):void {
        if (_query != value) {
            _query = value;
            _modelChanged.dispatch('query');
        }
    }


    public function get results():Array {
        return _results;
    }


    public function set results(value:Array):void {
        _results = value;
        _modelChanged.dispatch('results');
    }


    public function get selectedIndex():int {
        return _selectedIndex;
    }


    public function set selectedIndex(value:int):void {
        _selectedIndex = value;
        _modelChanged.dispatch('selectedIndex');
    }


    public function get progress():Number {
        return _progress;
    }


    public function set progress(value:Number):void {
        _progress = value;
        _modelChanged.dispatch('progress');
    }
}
}
