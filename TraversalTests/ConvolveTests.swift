//  Copyright (c) 2014 Rob Rix. All rights reserved.

import Traversal
import XCTest

class ConvolveTests: XCTestCase {
	func testConvolutionOfTwoParameters() {
		let r = Stream([1, 2, 3])
		let zipped = convolve(r, r)
		let mapped = Traversal.map(zipped, +)
		XCTAssertEqual(Traversal.reduce(mapped, 0, +), 12)
	}
}
