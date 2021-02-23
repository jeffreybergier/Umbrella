//
//  Created by Jeffrey Bergier on 2020/11/24.
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
 Takes `NSFetchedResultsController` and tranform closure. This list lazily converts values
 with the provided closure. This way it is possible to not let NSManagedObjects leak into your UI
 layer in an efficient way. You probably want to use the transform to wrap the NSManagedObject
 in `ManagedObjectElementObserver` so that it can be observed.
 This struct has no way to return errors so you must call `performFetch` on your own before using.
 To prevent core data from leaking into your UI layer, use `AnyList`.
 Note: this struct is not tested because it relies on NSFetchedResultsController
 ```
try controller.performFetch()
return .success(
    AnyListObserver(
        FetchedResultsControllerListObserver(
            FetchedResultsControllerList(controller) {
                AnyElementObserver(ManagedObjectElementObserver($0, { AnyTag($0) }))
            }
        )
    )
)
 ```
 */
public struct FetchedResultsControllerList<Output, Input: NSManagedObject>: RandomAccessCollection {
    
    public typealias Index = Int
    public typealias Element = Output

    internal let frc: NSFetchedResultsController<Input>
    private let transform: (Input) -> Output

    /// Init with `NSFetchedResultsController`
    /// This class does not call `performFetch` on its own.
    /// Call `performFetch()` yourself before this is used.
    public init(_ frc: NSFetchedResultsController<Input>,
                _ transform: @escaping (Input) -> Output)
    {
        self.frc = frc
        self.transform = transform
    }

    // MARK: Swift.Collection Boilerplate
    public var startIndex: Index { self.frc.fetchedObjects!.startIndex }
    public var endIndex: Index { self.frc.fetchedObjects!.endIndex }
    public subscript(index: Index) -> Element { self.transform(self.frc.fetchedObjects![index]) }
}
