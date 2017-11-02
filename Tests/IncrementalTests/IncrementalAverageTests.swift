//
//  IncrementalAverageTests.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

import Foundation
import XCTest
import Incremental

// To suppress unused value warnings
func touch<T>(_ value: T) {}

func merge<Value>(_ elements: [Node<Value>], combine: @escaping (Value, Value) -> Value) -> Node<Value> {
    guard 1 < elements.count else { return elements[0] }

    var halfArray = [Node<Value>]()
    halfArray.reserveCapacity(elements.count / 2)

    for index in 0 ..< elements.count / 2 {
        let lhs = elements[index * 2]
        let rhs = elements[index * 2 + 1]
        let combined = Incremental.map(lhs, rhs, combine)
        halfArray.append(combined)
    }

    if 1 == elements.count % 2 {
        halfArray.append(elements.last!)
    }

    return merge(halfArray, combine: combine)
}

func average(_ elements: [Node<Double>]) -> Node<Double> {
    let sum = merge(elements, combine: +)
    return Incremental.map(sum, { $0 / Double(elements.count)})
}

class IncrementalAverageTests: XCTestCase {

    func testIncrementalAverage() {

        let inputs = (0 ..< 100)
            .map(Double.init)
            .map(IncrementalInput.init)

        let incrementals = inputs.map { $0.node }

        let myAverage = average(incrementals)

        var resultValue = 0.0

        let observer = myAverage.observe(onUpdate: { resultValue = $0 })
        touch(observer)

        XCTAssertEqual(resultValue, 0.0)

        XCTAssertEqual(myAverage.value, 49.5)

        inputs[0].value = 100

        XCTAssertEqual(myAverage.value, 50.5)
        XCTAssertEqual(resultValue, 50.5)
    }

    func testIncrementalAveragePerformance() {
        measure {
            let inputs = (0 ..< 10000)
                .map(Double.init)
                .map(IncrementalInput.init)

            let incrementals = inputs.map { $0.node }

            let _ = average(incrementals)
        }
    }

    func testIncrementalAverageUpdatePerformance() {
        let inputs = (0 ..< 10000)
            .map(Double.init)
            .map(IncrementalInput.init)

        let incrementals = inputs.map { $0.node }
        let myAverage = average(incrementals)
        touch(myAverage)

        measure {
            for i in 0 ..< 40 {
                inputs[i].value = Double(i + 100)
            }
        }
    }

    func testStandardAveragePerformance() {
        func average(_ elements: [Double]) -> Double {
            let sum = elements.reduce(0, +)
            return sum / Double(elements.count)
        }

        measure {
            let numbers: [Double] = (0 ..< 10000).map(Double.init)
            let _ = average(numbers)
        }
    }

    static var allTests = [
        ("testIncrementalAverage", testIncrementalAverage),
        ("testIncrementalAveragePerformance", testIncrementalAveragePerformance),
        ("testStandardAveragePerformance", testStandardAveragePerformance),
    ]
}
