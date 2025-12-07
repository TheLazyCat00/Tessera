import 'dart:typed_data';
import 'dart:io';
import 'package:raylib/raylib.dart' hide Vector2, Uint32List;

import 'aliases.dart';
import 'helpers.dart';

typedef RenderCallback = RgbaSurface Function(RenderContext);
typedef RenderContext = ({
	Dimension2<Pixel> dimensions
});

typedef SizeCallback = Pixel Function(SizeContext);
typedef SizeContext = ({
	Dimension2<Pixel> dimensions
});

class Border<T> {
	T top;
	T left;
	T bottom;
	T right;

	Border(
		this.top,
		this.left,
		this.bottom,
		this.right
	);
}

typedef Widget = ({
	RenderCallback renderCallback,
	Vector2<Cell> topLeft,
	Vector2<Cell> bottomRight,
});

abstract class PixelSurface {
	Dimension2<Pixel> getDimensions();
	
	/// Returns pixel data as Uint32List for RGBA pixels.
	/// Each element encodes RGBA: 0xRRGGBBAA
	/// Row-major order: pixel at (x, y) is at index (y * width + x)
	Uint32List getPixels();
}

class RgbaSurface extends PixelSurface {
	final Dimension2<Pixel> _dimensions;
	final Uint32List _pixels;

	RgbaSurface(Dimension2<Pixel> dimensions, { Uint32List? initialPixels }):
		_dimensions = dimensions,
		_pixels = initialPixels ?? Uint32List(dimensions.x * dimensions.y);

	@override
	Dimension2<Pixel> getDimensions() => _dimensions;

	@override
	Uint32List getPixels() => _pixels;

	/// Set pixel at (x, y) to RGBA color
	void setPixel(Pixel x, Pixel y, int rgba) {
		if (x >= 0 && x < _dimensions.x && y >= 0 && y < _dimensions.y) {
			_pixels[y * _dimensions.x + x] = rgba;
		}
	}

	/// Get pixel at (x, y)
	int getPixel(Pixel x, Pixel y) {
		if (x >= 0 && x < _dimensions.x && y >= 0 && y < _dimensions.y) {
			return _pixels[y * _dimensions.x + x];
		}
		return 0; // Return transparent black for out-of-bounds
	}

	/// Fill entire surface with RGBA color
	void fill(int rgba) {
		_pixels.fillRange(0, _pixels.length, rgba);
	}

	/// Insert another surface at the given position
	void insertSurface(Vector2<Pixel> position, RgbaSurface source) {
		final sourceDimensions = source.getDimensions();
		final sourcePixels = source.getPixels();

		for (Pixel sy = 0; sy < sourceDimensions.y; sy++) {
			for (Pixel sx = 0; sx < sourceDimensions.x; sx++) {
				final destPos = Vector2(position.x + sx, position.y + sy);

				if (destPos.x >= 0 && destPos.x < _dimensions.x && destPos.y >= 0 && destPos.y < _dimensions.y) {
					final sourcePixel = sourcePixels[sy * sourceDimensions.x + sx];
					setPixel(destPos.x, destPos.y, sourcePixel);
				}
			}
		}
	}

	/// Create a copy of this surface
	RgbaSurface clone() {
		return RgbaSurface(_dimensions, initialPixels: Uint32List.fromList(_pixels));
	}
}

/// Finds the raylib.dll path by checking common locations
String _findRaylibPath() {
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

class PixelRenderer {
	RgbaSurface surface;

	PixelRenderer(this.surface, {String? libraryPath}) {
		final path = libraryPath ?? _findRaylibPath();
		initLibrary(windows: path);

		final dimensions = surface.getDimensions();
		initWindow(dimensions.x, dimensions.y, 'Pixel Surface');
		setTargetFPS(60);
	}

	void render() {
		final dimensions = surface.getDimensions();
		final pixelData = surface.getPixels();

		beginDrawing();
		clearBackground(Color.black);

		// Draw pixels directly
		for (int y = 0; y < dimensions.y; y++) {
			for (int x = 0; x < dimensions.x; x++) {
				final rgba = pixelData[y * dimensions.x + x];
				final color = Color(
					(rgba >> 24) & 0xFF, // R
					(rgba >> 16) & 0xFF, // G
					(rgba >> 8) & 0xFF,  // B
					rgba & 0xFF,         // A
				);
				drawPixel(x, y, color);
			}
		}

		endDrawing();
	}

	bool shouldClose() => windowShouldClose();

	void cleanup() {
		closeWindow();
	}
}


