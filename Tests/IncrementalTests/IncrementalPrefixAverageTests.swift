//
//  IncrementalPrefixAverageTests.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 02/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

import XCTest
import Incremental

func averageOfPrefix(_ elements: [Node<Double>], prefixLength: Node<Int>) -> Node<Double> {
    return Incremental.flatMap(prefixLength) { length in
        return average(Array(elements.prefix(upTo: length)))
    }
}

class IncrementalPrefixAverageTests: XCTestCase {

    func testIncrementalPrefixAverage() {

        let inputs = (0 ..< 100)
            .map(Double.init)
            .map(Input.init)

        let incrementals = inputs.map { $0.node }

        let prefixLength = Input(10)

        let myAverage = averageOfPrefix(incrementals, prefixLength: prefixLength.node)

        var resultValue = 0.0

        let observer = myAverage.observe(onUpdate: { resultValue = $0 })
        touch(observer)

        XCTAssertEqual(0.0, resultValue)
        XCTAssertEqual(4.5, myAverage.value)

        inputs[0].value = 100

        XCTAssertEqual(14.5, myAverage.value)
        XCTAssertEqual(14.5, resultValue)

        prefixLength.value = 50

        XCTAssertEqual(26.5, myAverage.value)
        XCTAssertEqual(26.5, resultValue)
    }

    static var allTests = [
        ("testIncrementalPrefixAverage", testIncrementalPrefixAverage),
    ]
}
