/**
 * @author Saqoosha
 */
package ui {

import com.bit101.components.HBox;
import com.bit101.components.Label;
import com.bit101.components.ProgressBar;
import com.bit101.components.VBox;
import com.bit101.components.Window;

import flash.display.DisplayObjectContainer;

public class PrinterStatusWindow extends Window {

    private var _statusLabel:Label;
    private var _progressBar:ProgressBar;
    private var _timeLabel:Label;


    public function PrinterStatusWindow(parent:DisplayObjectContainer = null) {
        super(parent, 10, 10, 'PRINTER INFO');
        width = 400;
        height = 100;
        var vbox:VBox = new VBox(content, 10, 10);
        _statusLabel = new Label(vbox, 0, 0, 'STATUS:');
        _statusLabel.autoSize = true;
        var hbox:HBox = new HBox(vbox);
        new Label(hbox, 0, 0, 'PROGRESS:');
        _progressBar = new ProgressBar(hbox, 0, 4);
        _progressBar.width = 200;
        _timeLabel = new Label(hbox);
        _timeLabel.autoSize = true;
    }


    public function set state(value:String):void {
        _statusLabel.text = 'STATUS: ' + value.toUpperCase();
    }


    public function set progress(value:Number):void {
        _progressBar.value = value;
    }
}
}
