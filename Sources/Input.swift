//
//  Input.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

public class InputBase {

    public func getNode() -> NodeBase {
        fatalError("Unimplemented")
    }
}

public final class Input<Value>: InputBase {

    public var _value: Value

    public private(set) lazy var node: Node<Value> = {
        return Node(
            computeValue: { self._value },
            getMaxChildPseudoHeight: { -1 }
        )
    }()

    public init(_ initialValue: Value) {
        self._value = initialValue
    }

    public override func getNode() -> NodeBase {
        return node
    }

    public var value: Value {
        get {
            return _value
        }
        set {
            _value = newValue
            Incremental.stabilize(inputsChanged: [self])
        }
    }
}
