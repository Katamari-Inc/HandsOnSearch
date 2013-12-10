/**
 * @author Saqoosha
 */
package utils {

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.getTimer;

public class ScreenUpdater extends Sprite {
    public function ScreenUpdater() {
        graphics.beginFill(0x808080);
        graphics.moveTo(0, 0);
        graphics.lineTo(2, 0);
        graphics.lineTo(0, 2);
        graphics.endFill();
        addEventListener(Event.ENTER_FRAME, _handleEnterFrame);
    }

    private function _handleEnterFrame(event:Event):void {
        alpha = Math.sin(getTimer() / 1000) * 0.5 + 0.5;
    }
}
}
