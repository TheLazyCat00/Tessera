import 'package:tessera/tessera.dart';
import 'package:raylib/raylib.dart' as rl hide Vector2;

Grid2<SizeCallback> evenGrid(Grid2<int> grid) {
	var proportional = grid.apply((element, axis) {
		int sum = grid.getAxis(axis).fold<int>(0, (prev, current) => prev + current);

		return element / sum;
	});

	SizeCallback getSizeGetter(double proportion, Axis2 axis) {
		return (grid) => (grid.dimensions.getAxis(axis) * proportion).toInt();
	}

	var res = proportional.apply(getSizeGetter);

	return res;
}

void main() {
	rl.initLibrary(windows: getRaylibPath());
	rl.initWindow(800, 600, "Hello Raylib!");

	var grid = Grid(evenGrid(Grid2([1], [1, 1])));

	grid.addWidgets([
		Widget(
			Area(Vector2(0, 0), Vector2(0, 0)),
			Grid(evenGrid(Grid2([1], [1, 1])))
			.addWidgets([
				Widget(
					Area(Vector2(0, 0), Vector2(0, 0)),
					(buffer, renderContext) {
						var dimensions = renderContext.area.getDimensions();

						rl.beginTextureMode(buffer);
						var color = rl.Color.blue;

						if (rl.getMousePosition().toTessera().isInside(renderContext.area)){
							color = rl.Color.magenta;
						}

						rl.drawRectangle(0, 0, dimensions.x, dimensions.y, color);
						rl.endTextureMode();
					}
				),
				Widget(
					Area(Vector2(0, 1), Vector2(0, 1)),
					(buffer, renderContext) {
						var dimensions = renderContext.area.getDimensions();

						rl.beginTextureMode(buffer);
						rl.drawRectangle(0, 0, dimensions.x, dimensions.y, rl.Color.red);
						rl.endTextureMode();
					}
				),
			]).render
		),
		Widget(
			Area(Vector2(0, 1), Vector2(0, 1)),
			(buffer, renderContext) {
				var dimensions = renderContext.area.getDimensions();

				rl.beginTextureMode(buffer);
				rl.drawRectangle(0, 0, dimensions.x, dimensions.y, rl.Color.orange);
				rl.endTextureMode();
			}
		),
	]);

	var dimension = Dimension2(800, 600);
	var gridWidget = Widget(
		Area.zero(),
		grid.render,
	);

	while (!rl.windowShouldClose()) {
		renderWidget(gridWidget, dimension);
	}


	rl.closeWindow();
}
