//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// An iterable stream.
public enum Stream<T> {
	case Nil
	case Cons(Box<T>, @autoclosure () -> Stream<T>)
}


public func first<T>(stream: Stream<T>) -> T? {
	switch stream {
	case .Nil: return nil
	case let .Cons(x, _): return x.value
	}
}

public func dropFirst<T>(stream: Stream<T>) -> Stream<T> {
	switch stream {
	case .Nil: return .Nil
	case let .Cons(_, rest): return rest()
	}
}


extension Stream {
	public init<R : ReducibleType where R.Element == T>(_ reducible: R) {
		var recur: ((R, Stream, (Stream, T) -> Either<Stream, Stream>) -> Stream)!
		recur = { reducible, initial, combine in
			switch initial {
			case Nil: return Nil
			case let Cons(x, _):
				let y = reducible.reduceLeft(recur)(reducible, Nil, combine)
				return Cons(x, y)
			}
		}

		self = reducible.reduceLeft(recur)(reducible, Nil) { into, each in
			.Right(Box(Cons(Box(each), into)))
		}
	}
}
