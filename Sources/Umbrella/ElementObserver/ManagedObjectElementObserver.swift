//
//  Created by Jeffrey Bergier on 2020/11/26.
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
 Observes an NSManagedObject in  a way that is useful to SwiftUI. Also provides a transform that
 can be used so that NSManagedObject does not leak into your UI layer. Basic usage looks like:
 Note: This class is not tested because it relies on NSManagedObject
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
public class ManagedObjectElementObserver<Output, Input: NSManagedObject>: ElementObserver {
    
    public let objectWillChange: ObservableObjectPublisher
    public var value: Output { transform(_value) }
    public var isDeleted: Bool { _value.isDeleted }
    public let canDelete: Bool = true

    private let _value: Input
    private let transform: (Input) -> Output

    public init(_ input: Input, _ transform: @escaping (Input) -> Output) {
        self._value = input
        self.transform = transform
        self.objectWillChange = input.objectWillChange
    }
    
    public static func == (lhs: ManagedObjectElementObserver<Output, Input>, rhs: ManagedObjectElementObserver<Output, Input>) -> Bool {
        return lhs._value == rhs._value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_value)
    }
    
    #if DEBUG
    deinit {
        log.verbose()
    }
    #endif
}
