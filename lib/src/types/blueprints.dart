import 'dart:math';

import 'package:raylib/raylib.dart' as rl hide Vector2;
import 'package:tessera/src/types.dart';

typedef RenderCallback = void Function(rl.RenderTexture2D buffer, RenderContext renderContext);
typedef RenderContext = ({
	Area<Pixels> area,
});

typedef SizeCallback = Pixels Function(SizeContext sizeContext);
typedef SizeContext = ({
	Dimension2<Pixels> dimensions
});

typedef AnimationFunc = double Function(double progressRatio);

class Animation {
	double _duration;
	double _to;
	double _from;
	double _timeSinceUpdate;
	AnimationFunc _func;

	Animation(double value, double duration, AnimationFunc func):
		_from = value,
		_to = value,
		_duration = duration,
		_func = func,
		_timeSinceUpdate = rl.getTime();

	void setValue(double value) {
		if (_to == value) return;

		var heightBefore = (_to - _from).abs();

		_from = getValue();
		_to = value;

		var heightAfter = (_to - _from).abs();

		double ratio;
		if (heightBefore == 0) {
			ratio = 1;
		}
		else {
			ratio = heightAfter / heightBefore;
		}

		_duration = _duration * ratio;
		_timeSinceUpdate = rl.getTime();
	}

	void setTime(double time) {
		if (_duration == time) return;

		_from = getValue();
		_duration = time;
		_timeSinceUpdate = rl.getTime();
	}

	double getValue () {
		var progressTime = rl.getTime() - _timeSinceUpdate;
		progressTime = min(progressTime, _duration);
		var progressRatio = progressTime / _duration;
		var height = _to - _from;

		var res = _from + _func(progressRatio) * height;
		return res;
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
	late rl.RenderTexture2D Function(RenderContext) renderCallback;
	int zIndex;

	RenderContext? _prevRenderCallContext;
	late rl.RenderTexture2D _buffer;

	Widget(RenderCallback renderCallback, { this.zIndex = 1 }) {
		this.renderCallback = ((renderContext) {
			if (_prevRenderCallContext != renderContext) {
				_buffer = rl.loadRenderTexture(renderContext.area.getDimensions().x, renderContext.area.getDimensions().y);
			}

			rl.setTextureFilter(_buffer.texture, rl.TextureFilter.bilinear);
			rl.beginTextureMode(_buffer);
			rl.clearBackground(rl.Color.rayWhite);
			rl.endTextureMode();

			renderCallback(_buffer, (area: renderContext.area));

			_prevRenderCallContext = renderContext;
			return _buffer;
		});
	}
}
