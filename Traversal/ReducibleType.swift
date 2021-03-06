//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A collection which can be left-reduced nonrecursively.
public protocol ReducibleType {
	/// The type of the collection’s elements.
	typealias Element

	/// Create a nonrecursive left reduce function for the receiver.
	///
	/// Instead of calling itself recursively as a typical left-reduce might do, the implementation calls out via the `recur` parameter instead. This allows the operator to be used for both enumeration (via a fixpoint) and iteration.
	///
	/// This is written in partially applied style to simplify the construction of enumerators.
	///
	/// The combine function returns Either in order to enable early termination; returning Either.Left(x) indicates that reduction should conclude immediately with x, whereas Either.Right(y) indicates that reduction should continue with y.
	func reducer<Result>() -> Reducible<Self, Result, Element>.Enumerator -> Reducible<Self, Result, Element>.Enumerator
}


/// Left-reduction of a reducible.
public func reduce<R: ReducibleType, Result>(collection: R, initial: Result, combine: Reducible<R, Result, R.Element>.Iteratee) -> Result {
	return fix(collection.reducer())(collection, initial, combine)
}


/// Left-reduction of a reducible.
///
/// Unlike the version above, this version takes a function returning Result instead of Either<Result, Result>. As such, it may be more convenient for cases not needing early termination.
public func reduce<R: ReducibleType, Result>(collection: R, initial: Result, combine: Reducible<R, Result, R.Element>.Combine) -> Result {
	return reduce(collection, initial, combine >>> Either.right)
}


/// Typealiases used by ReducibleType.
///
/// \param Self     The collection being reduced.
/// \param Result   The initial/result type of a reduction.
/// \param Element  The type of the elements of Self. Must be provided explicitly because conforming Self to ReducibleType fails typechecking.
public struct Reducible<Self, Result, Element> {
	/// The type of the function combining a working value and successive elements of Self which allows early termination.
	public typealias Iteratee = (Result, Element) -> Either<Result, Result>

	/// The type of the function combining a working value and successive elements of Self which does not allow early termination.
	public typealias Combine = (Result, Element) -> Result

	/// The type of the reduce function.
	public typealias Enumerator = (Self, Result, Iteratee) -> Result
}


// MARK: Imports

import Box
import Either
import Prelude
