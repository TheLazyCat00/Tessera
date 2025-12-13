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
	rl.Font font = rl.loadFont("C:/Windows/Fonts/arial.ttf");

	Knob(this.color, this.minValue, this.maxValue, { this.angleBetween = 280 }) {
		face = Widget((buffer, renderContext) {
			var relativeArea = renderContext.area.toRelative();
			rl.beginTextureMode(buffer);

			var radius = min(relativeArea.bottomRight.x, relativeArea.bottomRight.y) ~/ 2;
			rl.drawCircleV(
				relativeArea.getCenter().toRaylib(),
				radius.toDouble(),
				color
			);
			var dimensions = Dimension2(radius ~/ 8, radius ~/ 2);
			var position = relativeArea.getCenter() - Vector2(dimensions.x ~/ 2, radius);
			rl.drawRectangleV(position.toRaylib(), dimensions.toRaylib(), rl.Color.black);
			rl.endTextureMode();
		});
	}

	void render (rl.RenderTexture2D buffer, RenderContext renderContext) {
		var relativeArea = renderContext.area.toRelative();
		var center = relativeArea.getCenter();

		var radius = min(relativeArea.bottomRight.x, relativeArea.bottomRight.y) ~/ 2;
		var diameter = radius * 2;
		var bottomRight = Vector2.same(diameter);

		if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
			var mousePos = rl.getMousePosition().toTessera();
			var dx = mousePos.x - renderContext.area.getCenter().x;
			var dy = mousePos.y - renderContext.area.getCenter().y;
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

		var face = this.face.renderCallback((area: Area(Vector2.zero(), bottomRight)));
		rl.beginTextureMode(buffer);
		var origin = bottomRight / 2;
		var rotation = - angleBetween / 2 + ratio * angleBetween;
		drawBuffer(face, relativeArea.getCenter(), rotation: rotation, origin: origin);

		var diff = maxValue - minValue;
		int offset = 1;
		String text = (minValue + diff * ratio).toStringAsFixed(1);
		double fontSize = 30;
		double spacing = 1;

		Dimension2<Pixels> dimensions = rl.measureTextEx(font, text, fontSize, spacing).toTessera().toType<Pixels>();

		rl.drawTextPro(
			font,
			text,
			center.toRaylib(),
			(dimensions / 2).toRaylib(),
			0,
			fontSize,
			spacing,
			rl.Color.black,
		);

		rl.drawTextPro(
			font,
			text,
			(center + Vector2.same(offset)).toRaylib(),
			(dimensions / 2).toRaylib(),
			0,
			fontSize,
			spacing,
			rl.Color.white,
		);

		rl.endTextureMode();
	}
}
