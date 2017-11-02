# Incremental

Incremental computations in Swift.

Inspired by [Jane Street's Incremental](https://blog.janestreet.com/introducing-incremental/), written in OCaml.

## TODO

- [ ] Implement flatMap
- [ ] Remove memory cycles
- [ ] Add playground with examples
- [ ] Only propagate input if output is observed

## Purpose

Incremental is written to make it easier to transform an algorithm from a static to a dynamic one. This is especially useful for UI code, where one might want to have a computation done every frame. That computation might be too expensive if done from scratch, but might have a more efficient solution based on updating only the difference. By writing the solution in Incremental, the code should be very similar to a one-shot solution, while being more efficient at recomputing every step.

## Example: Average of 2

``` Swift
let initial = (0.0, 1.0)

// Simple
let _sum = initial.0 + initial.1
let _average = sum / 2.0

// Incremental
let inputs = (
	Input(0),
	Input(1)
)
let sum: Node<Double> = Incremental.map(inputs.0, inputs.1, +)
let average: Node<Double> = Incremental.map(sum) { $0 / 2.0 }

// We can observe changes to nodes
let observer = average.observe { print($0) }

inputs.0.value = 2.0 // prints "1.5"
```

## Example: Average of n

``` Swift
// Simple
func average(_ elements: [Double]) -> Double {
    let sum = elements.reduce(0, +)
    return sum / Double(elements.count)
}
```

We want to create an incremental version, of signature `[Node<Double>] -> Node<Double>`.

The thing to notice here is that reduce goes from the start to the end of the list, making n additions. An incremental computation is bounded by the number of nodes updated, and if we reuse the approach, we will have to do the same amount of work at every change.

Instead, we can try to reduce in parallel, adding the elements pairwise, like so:

``` Swift
// The array cannot be empty
func merge<Value>(_ elements: [Node<Value>], combine: @escaping (Value, Value) -> Value) -> Node<Value> {
	// There is only one element in the array
    guard 1 < elements.count else { return elements[0] }

    // Storage for merged nodes
    var halfArray = [Node<Value>]()
    halfArray.reserveCapacity(elements.count / 2)

    for index in 0 ..< elements.count / 2 {
        let lhs = elements[index * 2]
        let rhs = elements[index * 2 + 1]
        let combined = Incremental.map(lhs, rhs, combine)
        halfArray.append(combined)
    }

    // If there is an odd number of elements in the array, add the last one to the merged array
    if 1 == elements.count % 2 {
        halfArray.append(elements.last!)
    }

    // Recurse until all nodes have been merged
    return merge(halfArray, combine: combine)
}
```

This function creates a computation graph that is a binary tree, with the total merged value on top, with each branch containing the merged value of a sub-array. 

This allows us to write the incremental version of `average`:

``` Swift
func average(_ elements: [Node<Double>]) -> Node<Double> {
    let sum = merge(elements, combine: +)
    return Incremental.map(sum, { $0 / Double(elements.count)})
}
```

This can then be used like so:

``` Swift
let inputs = (0 ..< 100)
    .map(Double.init)
    .map(IncrementalInput.init)

let incrementals = inputs.map { $0.node }
let myAverage = average(incrementals)

myAverage.value // 49.5

inputs[0].value = 100

myAverage.value // 50.5
``` 
