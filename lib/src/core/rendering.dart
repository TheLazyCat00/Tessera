import 'package:tessera/src/types.dart';
import 'package:raylib/raylib.dart' as rl;
import 'dart:io';


void renderWidget(Widget widget) {
	Area<Pixel> area = Area(Vector2.zero(), Vector2(rl.getScreenWidth(), rl.getScreenHeight()));
	var buffer = widget.renderCallback((area: area));

	rl.beginDrawing();
	drawBuffer(buffer, Vector2(0, 0));
	rl.endDrawing();
}

void drawBuffer(rl.RenderTexture2D buffer, Vector2<Pixel> position) {
	final textureWidth = buffer.texture.width.toDouble();
	final textureHeight = buffer.texture.height.toDouble();

	final source = rl.Rectangle(
		textureWidth,
		0,
		textureWidth,
		- textureHeight,
	);

	rl.drawTextureRec(buffer.texture, source, position.toRaylib(), rl.Color.white);
}

String getRaylibPath() {
	// 1. Check current directory
	if (File('raylib.dll').existsSync()) {
		return 'raylib.dll';
	}

	// 2. Check RAYLIB_PATH environment variable
	final envPath = Platform.environment['RAYLIB_PATH'];
	if (envPath != null && File(envPath).existsSync()) {
		return envPath;
	}

	// 3. Try scoop prefix command (Windows)
	if (Platform.isWindows) {
		try {
			final result = Process.runSync('scoop', ['prefix', 'raylib'], runInShell: true);
			if (result.exitCode == 0) {
				final scoopPath = result.stdout.toString().trim();
				final dllPath = '$scoopPath\\lib\\raylib.dll';
				if (File(dllPath).existsSync()) {
					return dllPath;
				}
			}
		} catch (_) {
			// scoop not available
		}
	}

	throw Exception(
		'raylib.dll not found. Options:\n'
		'  1. Copy raylib.dll to your project directory\n'
		'  2. Set RAYLIB_PATH environment variable\n'
		'  3. Install via: scoop install raylib'
	);
}
