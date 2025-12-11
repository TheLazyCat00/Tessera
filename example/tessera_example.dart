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
	rl.setWindowState(rl.ConfigFlags.windowResizable);

	var grid = Grid(evenGrid(Grid2([1], [1, 1])));

	grid.addWidgets([
		Widget(
			Area(Vector2(0, 0), Vector2(0, 0)),
			Grid(evenGrid(Grid2([1], [1, 1])))
			.addWidgets([
				Widget(
					Area(Vector2(0, 0), Vector2(0, 0)),
					(() {
						var scale = Animation(1, 0.2, ease);
						var roundness = Animation(0, 0.2, ease);

						return (buffer, renderContext) {
							rl.beginTextureMode(buffer);

							var area = renderContext.area.toRelative();
							if (rl.getMousePosition().toTessera().isInside(renderContext.area) && rl.isCursorOnScreen()) {
								scale.setValue(0.5);
								roundness.setValue(0.5);
							}
							else {
								scale.setValue(1);
								roundness.setValue(0);
							}

							area.scale(scale.getValue());

							rl.drawRectangleRounded(area.toRaylib(), roundness.getValue(), 5, rl.Color.yellow);
							rl.endTextureMode();
						};
					})()
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

	var gridWidget = Widget(
		Area.zero(),
		grid.render,
	);

	while (!rl.windowShouldClose()) {
		renderWidget(gridWidget);
	}

	rl.closeWindow();
}
