//
//  IncrementalTests.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 23/10/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

import Foundation
import XCTest
import Incremental

class IncrementalTests: XCTestCase {

    // Tests that once a node is unreachable, it is deallocated
    func testMemoryCycle() {
        var count = 0

        func counter() {
            count += 1
        }

        let input = Input(())
        var node: Node<()>? = Incremental.map(input.node, counter)

        // `counter` fired on creation
        XCTAssertEqual(1, count)

        input.value = ()

        // `counter` fired on update
        XCTAssertEqual(2, count)

        var _count = 0
        // Captures node
        var observer: Observer<()>? = node?.observe { _count += 1 }
        touch(observer)

        // Old result node now unreachable
        node = nil

        input.value = ()

        // Even though node is unreachable, it is captured by observer
        XCTAssertEqual(3, count)

        // Observer should mutate `_count`
        XCTAssertEqual(1, _count)

        observer = nil

        input.value = ()

        // `counter` no longer fired on update
        XCTAssertEqual(3, count)
        // `observer` no longer fired on update
        XCTAssertEqual(1, _count)
    }
    
    static var allTests = [
        ("testMemoryCycle", testMemoryCycle),
    ]
}
