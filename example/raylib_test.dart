import 'package:tessera/tessera.dart';
import 'package:raylib/raylib.dart' as rl;
import 'package:raylib/src/modules/core/misc.dart' as misc;

void main() {
	rl.initLibrary(windows: getRaylibPath());

	misc.setConfigFlags(
		rl.ConfigFlags.msaa4xHint |
		rl.ConfigFlags.windowHighDPI
	);

	rl.initWindow(800, 600, "Smooth Test");

	while (!rl.windowShouldClose()) {
		rl.beginDrawing();
		rl.clearBackground(rl.Color.white);

		rl.drawCircle(400, 300, 150, rl.Color.black);

		rl.endDrawing();
	}

	rl.closeWindow();
}
