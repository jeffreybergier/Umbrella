//
//  Created by Jeffrey Bergier on 2020/11/25.
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

import Combine

/// Type eraser for customized lists.
/// See `FetchedResultsControllerList` for more details
public struct AnyList<Element>: RandomAccessCollection {
    
    public static var empty: AnyList<Element> {
        return AnyList(__List_Empty())
    }

    public typealias Index = Int
    public typealias Element = Element

    private let _startIndex: () -> Index
    private let _endIndex: () -> Index
    private let _subscript: (Index) -> Element

    public init<T: RandomAccessCollection>(_ collection: T)
    where T.Element == Element,
          T.Index == Int
    {
        _startIndex = { collection.startIndex }
        _endIndex = { collection.endIndex }
        _subscript = { collection[$0] }
    }

    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { _startIndex() }
    public var endIndex: Index { _endIndex() }
    public subscript(index: Index) -> Element { _subscript(index) }
}

fileprivate struct __List_Empty<T>: RandomAccessCollection {
    internal typealias Index = Int
    internal typealias Element = T
    
    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { 0 }
    public var endIndex: Index { 0 }
    public subscript(index: Index) -> Element { fatalError() }
}
