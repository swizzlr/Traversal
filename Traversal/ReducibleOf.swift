//  Copyright (c) 2014 Rob Rix. All rights reserved.

/// A reducible over a sequence.
public struct ReducibleOf<T>: ReducibleType, SequenceType {
	// MARK: Lifecycle

	/// Initializes with a sequence.
	public init<S : SequenceType where S.Generator.Element == T>(sequence: S) {
		self.init({ sequence.generate() })
	}

	/// Initializes with a function producing generators.
	public init<G: GeneratorType where G.Element == T>(_ generate: () -> G) {
		self.init({
			var generator = generate()
			return { generator.next() }
		})
	}

	/// Initializes with a reducible.
	public init<R: ReducibleType where R.Element == T>(_ reducible: R) {
		self.init(sequence: Stream(reducible))
	}

	/// Initializes with a single element.
	public init(element: T) {
		self.init(sequence: GeneratorOfOne(element))
	}

	/// Initializes an empty reducible.
	public init() {
		self.init({ { nil } })
	}


	// MARK: ReducibleType

	/// Nonrecursive left reduction.
	public func reducer<Result>() -> Reducible<Result, T>.Enumerator -> Reducible<Result, T>.Enumerator {
		var producer = self.producer()
		return { recur in
			{ initial, combine in
				producer().map { combine(initial, $0).map { recur($0, combine) }.either(id, id) } ?? initial
			}
		}
	}


	// MARK: SequenceType conformance.
	public func generate() -> GeneratorOf<T> {
		return GeneratorOf(Stream(self).generate())
	}


	// MARK: Private

	/// Initializes with a function which produces generator functions.
	private init(_ producer: () -> () -> T?) {
		self.producer = producer
	}

	/// The function which produces the functions which are reduced over.
	///
	/// This indirection is required because GeneratorType is consumed by next(), requiring us to acquire a new generator for each reduction.
	private let producer: () -> () -> T?
}
