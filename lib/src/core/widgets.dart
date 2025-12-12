import 'package:tessera/tessera.dart';
import 'package:raylib/raylib.dart' as rl;

typedef GridWidgetContext = ({ Widget widget, Area<Cell> area });

class Grid {
	Grid2<SizeCallback> grid;
	List<GridWidgetContext> widgets = [];
	Dimension2<Pixel> dimensions = Dimension2(0, 0);
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
	SizeCallback radius;
	double ratio = 0;
	rl.Color color;
	double min;
	double max;

	Knob(this.radius, this.color, this.min, this.max);

	void render (rl.RenderTexture2D buffer, RenderContext renderContext) {
		var relativeArea = renderContext.area.toRelative();
		var center = relativeArea.getCenter();
		rl.drawCircleV(
			center.toRaylib(),
			radius((dimensions: relativeArea.getDimensions())).toDouble(),
			color
		);

		var diff = max - min;
		rl.drawText((min + diff * ratio).toString(), center.x, center.y, 1, color);
	}
}
