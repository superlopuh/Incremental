//
//  UniqueObjects.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

func uniqueObjects<Object: AnyObject>(_ objects: [Object]) -> [Object] {
    let withAddresses = objects.lazy.map { object -> (Int, Object) in
        return (unsafeBitCast(object, to: Int.self), object)
    }
    let uniquedByAddress = Dictionary(withAddresses, uniquingKeysWith: { (first, _) in first })
    return Array(uniquedByAddress.values)
}
