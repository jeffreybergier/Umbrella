//
//  Created by Jeffrey Bergier on 2021/01/31.
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

/// SwiftUI ObservableObject for Lists of items
/// See `FetchedResultsControllerList` for details on how to use.
public protocol ListObserver: ObservableObject {
    associatedtype Collection: RandomAccessCollection
    var data: Collection { get }
    #if DEBUG
    // For testing only
    var __objectDidChange: Self.ObjectWillChangePublisher { get }
    #endif
}

/// Typeeraser for `ListObserver`
/// See `FetchedResultsControllerList` for details on how to use.
public class AnyListObserver<Collection: RandomAccessCollection>: ListObserver {
    
    public let objectWillChange: ObservableObjectPublisher
    
    public var data: Collection { _data() }
    private let _data: () -> Collection
    
    #if DEBUG
    public var __objectDidChange: ObservableObjectPublisher { ___objectDidChange() }
    private var ___objectDidChange: () -> ObservableObjectPublisher
    #endif
        
    public init<T: ListObserver>(_ observer: T)
          where T.Collection == Collection,
                T.ObjectWillChangePublisher == ObjectWillChangePublisher
    {
        _data = { observer.data }
        ___objectDidChange = { observer.__objectDidChange }
        self.objectWillChange = observer.objectWillChange
    }
}
