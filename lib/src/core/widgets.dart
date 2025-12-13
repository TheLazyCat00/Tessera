import 'dart:math';

import 'package:tessera/tessera.dart';
import 'package:raylib/raylib.dart' as rl;
import 'package:raylib/src/modules/text/font.dart' as rl;

typedef GridWidgetContext = ({ Widget widget, Area<Cells> area });

class Grid {
	Grid2<SizeCallback> grid;
	List<GridWidgetContext> widgets = [];
	Dimension2<Pixels> dimensions = Dimension2(0, 0);
	Grid(this.grid);

	Grid addWidgets(List<GridWidgetContext> widgets) {
		this.widgets.addAll(widgets);

		return this;
	}

	void render(rl.RenderTexture2D buffer, RenderContext renderContext) {
		dimensions = renderContext.area.getDimensions();

		final context = (dimensions: dimensions);

		final absoluteGrid = grid.accumulate(
			(sizeCallback, _) => sizeCallback(context),
			0,
			(a, b) => a + b,
		);


		// Sort widgets by zIndex (lower zIndex rendered first, higher on top)
		final sortedWidgets = [...widgets]..sort((a, b) => a.widget.zIndex.compareTo(b.widget.zIndex));

		for (var widget in sortedWidgets) {
			var topLeft = widget.area.topLeft.apply((cell, axis) {
				return absoluteGrid.getAxis(axis)[cell];
			});

			var bottomRight = widget.area.bottomRight.apply((cell, axis) {
				return absoluteGrid.getAxis(axis)[cell + 1];
			});

			var area = Area(topLeft, bottomRight);
			area.shift(renderContext.area.topLeft);
			var widgetBuffer = widget.widget.renderCallback((
				area: area
			));

			rl.beginTextureMode(buffer);
			drawBuffer(widgetBuffer, topLeft);
			rl.endTextureMode();
		}
	}
}

class Knob {
	double ratio = 0;
	rl.Color color;
	double minValue;
	double maxValue;
	Degrees angleBetween;
	bool isClicked = false;
	late Widget face;

	Knob(this.color, this.minValue, this.maxValue, { this.angleBetween = 280 });

	void render (rl.RenderTexture2D buffer, RenderContext renderContext) {
		var relativeArea = renderContext.area.toRelative();

		var radius = min(relativeArea.bottomRight.x, relativeArea.bottomRight.y) ~/ 2;

		if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
			var mousePos = rl.getMousePosition().toTessera();
			var center = renderContext.area.getCenter();
			var dx = mousePos.x - center.x;
			var dy = mousePos.y - center.y;
			var distanceSquared = dx * dx + dy * dy;

			bool mouseInside = distanceSquared <= radius * radius;

			isClicked = mouseInside;
		}

		if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
			isClicked = false;
		}

		if (isClicked) {
			double maxDistance = 400;
			ratio += -rl.getMouseDelta().y / maxDistance;
			ratio = ratio.clamp(0, 1);
		}

		var center = relativeArea.getCenter();
		var rotation = - angleBetween / 2 + ratio * angleBetween;

		rl.beginTextureMode(buffer);

		rl.drawCircleV(
			relativeArea.getCenter().toRaylib(),
			radius.toDouble(),
			color
		);

		var stickDimensions = Dimension2(radius ~/ 8, radius ~/ 2);
		var position = relativeArea.getCenter() - Vector2(stickDimensions.x ~/ 2, radius);

		rl.drawRectangleV(position.toRaylib(), stickDimensions.toRaylib(), rl.Color.black);
		rl.drawRectanglePro(
			Area(Vector2<Pixels>.zero(), stickDimensions).shift(center).toRaylib(),
			Vector2(stickDimensions.x ~/ 2, radius).toRaylib(),
			rotation,
			rl.Color.red
		);

		var font = getGlobalFont();
		var diff = maxValue - minValue;
		var value = minValue + diff * ratio;
		String text = value.toStringAsFixed(1);
		double fontSize = 24;
		double spacing = 0;

		Dimension2<Pixels> dimensions = rl.measureTextEx(font, text, fontSize, spacing).toTessera().toType<Pixels>();

		rl.drawTextEx(
			font,
			text,
			(center - dimensions / 2).toRaylib(),
			fontSize,
			spacing,
			rl.Color.blue,
		);

		rl.endTextureMode();
	}
}
