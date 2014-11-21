//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A reducible over other reducibles.
///
/// This is a meta-reducer used to implement `flattenMap`, `map`, `filter`, and `concat`.
public struct ReducerOf<Base: ReducibleType, T: ReducibleType>: ReducibleType {
	// MARK: Lifecycle

	/// Initializes with a base `reducible` and a `map` from the elements of `reducible` to some inhabitant of `ReducibleType`.
	public init(_ reducible: Base, _ map: Base.Element -> T) {
		self.reducible = reducible
		self.map = map
	}


	// MARK: ReducibleType

	public func reducer<Result>() -> Reducible<Result, T.Element>.Enumerator -> Reducible<Result, T.Element>.Enumerator {
		let reducer: Reducible<Result, Base.Element>.Enumerator -> Reducible<Result, Base.Element>.Enumerator = reducible.reducer()
		let transduce: Reducible<Result, T.Element>.Iteratee -> Reducible<Result, Base.Element>.Iteratee = flattenMapping(self.map)
		return { recur in
			// In order to reduce `reducible`, we have to pass it a `recur` function which calls the one which this function has been called with. We can’t just pass in `combine` because the element type of `reducible` does not match the element type of `self` (in the general case). However, we don’t want to generate a new function with every step, since that would be wasteful (and surprising). Therefore, we produce the function on the first step only. I’m discontent with this implementation, but it will have to do for now.
			var reduce: Reducible<Result, Base.Element>.Enumerator!
			var c: Reducible<Result, Base.Element>.Iteratee!
			return { initial, combine in
				if c == nil {
					c = transduce(combine)
				}
				if reduce == nil {
					reduce = reducer { initial, _ in
						recur(initial, combine)
					}
				}
				return reduce(initial, c)
			}
		}
	}


	// MARK: Private

	private let reducible: Base
	private let map: Base.Element -> T
}


/// Transducer for flatten maps.
private func flattenMapping<Result, U, T: ReducibleType>(map: U -> T)(combine: Reducible<Result, T.Element>.Iteratee) -> Reducible<Result, U>.Iteratee {
	return { into, each in
		return .Right(Box(reduce(map(each), into, combine)))
	}
}


// MARK: Imports

import Box
