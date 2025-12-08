import 'package:raylib/raylib.dart' as rl hide Vector2;
import 'package:tessera/src/types.dart';

typedef RenderCallback = void Function(rl.RenderTexture2D buffer, RenderContext renderContext);
typedef RenderContext = ({
	Area<Pixel> area,
});

typedef SizeCallback = Pixel Function(SizeContext sizeContext);
typedef SizeContext = ({
	Dimension2<Pixel> dimensions
});

typedef AnimationCallback = double Function();

class Animation {
	double _time;
	double _value;
	double _timeSinceUpdate;

	Animation(this._value, this._time):
		_timeSinceUpdate = rl.getTime();

	void setValue(double value) {
		if (_value == value) return;

		_value = value;
		_timeSinceUpdate = rl.getTime();
	}

	void setTime(double time) {
		if (_time == _time) return;

		_time = time;
		_timeSinceUpdate = rl.getTime();
	}

	AnimationCallback getValue = () {
		return "hi";
	}
}

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
	late rl.RenderTexture2D Function(RenderContext) renderCallback;
	int zIndex;

	RenderContext? _prevRenderCallContext;
	late rl.RenderTexture2D _buffer;

	Widget(this.area, RenderCallback renderCallback, { this.zIndex = 0 }) {
		this.renderCallback = ((renderContext) {
			if (_prevRenderCallContext != renderContext) {
				_buffer = rl.loadRenderTexture(renderContext.area.getDimensions().x, renderContext.area.getDimensions().y);
			}

			rl.beginTextureMode(_buffer);
			rl.clearBackground(rl.Color.rayWhite);
			rl.endTextureMode();

			renderCallback(_buffer, (area: renderContext.area));

			_prevRenderCallContext = renderContext;
			return _buffer;
		});
	}
}
