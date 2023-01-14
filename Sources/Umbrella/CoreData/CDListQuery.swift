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
public struct CDListQuery<In: NSManagedObject, Out>: DynamicProperty {
    
    public typealias OnError = (Swift.Error) -> Void
    public typealias ReadTransform = (In) -> Out
    public typealias WriteTransform = (In, Out) -> Result<Void, Swift.Error>
    
    private let onRead: ReadTransform
    @StateObject private var onWrite: SecretBox<WriteTransform?>
    @StateObject private var onError: SecretBox<OnError?>
    
    @FetchRequest public var request: FetchedResults<In>
    @Environment(\.errorResponder) private var errorResponder

    public init(sort:      [SortDescriptor<In>] = [],
                predicate: NSPredicate? = nil,
                animation: Animation? = .default,
                onError:   OnError? = nil,
                onWrite:   WriteTransform? = nil,
                onRead:    @escaping ReadTransform)
    {
        self.onRead  = onRead
        _onWrite     = .init(wrappedValue: .init(onWrite))
        _onError     = .init(wrappedValue: .init(onError))
        _request     = .init(entity: In.entity(),
                             sortDescriptors: sort.map { NSSortDescriptor($0) },
                             predicate: predicate,
                             animation: animation)
    }
    
    public var wrappedValue: some RandomAccessCollection<Out> {
        self.request.lazy.map(self.onRead)
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<Out>> {
        self.request.lazy.map { cd in
            Binding {
                self.onRead(cd)
            } set: { newValue in
                guard let onWrite = self.onWrite.value else {
                    assertionFailure("Attempted to write value, but no write closure was given")
                    return
                }
                guard let error = onWrite(cd, newValue).error else { return }
                let errorHandler = self.onError.value ?? self.errorResponder
                errorHandler(error)
            }
        }
    }
    
    public func setOnWrite(_ newValue: WriteTransform?) {
        self.onWrite.value = newValue
    }
    
    public func setOnError(_ newValue: OnError?) {
        self.onError.value = newValue
    }
    
    public func setPredicate(_ newValue: NSPredicate?) {
        self.request.nsPredicate = newValue
    }
    
    public func setSortDescriptors(_ newValue: [SortDescriptor<In>] = []) {
        self.request.sortDescriptors = newValue
    }
    
}
