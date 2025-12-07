import 'package:tessera/src/core/rendering.dart';
import 'package:tessera/src/types/aliases.dart';
import 'package:tessera/src/types/blueprints.dart';
import 'package:tessera/src/types/helpers.dart';
import 'package:raylib/raylib.dart' as rl;


class Grid {
	Grid2<SizeCallback> grid;
	List<Widget> widgets = [];
	Dimension2<Pixel> dimensions = Dimension2(0, 0);
	Grid(this.grid);

	Grid addWidgets(List<Widget> newWidgets) {
		widgets.addAll(newWidgets);

		return this;
	}

	void render(rl.RenderTexture2D buffer, RenderContext renderContext) {
		dimensions = renderContext.dimensions;

		final context = (dimensions: dimensions);

		final absoluteGrid = grid.accumulate(
			(sizeCallback, _) => sizeCallback(context),
			0,
			(a, b) => a + b,
		);


		// Sort widgets by zIndex (lower zIndex rendered first, higher on top)
		final sortedWidgets = [...widgets]..sort((a, b) => a.zIndex.compareTo(b.zIndex));

		for (var widget in sortedWidgets) {
			var topLeft = widget.topLeft.apply((cell, axis) {
				return absoluteGrid.getAxis(axis)[cell];
			});

			var bottomRight = widget.bottomRight.apply((cell, axis) {
				return absoluteGrid.getAxis(axis)[cell + 1];
			});

			var widgetBuffer = widget.renderCallback((
				dimensions: bottomRight - topLeft
			));

			rl.beginTextureMode(buffer);
			drawBuffer(widgetBuffer, topLeft);
			rl.endTextureMode();
		}
	}
}
