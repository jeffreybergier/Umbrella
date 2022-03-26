//
//  Created by Jeffrey Bergier on 2022/03/26.
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
import SwiftUI

@propertyWrapper
public struct CDListQuery<In: NSManagedObject, Out, E: Error>: DynamicProperty {
    
    public typealias ReadTransform = (In) -> Out
    public typealias WriteTransform = (In, Out) -> Result<Void, E>
    
    public var onRead: ReadTransform
    public var onWrite: WriteTransform
    @FetchRequest public var request: FetchedResults<In>
    @EnvironmentObject public var errorEnvironment: EnvironmentQueue<E>.Environment
    
    public init(sort: [NSSortDescriptor] = [],
                predicate: NSPredicate? = nil,
                animation: Animation? = nil,
                onWrite: @escaping WriteTransform = { _, _ in .success(()) },
                onRead: @escaping ReadTransform)
    {
        _request = .init(entity: In.entity(),
                         sortDescriptors: sort,
                         predicate: predicate,
                         animation: animation)
        self.onRead = onRead
        self.onWrite = onWrite
    }
    
    public var wrappedValue: AnyRandomAccessCollection<Out> {
        TransformCollection(collection: self.request) { cd in
            self.onRead(cd)
        }
        .eraseToAnyRandomAccessCollection()
    }
    
    public var projectedValue: AnyRandomAccessCollection<Binding<Out>> {
        TransformCollection(collection: self.request) { cd in
            Binding {
                self.onRead(cd)
            } set: { newValue in
                guard let error = self.onWrite(cd, newValue).error else { return }
                self.errorEnvironment.value.append(error)
            }
        }
        .eraseToAnyRandomAccessCollection()
    }
    
}
