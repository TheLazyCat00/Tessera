import 'package:tessera/tessera.dart';

import 'package:raylib/raylib.dart' as rl;
import 'package:raylib/src/modules/text/font.dart' as rl;

rl.Font _globalFont = rl.getFontDefault();

void setGlobalFont(rl.Font font) {
	_globalFont = font;
}

rl.Font getGlobalFont() {
	return _globalFont;
}
