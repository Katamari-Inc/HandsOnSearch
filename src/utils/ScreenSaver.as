/**
 * @author Saqoosha
 */
package utils {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class ScreenSaver extends Sprite {
    private static const TIMEOUT:Number = 10;
    private var _enabled:Boolean = false;
    private var _timer:Timer = new Timer(TIMEOUT * 60000, 1);

    public function ScreenSaver() {
        visible = false;
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, 1024, 768);
        graphics.endFill();

        _timer.stop();
        _timer.addEventListener(TimerEvent.TIMER, _handleTimer);
    }

    public function get enabled():Boolean {
        return _enabled;
    }

    public function set enabled(value:Boolean):void {
        if (_enabled != value) {
            _enabled = value;
            if (_enabled) {
                stage.addEventListener(MouseEvent.MOUSE_MOVE, _handleAction);
                stage.addEventListener(MouseEvent.MOUSE_DOWN, _handleAction);
                stage.addEventListener(KeyboardEvent.KEY_DOWN, _handleAction);
                _timer.start();
            }
            else {
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, _handleAction);
                stage.removeEventListener(MouseEvent.MOUSE_DOWN, _handleAction);
                stage.removeEventListener(KeyboardEvent.KEY_DOWN, _handleAction);
                _timer.stop();
            }
        }
    }

    public function get saving():Boolean {
        return visible;
    }

    public function action():void {
        _handleAction(null);
    }

    private function _handleAction(e:Event):void {
        visible = false;
        _timer.reset();
        _timer.start();
    }

    public function _handleTimer(e:TimerEvent):void {
        visible = true;
    }
}
}
