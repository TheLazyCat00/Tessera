import 'package:tessera/src/types/aliases.dart';
import 'package:tessera/src/types/blueprints.dart';
import 'package:tessera/src/types/helpers.dart';

class Grid {
	Grid2<SizeCallback> grid;
	List<Widget> widgets = [];
	Dimension2<Pixel> dimensions = Dimension2(0, 0);
	Grid(this.grid);

	void addWidget(Widget widget) {
		widgets.add(widget);
	}

	RgbaSurface render(RenderContext renderContext) {
		dimensions = renderContext.dimensions;
		final context = (dimensions: dimensions);

		final absoluteGrid = grid.accumulate(
			(sizeCallback, _) => sizeCallback(context),
			0,
			(a, b) => a + b,
		);

		RgbaSurface surface = RgbaSurface(dimensions);

		for (var widget in widgets) {
			var topLeft = widget.topLeft.apply((cell, axis) {
				return absoluteGrid.getAxis(axis)[cell];
			});

			var bottomRight = widget.bottomRight.apply((cell, axis) {
				return absoluteGrid.getAxis(axis)[cell + 1];
			});

			var widgetSurface = widget.renderCallback((dimensions: bottomRight - topLeft));
			surface.insertSurface(topLeft, widgetSurface);
		}

		return surface;
	}
}
