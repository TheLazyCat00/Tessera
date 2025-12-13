import 'package:raylib/raylib.dart' as rl;
import 'package:tessera/src/types.dart';

enum Axis2 {
	x,
	y;

	static const Map<Axis2, Axis2> opposites = {
		Axis2.x: Axis2.y,
		Axis2.y: Axis2.x,
	};

	Axis2 getOpposite() {
		return opposites[this]!;
	}
}

T convert<T extends num>(num value) {
	if (T == double) return value.toDouble() as T;
	if (T == int) return value.toInt() as T;
	throw UnsupportedError("Unsupported type $T");
}

class Grid2<T> {
	final Map<Axis2, List<T>> _data;

	Grid2(List<T> x, List<T> y) : _data = { Axis2.x: x, Axis2.y: y };

	List<T> get x => _data[Axis2.x] as List<T>;

	List<T> get y => _data[Axis2.y] as List<T>;

	List<T> getAxis(Axis2 axis) => _data[axis] as List<T>;

	Grid2<U> apply<U>(U Function(T, Axis2) transform) {
		return Grid2(
			_data[Axis2.x]!.map((e) => transform(e, Axis2.x)).toList(),
			_data[Axis2.y]!.map((e) => transform(e, Axis2.y)).toList(),
		);
	}

	/// Accumulates values along each axis, returning cumulative sums.
	/// The result has length + 1 elements per axis: [0, v0, v0+v1, v0+v1+v2, ...]
	Grid2<U> accumulate<U>(U Function(T, Axis2) transform, U zero, U Function(U, U) combine) {
		List<U> accumulateAxis(List<T> values, Axis2 axis) {
			List<U> result = [zero];
			U cumulative = zero;
			for (var value in values) {
				cumulative = combine(cumulative, transform(value, axis));
				result.add(cumulative);
			}
			return result;
		}

		return Grid2(
			accumulateAxis(_data[Axis2.x]!, Axis2.x),
			accumulateAxis(_data[Axis2.y]!, Axis2.y),
		);
	}
}

class Area<T extends num> {
	Vector2<T> topLeft;
	Vector2<T> bottomRight;

	Area(this.topLeft, this.bottomRight);
	Area.zero() :
		topLeft = Vector2.zero(),
		bottomRight = Vector2.zero();

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
			other is Area<T> &&
			other.topLeft == topLeft &&
			other.bottomRight == bottomRight;
	}

	@override
	int get hashCode => Object.hash(topLeft, bottomRight);

	Dimension2<T> getDimensions() => bottomRight - topLeft;

	void scale(double factor) {
		var middlePoint = (topLeft + bottomRight) / 2;
		var distance = middlePoint - topLeft;
		distance = distance * factor;

		topLeft = middlePoint - distance;
		bottomRight = middlePoint + distance;
	}

	rl.Rectangle toRaylib() {
		var dimensions = getDimensions();

		return rl.Rectangle(
			topLeft.x.toDouble(),
			topLeft.y.toDouble(),
			dimensions.x.toDouble(),
			dimensions.y.toDouble()
		);
	}

	Area<T> toRelative() {
		return Area(Vector2.zero(), bottomRight - topLeft);
	}

	Vector2<T> getCenter() => bottomRight - getDimensions() / 2;
}

extension RaylibVector2ToTesseraVector2 on rl.Vector2 {
	Vector2<double> toTessera() => Vector2(x.toDouble(), y.toDouble());
}

class Vector2<T extends num> {
	final Map<Axis2, T> _data;

	Vector2(T x, T y) : _data = { Axis2.x: x, Axis2.y: y };
	Vector2.same(T value) : _data = { Axis2.x: value, Axis2.y: value };
	Vector2.zero() : _data = { Axis2.x: 0 as T, Axis2.y: 0 as T };

	T get x => _data[Axis2.x] as T;
	T get y => _data[Axis2.y] as T;

	Vector2<U> toType<U extends num>() => Vector2(convert<U>(x), convert<U>(y));

	@override
	bool operator ==(Object other) {
		return identical(this, other) ||
			other is Vector2<T> &&
			other.x == x &&
			other.y == y;
	}

	@override
	int get hashCode => Object.hash(x, y);

	rl.Vector2 toRaylib() => rl.Vector2(x.toDouble(), y.toDouble());

	T getAxis(Axis2 axis) => _data[axis] as T;

	bool isInside(Area<T> area) {
		return
			area.topLeft.x < x &&
			area.topLeft.y < y &&
			x < area.bottomRight.x &&
			y < area.bottomRight.y;
	}

	Vector2<U> apply<U extends num>(U Function(T, Axis2) transform) {
		return Vector2(
			transform(x, Axis2.x),
			transform(y, Axis2.y),
		);
	}

	Vector2<T> operator +(Vector2<T> other) {
		dynamic x = this.x;
		dynamic y = this.y;
		dynamic ox = other.x;
		dynamic oy = other.y;
		return Vector2<T>(x + ox, y + oy);
	}

	Vector2<T> operator -(Vector2<T> other) {
		dynamic x = this.x;
		dynamic y = this.y;
		dynamic ox = other.x;
		dynamic oy = other.y;
		return Vector2<T>(x - ox, y - oy);
	}

	Vector2<T> operator * (num value) {
		return Vector2(convert<T>(x * value), convert<T>(y * value));
	}

	Vector2<T> operator / (num value) {
		return Vector2(convert<T>(x / value), convert<T>(y / value));
	}
}
