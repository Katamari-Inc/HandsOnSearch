/**
 * @author Saqoosha
 */
package states {

import flash.events.Event;
import flash.events.MouseEvent;

public class SelectModelState extends BaseState {

    private var _app:HandsOnSearch;
    private var _view:SelectModelPage;


    public function SelectModelState(app:HandsOnSearch) {
        _app = app;
        _app.modelChanged.add(function (name:String):void {
            switch (name) {
                case 'query':
                {
                    _view.queryField.text = _app.query;
                    break;
                }
                case 'results':
                {
                    _app.selectedIndex = 0;
                    _updateButtons();
                    if (_app.results.length) {
                        _showImage();
                    }
                    break;
                }
            }
        });
        _view = new SelectModelPage();
        _view.queryField.text = '';
        _view.queryField.embedFonts = false;
        _view.prevButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.selectedIndex--;
            _updateButtons();
            _showImage();
        });
        _view.nextButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.selectedIndex++;
            _updateButtons();
            _showImage();
        });
        _updateButtons();
        _view.printButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.PRINTING);
        });
        _view.retryButton.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
            _app.changeState(States.INPUT_QUERY);
        });
    }


    private function _updateButtons():void {
        _view.prevButton.visible = _app.selectedIndex > 0;
        _view.nextButton.visible = _app.selectedIndex < _app.results.length - 1;
    }


    private function _showImage():void {
        var data:Object = _app.results[_app.selectedIndex];
        _app.showImage(data.thumbnail_url);
    }


    override public function enter(event:Event):void {
        _app.container.addChild(_view);
    }


    override public function exit(event:Event):void {
        _app.container.removeChild(_view);
    }
}
}
