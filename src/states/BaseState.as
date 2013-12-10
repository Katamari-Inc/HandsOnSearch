/**
 * @author Saqoosha
 */
package states {

import flash.events.Event;

public class BaseState {

    public function get from():* {
        return '*';
    }


    public function get parent():String {
        return null;
    }


    public function enter(event:Event):void {
        trace('Entering state');
    }


    public function exit(event:Event):void {
        trace('Exiting state');
    }
}
}
