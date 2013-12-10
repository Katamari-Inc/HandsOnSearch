/**
 * @author Saqoosha
 */
package states {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class NotFoundState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:NotFoundPage;
    private var _timer:Timer;


    public function NotFoundState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            if (name == 'query') {
                _view.queryField.text = _app.query;
            }
        });
        _view = new NotFoundPage();
        _view.queryField.text = _app.query;
        _view.queryField.embedFonts = false;
        _view.retryButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.INPUT_QUERY);
        });
        _timer = new Timer(10000, 1);
        _timer.addEventListener(TimerEvent.TIMER, _handleTimer);
    }


    override public function enter(event:Event):void {
        _app.container.addChild(_view);
        _timer.reset();
        _timer.start();
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
        _timer.stop();
    }


    private function _handleTimer(event:TimerEvent):void {
        _app.changeState(States.INPUT_QUERY);
    }
}
}
