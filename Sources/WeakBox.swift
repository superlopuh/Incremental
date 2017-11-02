//
//  WeakBox.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 02/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

public final class WeakBox<Value: AnyObject> {

    public weak var value: Value?

    public init(_ value: Value?) {
        self.value = value
    }
}
