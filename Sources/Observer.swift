//
//  Observer.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

public final class Observer<Value> {

    public let incremental: Node<Value>
    public let onUpdate: (Value) -> ()

    public init(incremental: Node<Value>, onUpdate: @escaping (Value) -> ()) {
        self.incremental = incremental
        self.onUpdate = onUpdate
        incremental.observer = self
    }

    deinit {
        incremental.observer = nil
    }
}
