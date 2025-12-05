import "aliases.dart";

abstract class PixelSurface {
	Pixel getWidth();
	Pixel getHeight();
	List<int> getPixels();
}

class RenderContext {
	final int x;
	final int y;
	final String mode;

	RenderContext({
		this.x = 0,
		this.y = 0,
		this.mode = 'default',
	});
}

typedef RenderCallback = PixelSurface Function(RenderContext);

class Widget {

}
