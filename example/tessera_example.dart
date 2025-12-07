import 'package:tessera/tessera.dart';

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
	var layout = evenGrid(Grid2([1, 1, 1], [1, 1, 1]));
	var grid = Grid(layout);

	Widget widget = (topLeft: Vector2(0, 0), bottomRight: Vector2(2, 2), renderCallback: (renderContext) {
		var res = RgbaSurface(renderContext.dimensions);
		res.fill(0xFFAA00FF);

		return res;
	});

	grid.addWidget(widget);

	var dimension = Dimension2(800, 600);
	var pixelRenderer = PixelRenderer(RgbaSurface(dimension)); // Initial surface

	while (!pixelRenderer.shouldClose()) {
		// Re-render grid each frame
		var surface = grid.render((dimensions: dimension));
		
		// Update renderer's surface and display
		pixelRenderer.surface = surface;
		pixelRenderer.render();
	}

	pixelRenderer.cleanup();
}
