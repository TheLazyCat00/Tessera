import 'package:raylib/raylib.dart' as rl hide Vector2;
import 'aliases.dart';
import 'helpers.dart';

typedef RenderCallback = void Function(rl.RenderTexture2D buffer, RenderContext renderContext);
typedef RenderContext = ({
	Dimension2<Pixel> dimensions
});

typedef SizeCallback = Pixel Function(SizeContext sizeContext);
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

class Widget {
	Vector2<Cell> topLeft;
	Vector2<Cell> bottomRight;
	late rl.RenderTexture2D Function(RenderContext renderContext) renderCallback;
	int zIndex;

	RenderContext? _prevRenderContext;
	late rl.RenderTexture2D _buffer;

	Widget(this.topLeft, this.bottomRight, RenderCallback renderCallback, { this.zIndex = 0 }) {
		this.renderCallback = ((RenderContext renderContext) {
			if (_prevRenderContext != renderContext) {
				_buffer = rl.loadRenderTexture(renderContext.dimensions.x, renderContext.dimensions.y);
			}

			renderCallback(_buffer, renderContext);

			_prevRenderContext = renderContext;
			return _buffer;
		});
	}
}
