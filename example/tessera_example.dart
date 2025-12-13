import 'package:tessera/tessera.dart';
import 'package:raylib/raylib.dart' as rl;
import 'package:raylib/src/modules/core/misc.dart' as rl;
import 'package:raylib/src/modules/text/font.dart' as rl;

void main() {
	rl.initLibrary(windows: getRaylibPath());

	rl.setConfigFlags(rl.ConfigFlags.windowResizable | rl.ConfigFlags.msaa4xHint);

	rl.initWindow(800, 600, "Hello Raylib!");

	const int kMaxCodePoint = 512; 

	final List<int> allChars = List<int>.generate(
		kMaxCodePoint - 32, 
		(index) => index + 32
	);

	var fontPath = "C:/Windows/Fonts/ShareTechMono-Regular.ttf";

	final font = rl.loadFontEx(
		fontPath,
		100,
		allChars,
		allChars.length,
	);

	rl.setTextureFilter(font.texture, rl.TextureFilter.bilinear);
	setGlobalFont(font);

	var animationWidget = Widget((() {
		var scale = Animation(1, 0.2, ease);
		var roundness = Animation(0, 0.2, ease);

		return (buffer, RenderContext renderContext) {
			rl.beginTextureMode(buffer);

			var area = renderContext.area.toRelative();
			if (rl.getMousePosition().toTessera().toType<Pixels>().isInside(renderContext.area) && rl.isCursorOnScreen()) {
				scale.setValue(0.5);
				roundness.setValue(0.5);
			}
			else {
				scale.setValue(1);
				roundness.setValue(0);
			}

			area.scale(scale.getValue());
			rl.drawRectangleRounded(area.toRaylib(), roundness.getValue(), 5, rl.Color.yellow);
			rl.drawTextEx(getGlobalFont(), "hello", Vector2.zero().toRaylib(), 64, 1, rl.Color.red);
			rl.endTextureMode();
		};
	})());

	var idk1 = Widget(
		Grid(evenGrid(Grid2([1], [1, 1])))
		.addWidgets([
			(
				area: Area(Vector2(0, 0), Vector2(0, 0)),
				widget: animationWidget
			),
			(
				area: Area(Vector2(0, 1), Vector2(0, 1)),
				widget: Widget((buffer, renderContext) {
					var dimensions = renderContext.area.getDimensions();

					rl.beginTextureMode(buffer);
					rl.drawRectangle(0, 0, dimensions.x, dimensions.y, rl.Color.red);
					rl.endTextureMode();
				})
			),
		]).render
	);

	var idk2 = Widget(
		Grid(evenGrid(Grid2([1, 1, 1], [1, 1, 1])))
		.addWidgets([
			(
				area: Area(Vector2(1, 1), Vector2(1, 1)),
				widget: Widget(
					Knob(rl.Color.black, 1, 10).render
				)
			)
		]).render
	);

	var grid = Grid(evenGrid(Grid2([1], [1, 1])));

	grid.addWidgets([
		(widget: idk1, area: Area(
			Vector2(0, 0),
			Vector2(0, 0)
		)),
		(widget: idk2, area: Area(
			Vector2(0, 1),
			Vector2(0, 1)
		))
	]);

	var gridWidget = Widget(
		grid.render,
	);

	while (!rl.windowShouldClose()) {
		renderWidget(idk2);
	}

	rl.closeWindow();
}
