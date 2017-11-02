//
//  UniqueObjectsTests.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

import XCTest
@testable import Incremental

class Class {}

class UniqueObjectsTests: XCTestCase {
    
    func testUniqueObjects() {
        var objects = [Class(), Class(), Class()]
        XCTAssertEqual(3, uniqueObjects(objects).count)
        objects.append(objects[0])
        XCTAssertEqual(3, uniqueObjects(objects).count)
    }

    static var allTests = [
        ("testUniqueObjects", testUniqueObjects),
    ]
}
