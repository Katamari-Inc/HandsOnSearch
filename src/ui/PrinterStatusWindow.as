/**
 Copyright (c) 2013, Yahoo Japan Corporation
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.

 3. Neither the name of  Yahoo Japan Corporation nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
