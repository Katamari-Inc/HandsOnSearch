/**
 * AS3 ported version of GCode Analyzer. This class is used for estimate the printing time from provided GCode.
 * @author hudbrog
 * @author Saqoosha
 * @see https://github.com/hudbrog/gCodeViewer
 * @see http://www.thingiverse.com/thing:35248
 */
package utils {

public class GCodeAnalyzer {

    public var gcode:Array;
    public var z_heights:Object = {};
    public var model:Array = [];
    public var max:Object = {x: undefined, y: undefined, z: undefined};
    public var min:Object = {x: undefined, y: undefined, z: undefined};
    public var modelSize:Object = {x: undefined, y: undefined, z: undefined};
    public var filamentByLayer:Object = {};
    public var totalFilament:Number = 0;
    public var printTime:Number = 0;
    public var printTimeByLayer:Object = {};
    public var layerHeight:Number = 0;
    public var layerCnt:Number = 0;
    public var speeds:Object = {extrude: [], retract: [], move: []};
    public var speedsByLayer:Object = {extrude: {}, retract: {}, move: {}};
    public var volSpeeds:Array = [];
    public var volSpeedsByLayer:Object = {};
    public var extrusionSpeeds:Array = [];
    public var extrusionSpeedsByLayer:Object = {};


    public function GCodeAnalyzer() {
    }


    public function analyze(rawGcode:String):Number {
        init();
        gcode = rawGcode.split(/\n/);
        doParse();
        analyzeModel();
        return printTime;
    }


    private function init():void {
        gcode = undefined;
        z_heights = {};
        model = [];
        max = {x: undefined, y: undefined, z: undefined};
        min = {x: undefined, y: undefined, z: undefined};
        modelSize = {x: undefined, y: undefined, z: undefined};
        filamentByLayer = {};
        totalFilament = 0;
        printTime = 0;
        printTimeByLayer = {};
        layerHeight = 0;
        layerCnt = 0;
        speeds = {extrude: [], retract: [], move: []};
        speedsByLayer = {extrude: {}, retract: {}, move: {}};
    }


    private function purgeLayers():void {
        var purge:Boolean = true;
        for (var i:int = 0; i < model.length; i++) {
            purge = true;
            if (!model[i]) {
                purge = true;
            }
            else {
                for (var j:int = 0; j < model[i].length; j++) {
                    if (model[i][j].extrude) {
                        purge = false;
                    }
                }
            }
            if (!purge) {
                layerCnt += 1;
            }
        }
    }


    private function analyzeModel():void {
        var i:int;
        var j:int;
        var x_ok:Boolean = false;
        var y_ok:Boolean = false;
        var cmds:Array;
        var tmp1:Number = 0;
        var tmp2:Number = 0;
        var speedIndex:int = 0;
        var type:String;
        var printTimeAdd:Number = 0;

        for (i = 0; i < model.length; i++) {
            cmds = model[i];
            if (!cmds) {
                continue;
            }
            for (j = 0; j < cmds.length; j++) {
                x_ok = false;
                y_ok = false;
                if (typeof(cmds[j].x) !== 'undefined' && typeof(cmds[j].prevX) !== 'undefined' && typeof(cmds[j].extrude) !== 'undefined' && cmds[j].extrude && !isNaN(cmds[j].x)) {
                    max.x = parseFloat(max.x) > parseFloat(cmds[j].x) ? parseFloat(max.x) : parseFloat(cmds[j].x);
                    max.x = parseFloat(max.x) > parseFloat(cmds[j].prevX) ? parseFloat(max.x) : parseFloat(cmds[j].prevX);
                    min.x = parseFloat(min.x) < parseFloat(cmds[j].x) ? parseFloat(min.x) : parseFloat(cmds[j].x);
                    min.x = parseFloat(min.x) < parseFloat(cmds[j].prevX) ? parseFloat(min.x) : parseFloat(cmds[j].prevX);
                    x_ok = true;
                }

                if (typeof(cmds[j].y) !== 'undefined' && typeof(cmds[j].prevY) !== 'undefined' && typeof(cmds[j].extrude) !== 'undefined' && cmds[j].extrude && !isNaN(cmds[j].y)) {
                    max.y = parseFloat(max.y) > parseFloat(cmds[j].y) ? parseFloat(max.y) : parseFloat(cmds[j].y);
                    max.y = parseFloat(max.y) > parseFloat(cmds[j].prevY) ? parseFloat(max.y) : parseFloat(cmds[j].prevY);
                    min.y = parseFloat(min.y) < parseFloat(cmds[j].y) ? parseFloat(min.y) : parseFloat(cmds[j].y);
                    min.y = parseFloat(min.y) < parseFloat(cmds[j].prevY) ? parseFloat(min.y) : parseFloat(cmds[j].prevY);
                    y_ok = true;
                }

                if (typeof(cmds[j].prevZ) !== 'undefined' && typeof(cmds[j].extrude) !== 'undefined' && cmds[j].extrude && !isNaN(cmds[j].prevZ)) {
                    max.z = parseFloat(max.z) > parseFloat(cmds[j].prevZ) ? parseFloat(max.z) : parseFloat(cmds[j].prevZ);
                    min.z = parseFloat(min.z) < parseFloat(cmds[j].prevZ) ? parseFloat(min.z) : parseFloat(cmds[j].prevZ);
                }

                if (typeof(cmds[j].extrude) !== 'undefined' || cmds[j].retract != 0) {
                    totalFilament += cmds[j].extrusion;
                    if (!filamentByLayer[cmds[j].prevZ]) {
                        filamentByLayer[cmds[j].prevZ] = 0;
                    }
                    filamentByLayer[cmds[j].prevZ] += cmds[j].extrusion;
                }

                if (x_ok && y_ok) {
                    printTimeAdd = Math.sqrt(Math.pow(parseFloat(cmds[j].x) - parseFloat(cmds[j].prevX), 2) + Math.pow(parseFloat(cmds[j].y) - parseFloat(cmds[j].prevY), 2)) / (cmds[j].speed / 60);
                }
                else if (cmds[j].retract === 0 && cmds[j].extrusion !== 0) {
                    tmp1 = Math.sqrt(Math.pow(parseFloat(cmds[j].x) - parseFloat(cmds[j].prevX), 2) + Math.pow(parseFloat(cmds[j].y) - parseFloat(cmds[j].prevY), 2)) / (cmds[j].speed / 60);
                    tmp2 = Math.abs(parseFloat(cmds[j].extrusion) / (cmds[j].speed / 60));
                    printTimeAdd = tmp1 >= tmp2 ? tmp1 : tmp2;
                }
                else if (cmds[j].retract !== 0) {
                    printTimeAdd = Math.abs(parseFloat(cmds[j].extrusion) / (cmds[j].speed / 60));
                }

                printTime += printTimeAdd;
                if (typeof(printTimeByLayer[cmds[j].prevZ]) === 'undefined') {
                    printTimeByLayer[cmds[j].prevZ] = 0;
                }
                printTimeByLayer[cmds[j].prevZ] += printTimeAdd;

                if (cmds[j].extrude && cmds[j].retract === 0) {
                    type = 'extrude';
                }
                else if (cmds[j].retract !== 0) {
                    type = 'retract';
                }
                else if (!cmds[j].extrude && cmds[j].retract === 0) {
                    type = 'move';
                }
                else {
//                    self.postMessage({cmd: 'unknown type of move'});
                    type = 'unknown';
                }
                speedIndex = speeds[type].indexOf(cmds[j].speed);
                if (speedIndex === -1) {
                    speeds[type].push(cmds[j].speed);
                    speedIndex = speeds[type].indexOf(cmds[j].speed);
                }
                if (typeof(speedsByLayer[type][cmds[j].prevZ]) === 'undefined') {
                    speedsByLayer[type][cmds[j].prevZ] = [];
                }
                if (speedsByLayer[type][cmds[j].prevZ].indexOf(cmds[j].speed) === -1) {
                    speedsByLayer[type][cmds[j].prevZ][speedIndex] = cmds[j].speed;
                }

                if (cmds[j].extrude && cmds[j].retract === 0 && x_ok && y_ok) {
                    // we are extruding
                    var volPerMM:* = cmds[j].volPerMM;
                    volPerMM = parseFloat(volPerMM).toFixed(3);
                    var volIndex:int = volSpeeds.indexOf(volPerMM);
                    if (volIndex === -1) {
                        volSpeeds.push(volPerMM);
                        volIndex = volSpeeds.indexOf(volPerMM);
                    }
                    if (typeof(volSpeedsByLayer[cmds[j].prevZ]) === 'undefined') {
                        volSpeedsByLayer[cmds[j].prevZ] = [];
                    }
                    if (volSpeedsByLayer[cmds[j].prevZ].indexOf(volPerMM) === -1) {
                        volSpeedsByLayer[cmds[j].prevZ][volIndex] = volPerMM;
                    }

                    var extrusionSpeed:* = volPerMM * cmds[j].speed;
                    extrusionSpeed = parseFloat(extrusionSpeed).toFixed(3);
                    volIndex = extrusionSpeeds.indexOf(extrusionSpeed);
                    if (volIndex === -1) {
                        extrusionSpeeds.push(extrusionSpeed);
                        volIndex = extrusionSpeeds.indexOf(extrusionSpeed);
                    }
                    if (typeof(extrusionSpeedsByLayer[cmds[j].prevZ]) === 'undefined') {
                        extrusionSpeedsByLayer[cmds[j].prevZ] = [];
                    }
                    if (extrusionSpeedsByLayer[cmds[j].prevZ].indexOf(extrusionSpeed) === -1) {
                        extrusionSpeedsByLayer[cmds[j].prevZ][volIndex] = extrusionSpeed;
                    }
                }


            }
//            sendSizeProgress(i / model.length * 100);

        }
        purgeLayers();

        modelSize.x = Math.abs(max.x - min.x);
        modelSize.y = Math.abs(max.y - min.y);
        modelSize.z = Math.abs(max.z - min.z);
        layerHeight = (max.z - min.z) / (layerCnt - 1);
    }


    private function doParse():void {
        var argChar:String;
        var numSlice:String;
        model = [];
//        var sendLayer = undefined;
//        var sendLayerZ = 0;
//        var sendMultiLayer:Array = [];
//        var sendMultiLayerZ:Array = [];
//        var lastSend = 0;
        var reg:RegExp = new RegExp(/^(?:G0|G1)\s/i);
        var i:int;
        var j:int;
        var layer:Number = 0;
        var extrude:Boolean = false;
        var prevRetract:Number = 0;
        var retract:* = 0;
        var x:*;
        var y:*;
        var z:* = 0;
        var f:*;
        var prevZ:* = 0;
        var prevX:*;
        var prevY:*;
        var lastF:* = 4000;
        var prev_extrude:Object = {a: undefined, b: undefined, c: undefined, e: undefined, abs: undefined};
        var extrudeRelative:Boolean = false;
        var volPerMM:Number;
        var dcExtrude:Boolean = false;
        var assumeNonDC:Boolean = false;
        var args:Array;

        for (i = 0; i < gcode.length; i++) {
            x = undefined;
            y = undefined;
            z = undefined;
            volPerMM = undefined;
            retract = 0;

            extrude = false;
            gcode[i] = gcode[i].split(/[\(;]/)[0];

            if (reg.test(gcode[i])) {
                args = gcode[i].split(/\s/);
                for (j = 0; j < args.length; j++) {
                    switch (argChar = args[j].charAt(0).toLowerCase()) {
                        case 'x':
                        {
                            x = args[j].slice(1);
                            break;
                        }
                        case 'y':
                        {
                            y = args[j].slice(1);
                            break;
                        }
                        case 'z':
                        {
                            z = args[j].slice(1);
                            z = Number(z);
                            if (z == prevZ) {
                                continue;
                            }
                            if (z_heights.hasOwnProperty(z)) {
                                layer = z_heights[z];
                            }
                            else {
                                layer = model.length;
                                z_heights[z] = layer;
                            }
//                            sendLayer = layer;
//                            sendLayerZ = z;
                            prevZ = z;
                            break;
                        }
                        case 'e':
                        case 'a':
                        case 'b':
                        case 'c':
                        {
                            assumeNonDC = true;
                            numSlice = parseFloat(args[j].slice(1)).toFixed(3);

                            if (!extrudeRelative) {
                                prev_extrude["abs"] = parseFloat(numSlice) - parseFloat(prev_extrude[argChar]);
                            }
                            else {
                                prev_extrude["abs"] = parseFloat(numSlice);
                            }
                            extrude = prev_extrude["abs"] > 0;
                            if (prev_extrude["abs"] < 0) {
                                prevRetract = -1;
                                retract = -1;
                            }
                            else if (prev_extrude["abs"] == 0) {
                                retract = 0;
                            }
                            else if (prev_extrude["abs"] > 0 && prevRetract < 0) {
                                prevRetract = 0;
                                retract = 1;
                            }
                            else {
                                retract = 0;
                            }
                            prev_extrude[argChar] = numSlice;

                            break;
                        }
                        case 'f':
                        {
                            numSlice = args[j].slice(1);
                            lastF = numSlice;
                            break;
                        }
                        default:
                        {
                            break;
                        }
                    }
                }
                if (dcExtrude && !assumeNonDC) {
                    extrude = true;
                    prev_extrude["abs"] = Math.sqrt((prevX - x) * (prevX - x) + (prevY - y) * (prevY - y));
                }
                if (extrude && retract == 0) {
                    volPerMM = Number(prev_extrude['abs'] / Math.sqrt((prevX - x) * (prevX - x) + (prevY - y) * (prevY - y)));
                }
                if (!model[layer]) {
                    model[layer] = [];
                }
                if (typeof(x) !== 'undefined' || typeof(y) !== 'undefined' || typeof(z) !== 'undefined' || retract != 0) {
                    model[layer][model[layer].length] = {x: Number(x), y: Number(y), z: Number(z), extrude: extrude, retract: Number(retract), noMove: false, extrusion: (extrude || retract) ? Number(prev_extrude["abs"]) : 0, prevX: Number(prevX), prevY: Number(prevY), prevZ: Number(prevZ), speed: Number(lastF), gcodeLine: Number(i), volPerMM: typeof(volPerMM) === 'undefined' ? -1 : volPerMM.toFixed(3)};
                }
                if (typeof(x) !== 'undefined') {
                    prevX = x;
                }
                if (typeof(y) !== 'undefined') {
                    prevY = y;
                }
            }
            else if (gcode[i].match(/^(?:M82)/i)) {
                extrudeRelative = false;
            }
            else if (gcode[i].match(/^(?:G91)/i)) {
                extrudeRelative = true;
            }
            else if (gcode[i].match(/^(?:G90)/i)) {
                extrudeRelative = false;
            }
            else if (gcode[i].match(/^(?:M83)/i)) {
                extrudeRelative = true;
            }
            else if (gcode[i].match(/^(?:M101)/i)) {
                dcExtrude = true;
            }
            else if (gcode[i].match(/^(?:M103)/i)) {
                dcExtrude = false;
            }
            else if (gcode[i].match(/^(?:G92)/i)) {
                args = gcode[i].split(/\s/);
                for (j = 0; j < args.length; j++) {
                    switch (argChar = args[j].charAt(0).toLowerCase()) {
                        case 'x':
                        {
                            x = args[j].slice(1);
                            break;
                        }
                        case 'y':
                        {
                            y = args[j].slice(1);
                            break;
                        }
                        case 'z':
                        {
                            z = args[j].slice(1);
                            prevZ = z;
                            break;
                        }
                        case 'e' || 'a' || 'b' || 'c':
                        {
                            numSlice = args[j].slice(1);
                            if (!extrudeRelative) {
                                prev_extrude[argChar] = 0;
                            }
                            else {
                                prev_extrude[argChar] = numSlice;
                            }
                            break;
                        }
                        default:
                        {
                            break;
                        }
                    }
                }
                if (!model[layer]) {
                    model[layer] = [];
                }
                if (typeof(x) !== 'undefined' || typeof(y) !== 'undefined' || typeof(z) !== 'undefined') {
                    model[layer][model[layer].length] = {
                        x: parseFloat(x),
                        y: parseFloat(y),
                        z: parseFloat(z),
                        extrude: extrude,
                        retract: parseFloat(retract),
                        noMove: true,
                        extrusion: (extrude || retract) ? parseFloat(prev_extrude["abs"]) : 0,
                        prevX: parseFloat(prevX),
                        prevY: parseFloat(prevY),
                        prevZ: parseFloat(prevZ),
                        speed: parseFloat(lastF),
                        gcodeLine: i
                    };
                }
            }
            else if (gcode[i].match(/^(?:G28)/i)) {
                args = gcode[i].split(/\s/);
                for (j = 0; j < args.length; j++) {
                    switch (argChar = args[j].charAt(0).toLowerCase()) {
                        case 'x':
                        {
                            x = args[j].slice(1);
                            break;
                        }
                        case 'y':
                        {
                            y = args[j].slice(1);
                            break;
                        }
                        case 'z':
                        {
                            z = args[j].slice(1);
                            z = Number(z);
                            if (z === prevZ) {
                                continue;
                            }
//                            sendLayer = layer;
//                            sendLayerZ = z;//}
                            if (z_heights.hasOwnProperty(z)) {
                                layer = z_heights[z];
                            }
                            else {
                                layer = model.length;
                                z_heights[z] = layer;
                            }
                            prevZ = z;
                            break;
                        }
                        default:
                        {
                            break;
                        }
                    }
                }
                // G28 with no arguments
                if (args.length == 1) {
                    //need to init values to default here
                }
                // if it's the first layer and G28 was without
                if (layer == 0 && typeof(z) === 'undefined') {
                    z = 0;
                    if (z_heights.hasOwnProperty(z)) {
                        layer = z_heights[z];
                    }
                    else {
                        layer = model.length;
                        z_heights[z] = layer;
                    }
                    prevZ = z;
                }

                if (!model[layer]) {
                    model[layer] = [];
                }
                if (typeof(x) !== 'undefined' || typeof(y) !== 'undefined' || typeof(z) !== 'undefined' || retract != 0) {
                    model[layer][model[layer].length] = {
                        x: Number(x),
                        y: Number(y),
                        z: Number(z),
                        extrude: extrude,
                        retract: Number(retract),
                        noMove: false,
                        extrusion: (extrude || retract) ? Number(prev_extrude["abs"]) : 0,
                        prevX: Number(prevX),
                        prevY: Number(prevY),
                        prevZ: Number(prevZ),
                        speed: Number(lastF),
                        gcodeLine: Number(i)
                    };
                }
            }
//            if (typeof(sendLayer) !== "undefined")
//            {
//                if (i - lastSend > gcode.length * 0.02 && sendMultiLayer.length != 0)
//                {
//                    lastSend = i;
//                    sendMultiLayer = [];
//                    sendMultiLayerZ = [];
//                }
//                sendMultiLayer[sendMultiLayer.length] = sendLayer;
//                sendMultiLayerZ[sendMultiLayerZ.length] = sendLayerZ;
//                sendLayer = undefined;
//                sendLayerZ = undefined;
//            }
        }
    }


    private function getResults():Object {
        return {
            max: max,
            min: min,
            modelSize: modelSize,
            totalFilament: totalFilament,
            filamentByLayer: filamentByLayer,
            printTime: printTime,
            layerHeight: layerHeight,
            layerCnt: layerCnt,
            layerTotal: model.length,
            speeds: speeds,
            speedsByLayer: speedsByLayer,
            volSpeeds: volSpeeds,
            volSpeedsByLayer: volSpeedsByLayer,
            printTimeByLayer: printTimeByLayer,
            extrusionSpeeds: extrusionSpeeds,
            extrusionSpeedsByLayer: extrusionSpeedsByLayer
        };
    }
}
}
