import "../core/grid.dart";
import "aliases.dart";
import "helpers.dart";

typedef RenderCallback = PixelSurface Function(RenderContext);
typedef RenderContext = ({
	Grid parent,
});

typedef SizeCallback = Pixel Function(Grid);
typedef SizeContext = ({
	Dimension2<Pixel> dimension2,
});

abstract class PixelSurface {
	Pixel getWidth();
	Pixel getHeight();
	List<int> getPixels();
}


class Border<T> {
	T top;
	T left;
	T bottom;
	T right;

	Border(
		this.top,
		this.left,
		this.bottom,
		this.right
	);
}

typedef Widget = ({
	RenderCallback renderCallback,
	Vector2<Cell> topLeft,
	Vector2<Cell> bottomRight,
});
