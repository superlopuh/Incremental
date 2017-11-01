//
//  BucketQueue.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

public struct BucketQueue<Value> {

    public private(set) var buckets: [[Value]] = []

    public init() {}

    public mutating func insert(_ value: Value, at index: Int) {
        if buckets.count <= index {
            buckets.append(contentsOf: repeatElement([], count: index - buckets.count + 1))
        }

        buckets[index].append(value)
    }
}
