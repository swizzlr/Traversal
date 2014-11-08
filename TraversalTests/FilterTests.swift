//  Copyright (c) 2014 Rob Rix. All rights reserved.

import Traversal
import XCTest

class FilterTests: XCTestCase {
	func testFilterAcceptingAll() {
		let sequence = [1, 2, 3, 4]
		let reducible = ReducibleOf(sequence: sequence)
		let filtered = Traversal.filter(reducible, acceptAll)
		XCTAssertEqual(reduce(filtered, 0, +), 10)
	}

	func testFilterRejectingAll() {
		let sequence = [1, 2, 3, 4]
		let reducible = ReducibleOf(sequence: sequence)
		let filtered = Traversal.filter(reducible, rejectAll)
		XCTAssertEqual(reduce(filtered, 0, +), 0)
	}

	func testFilterAcceptingSome() {
		let sequence: [Int?] = [1, nil, 3, nil]
		let reducible = ReducibleOf(sequence: sequence)
		let filtered = Traversal.filter(reducible, rejectNil)
		XCTAssertEqual(reduce(filtered, 0) { $0 + ($1 ?? 0) }, 4)
	}
}
