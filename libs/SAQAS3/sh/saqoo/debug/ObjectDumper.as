/**
 * デバッグ用ユーティリティクラス
 *
 * TODO:
 * -プリミティヴ型変数の判定部分が適当なので、不具合があったら直す
 *
 * @author kjirou <kjirou.web[at-mark]gmail.com>
 *				  <http://kjirou.sakura.ne.jp/mt/>
 * @license MIT License http://www.opensource.org/licenses/mit-license.php
 */
package sh.saqoo.debug {

	import flash.geom.Matrix3D;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	public class ObjectDumper extends Object {


		/**
		 * 変数の内容をダンプして文字列として返す
		 *
		 * @param foo			 ダンプ対象の変数
		 * @param maxObjectNests Object型の情報を何階層まで出力するか
		 * @param level			 現在の階層、再帰呼び出しでのみ使用するので設定不要
		 * @param label			 出力に付くラベル、再帰呼び出しでのみ使用するので設定不要
		 */
		public static function dumpToText(data:*, maxObjectNests:Number = 5, level:int = 0, label:String = ''):String {
			var out:String = '';
			var pad:String = '';
			var i:int = 0;
			for (i = 0; i < level; i++) pad += '    ';

			switch (true) {
				case data is Boolean:
				case data is Number:
				case data is int:
				case data is uint:
				case data is String:
				case data === undefined:
				case data === null:
					out += pad + label + '(' + typeof data + ') ' + data + '\n';
					break;
				default:
					var type:String = getQualifiedClassName(data);
					var vecType:String = '';
					var match:Array = type.match(/__AS3__\.vec::Vector\.<(.*)>/);
					if (match) {
						type = 'Vector';
						vecType = '.<' + match[1].replace(/::/g, '.') + '>';
					}
					switch (type) {
						case 'Array':
						case 'Vector':
							out += pad + label + '(' + typeof data + ') [' + type + vecType + ' size = ' + data.length + ']\n';
							var n:int = Math.min(data.length, 100);
							for (i = 0; i < n; i++) {
								out += arguments.callee(data[i], maxObjectNests, level + 1, '[' + i + '] = ');
							}
							if (n < data.length) {
								out += pad + '	... abbreviated ...\n';
							}
							break;
						case 'flash.utils::ByteArray':
							out += pad + label + '(object) [ByteArray length = ' + ByteArray(data).length + ']\n';
							break;
						case 'flash.display::BitmapData':
							out += pad + label + '(object) [BitmapData width = ' + BitmapData(data).width + ' height = ' + BitmapData(data).height + ']\n';
							break;
//						case 'flash.geom::Matrix3D':
//							var r:Vector.<Number> = Matrix3D(data).rawData;
//							out += pad + r[0].toPrecision(3) + ', ' + r[1].toPrecision(3) + ', ' + r[2].toPrecision(3) + ', ' + r[3].toPrecision(3) + ',\n';
//							out += pad + r[4].toPrecision(3) + ', ' + r[5].toPrecision(3) + ', ' + r[6].toPrecision(3) + ', ' + r[7].toPrecision(3) + ',\n';
//							out += pad + r[8].toPrecision(3) + ', ' + r[9].toPrecision(3) + ', ' + r[10].toPrecision(3) + ', ' + r[11].toPrecision(3) + ',\n';
//							out += pad + r[12].toPrecision(3) + ', ' + r[13].toPrecision(3) + ', ' + r[14].toPrecision(3) + ', ' + r[15].toPrecision(3) + '\n';
//							break;
						default:
							out += pad + label + '(' + typeof data + ') ' + data + '\n';
							if (level < maxObjectNests) {
								var keys:Array = [];
								for (var key:* in data) keys.push(key);
								for each (key in keys.sort()) {
									out += arguments.callee(data[key], maxObjectNests, level + 1, key + ' = ');
								}
							} else {
								out += pad + '	... abbreviated ...\n';
							}
							break;
					}
					break;
			}
			return out;
		}


		/**
		 * 変数の内容をダンプする
		 *
		 * @param foo			 dumpToText参照
		 * @param maxObjectNests dumpToText参照
		 */
		public static function dump(data:*, maxObjectNests:Number = 10):void {
			trace(dumpToText(data, maxObjectNests));
		}
	}
}
