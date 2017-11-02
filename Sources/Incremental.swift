//
//  Incremental.swift
//  Incremental
//
//  Created by Sasha Lopoukhine on 23/10/2017.
//  Copyright © 2017 Incremental. All rights reserved.
//

public enum Incremental {}

extension Incremental {

    public static func map<Value0, NewValue>(_ node0: Node<Value0>, _ transform: @escaping (Value0) -> NewValue) -> Node<NewValue> {
        let result = Node<NewValue>(
            computeValue: { transform(node0.value) },
            getMaxChildPseudoHeight: { node0.pseudoHeight }
        )
        node0.addHigherNode(result)
        return result
    }

    public static func map<Value0, Value1, NewValue>(_ node0: Node<Value0>, _ node1: Node<Value1>, _ transform: @escaping (Value0, Value1) -> NewValue) -> Node<NewValue> {
        let result = Node<NewValue>(
            computeValue: { transform(node0.value, node1.value) },
            getMaxChildPseudoHeight: { max(node0.pseudoHeight, node1.pseudoHeight) }
        )
        node0.addHigherNode(result)
        node1.addHigherNode(result)
        return result
    }
}

extension Incremental {

    // As it stands, the pseudoheight of `node0` does not affect the pseudoheight of computed node
    // This is only important if we stabilise manually after updating _values of inputs that lead to node0 and the computed dynamic graph
    // TODO: investigate how to make sure that the outdated graph is not updated before node0
    public static func flatMap<Value0, NewValue>(_ node0: Node<Value0>, _ transform: @escaping (Value0) -> Node<NewValue>) -> Node<NewValue> {

        let _node0 = map(node0, { $0 })

        var recompute = true
        let observer = _node0.observe { _ in
            recompute = true
        }

        var _intermediate: Node<NewValue>? = nil
        var _result: Node<NewValue>? = nil

        let result = Node<NewValue>(
            computeValue: { [observer, weak _result] in
                guard recompute else { return _intermediate!.value }
                defer { recompute = false }

                // TODO: investigate why capture list doesn't work
                let _ = observer

                let intermediate = transform(node0.value)
                _intermediate = intermediate
                if let result = _result {
                    intermediate.addHigherNode(result)
                }
                return intermediate.value
            },
            getMaxChildPseudoHeight: {
                return max(
                    _intermediate!.pseudoHeight,
                    _node0.pseudoHeight
                )
            }
        )

        _node0.addHigherNode(result)

        _result = result
        _intermediate!.addHigherNode(result)
        
        return result
    }
}

extension Incremental {

    public static func stabilize(inputsChanged: [InputBase]) {
        var queue = BucketQueue<NodeBase>()

        func insert(_ result: NodeBase) {
            queue.insert(result, at: result.pseudoHeight)
        }

        for input in inputsChanged {
            insert(input.getNode())
        }

        var index = 0

        while index < queue.buckets.count {
            for box in uniqueObjects(queue.buckets[index]) {
                if box.dirtyPseudoHeight {
                    box.recomputePseudoHeight()
                }
                guard index == box.pseudoHeight else { insert(box); continue }
                guard box.recomputeValue() else { continue }
                for higherNode in box.getHigherNodes() {
                    insert(higherNode)
                }
            }

            index += 1
        }
    }
}
