//
//  Created by Jeffrey Bergier on 2021/02/18.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

public protocol QueueProtocol {
    associatedtype Element
    var isEmpty: Bool { get }
    var peek: Element? { get }
    mutating func append(_: Element)
    mutating func pop() -> Element?
}

public struct Queue<Element>: QueueProtocol, ExpressibleByArrayLiteral {
    
    // TODO: Use a more efficient data storage
    // Internal for testing only
    internal var _storage: [Element] = []
    
    public var isEmpty: Bool {
        return _storage.isEmpty
    }
    
    public var peek: Element? {
        return _storage.first
    }
    
    public init() {}
    
    public init(arrayLiteral elements: Element...) {
        _storage = elements
    }
    
    public mutating func append(_ element: Element) {
        _storage.append(element)
    }
    
    public mutating func append(_ queue: Queue<Element>) {
        _storage += queue._storage
    }
    
    public mutating func removeAll() {
        _storage = []
    }
    
    @discardableResult
    public mutating func pop() -> Element? {
        guard let next = _storage.first else { return nil }
        _storage = Array(_storage.dropFirst())
        return next
    }
}
