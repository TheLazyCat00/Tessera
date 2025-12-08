import 'package:raylib/raylib.dart' as rl hide Vector2;
import 'package:tessera/src/types.dart';

typedef RenderCallback = void Function(rl.RenderTexture2D buffer, RenderContext renderContext);
typedef RenderContext = ({
	Area<Pixel> area
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
	Area<Cell> area;
	late rl.RenderTexture2D Function(RenderContext renderContext) renderCallback;
	int zIndex;

	RenderContext? _prevRenderContext;
	late rl.RenderTexture2D _buffer;

	Widget(this.area, RenderCallback renderCallback, { this.zIndex = 0 }) {
		this.renderCallback = ((RenderContext renderContext) {
			if (_prevRenderContext != renderContext) {
				_buffer = rl.loadRenderTexture(renderContext.area.getDimensions().x, renderContext.area.getDimensions().y);
			}

			renderCallback(_buffer, renderContext);

			_prevRenderContext = renderContext;
			return _buffer;
		});
	}
}
