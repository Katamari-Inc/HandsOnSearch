/**
 * @author Saqoosha
 */
package states {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

public class InputQueryState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:InputQueryPage;


    public function InputQueryState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            if (name == 'query') {
                _view.queryField.text = _app.query;
            }
        });
        _view = new InputQueryPage();
        _view.queryField.text = _app.query;
        _view.queryField.embedFonts = false;
        _view.searchButton.addEventListener(MouseEvent.CLICK, _handleSearchClick);
    }


    override public function enter(event:Event):void {
        _app.query = '';
        _app.container.addChild(_view);
        _app.stage.focus = _view.queryField;
        _view.queryField.addEventListener(KeyboardEvent.KEY_DOWN, _handleKeyDown);
        _view.queryField.addEventListener(Event.CHANGE, _handleChange);
    }


    private function _handleChange(event:Event):void {
        trace(_view.queryField.text);
    }


    private function _handleKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case Keyboard.ENTER:
                event.preventDefault();
                event.stopPropagation();
                _handleSearchClick(null);
                break;
        }
    }


    private function _handleSearchClick(event:MouseEvent):void {
        var q:String = _view.queryField.text.replace(/\s+/g, '');
        if (q.length) {
            _app.search(q);
        }
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
        _view.queryField.removeEventListener(KeyboardEvent.KEY_DOWN, _handleKeyDown);
    }
}
}
