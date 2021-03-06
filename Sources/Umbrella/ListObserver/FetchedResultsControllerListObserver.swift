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

import CoreData
import Combine

/**
 Takes an `FetchedResultsControllerList` and adapts it for use with SwiftUI.
 This class has no way to return errors so you must call performFetch on your own before
 The class is used.
 To prevent your data model (Core Data) from leaking into your UI layer use `AnyListObserver`:
 ```
 try controller.performFetch()
 return .success(
     AnyListObserver(
         FetchedResultsControllerListObserver(controller) {
             AnyElementObserver(ManagedObjectElementObserver($0, { AnyTag($0) }))
         }
     )
 )
 ```
 */
public class FetchedResultsControllerListObserver<Output, Input: NSManagedObject>:
    NSObject, ListObserver, NSFetchedResultsControllerDelegate
{
    public typealias Transform = (Input) -> Output

    @Published public var data: AnyRandomAccessCollection<Output>
    private let controller: NSFetchedResultsController<Input>
    private let transform: Transform

    public init(_ controller: NSFetchedResultsController<Input>, transform: @escaping Transform) {
        self.controller = controller
        self.transform = transform
        self.data = controller.fetchedObjects?.lazy.map(transform).eraseToAnyRandomAccessCollection() ?? .empty
        super.init()
        controller.delegate = self
    }

    // MARK: NSFetchedResultsControllerDelegate
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.data = self.controller.fetchedObjects?.lazy.map(self.transform).eraseToAnyRandomAccessCollection() ?? .empty
        #if DEBUG
        __objectDidChange.send()
        #endif
    }
    
    deinit {
        self.controller.delegate = nil
        #if DEBUG
        log.verbose()
        #endif
    }
    
    #if DEBUG
    // MARK: Testing Only
    
    /// for testing only
    public var __objectDidChange = ObservableObjectPublisher()
    
    /// for testing only
    internal init(__TESTING: Bool) where Input == NSManagedObject, Output == Never {
        self.controller = NSFetchedResultsController()
        self.transform = { _ in fatalError() }
        self.data = .init([])
        super.init()
    }
    #endif
}
