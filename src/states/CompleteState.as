/**
 * @author Saqoosha
 */
package states {

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class CompleteState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:Sprite;
    private var _queryField:TextField;
    private var _button:SimpleButton;


    public function CompleteState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            if (name == 'query') {
                _queryField.text = _app.query;
            }
        });
        _view = new CompletePage();
        _queryField = TextField(_view.getChildByName('queryField'));
        _queryField.text = _app.query;
        _queryField.embedFonts = false;
        _button = SimpleButton(_view.getChildByName('restartButton'));
        _button.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.INPUT_QUERY);
        });
    }


    override public function get from():* {
        return States.PRINTING;
    }


    override public function enter(event:Event):void {
        _app.container.addChild(_view);
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
    }
}
}
