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
			Vector2(0, 0),
			Vector2(0, 0),
			Grid(evenGrid(Grid2([1], [1, 1])))
			.addWidgets([
				Widget(
					Vector2(0, 0),
					Vector2(0, 0),
					(buffer, renderContext) {
						rl.beginTextureMode(buffer);
						rl.drawRectangle(0, 0, renderContext.dimensions.x, renderContext.dimensions.y, rl.Color.blue);
						rl.endTextureMode();
					}
				),
				Widget(
					Vector2(0, 1),
					Vector2(0, 1),
					(buffer, renderContext) {
						rl.beginTextureMode(buffer);
						rl.drawRectangle(0, 0, renderContext.dimensions.x, renderContext.dimensions.y, rl.Color.red);
						rl.endTextureMode();
					}
				),
			]).render
		),
		Widget(
			Vector2(0, 1),
			Vector2(0, 1),
			(buffer, renderContext) {
				rl.beginTextureMode(buffer);
				rl.drawRectangle(0, 0, renderContext.dimensions.x, renderContext.dimensions.y, rl.Color.orange);
				rl.endTextureMode();
			}
		),
	]);

	var dimension = Dimension2(800, 600);
	var gridWidget = Widget(
		Vector2.zero(),
		Vector2.zero(),
		grid.render,
	);

	while (!rl.windowShouldClose()) {
		renderWidget(gridWidget, dimension);
	}


	rl.closeWindow();
}
