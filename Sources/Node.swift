//
//  Node.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 01/11/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

public class NodeBase {

    public var higherNodes: [NodeBase] = []

    public var dirtyPseudoHeight = false

    public var pseudoHeight: Int

    public var getMaxChildPseudoHeight: () -> Int

    public init(getMaxChildPseudoHeight: @escaping () -> Int) {
        self.pseudoHeight = getMaxChildPseudoHeight() + 1
        self.getMaxChildPseudoHeight = getMaxChildPseudoHeight
    }

    public func addHigherNode(_ higherNode: NodeBase) {
        higherNodes.append(higherNode)
    }

    public final func recomputePseudoHeight() {
        defer { dirtyPseudoHeight = false }

        let childMax = getMaxChildPseudoHeight()

        guard pseudoHeight < childMax + 1 else { return }

        pseudoHeight = childMax + 1
        for higherNode in higherNodes {
            higherNode.setPseudoHeightDirty()
        }
    }

    public func setPseudoHeightDirty() {
        dirtyPseudoHeight = true
    }

    public func recomputeValue() -> Bool {
        fatalError("Unimplemented")
    }
}

public final class Node<Value>: NodeBase {

    public weak var observer: Observer<Value>? = nil

    public var value: Value
    public var computeValue: () -> Value

    public init(computeValue: @escaping () -> Value, getMaxChildPseudoHeight: @escaping () -> Int) {
        self.value = computeValue()
        self.computeValue = computeValue
        super.init(getMaxChildPseudoHeight: getMaxChildPseudoHeight)
    }

    public func observe(onUpdate: @escaping (Value) -> ()) -> Observer<Value> {
        return Observer(incremental: self, onUpdate: onUpdate)
    }

    public override func recomputeValue() -> Bool {
        self.value = computeValue()
        observer?.onUpdate(value)
        return true
    }
}
