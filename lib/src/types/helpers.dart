// filepath: lib/types/helpers.dart

enum Axis2 { x, y }

extension Axis2Extension on Axis2 {
	Axis2 getOpposite() {
		return this == Axis2.x ? Axis2.y : Axis2.x;
	}
}

class Grid2<T> {
	final Map<Axis2, T> data;

	Grid2(T x, T y) : data = {Axis2.x: x, Axis2.y: y};

	T get x => data[Axis2.x] as T;
	set x(T value) => data[Axis2.x] = value;

	T get y => data[Axis2.y] as T;
	set y(T value) => data[Axis2.y] = value;

	T getAxis(Axis2 axis) => data[axis] as T;
}

class Vector2<T> {
	final Map<Axis2, T> data;

	Vector2(T x, T y) : data = {Axis2.x: x, Axis2.y: y};

	T get x => data[Axis2.x] as T;
	T get y => data[Axis2.y] as T;

	T getAxis(Axis2 axis) => data[axis] as T;

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

	Vector2<T> operator *(Vector2<T> other) {
		dynamic x = this.x;
		dynamic y = this.y;
		dynamic ox = other.x;
		dynamic oy = other.y;
		return Vector2<T>(x * ox, y * oy);
	}

	Vector2<T> operator /(Vector2<T> other) {
		dynamic x = this.x;
		dynamic y = this.y;
		dynamic ox = other.x;
		dynamic oy = other.y;
		return Vector2<T>(x / ox, y / oy);
	}
}
