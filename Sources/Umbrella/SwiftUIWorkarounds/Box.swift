//
//  Created by Jeffrey Bergier on 2021/03/08.
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
import Foundation

/// Takes an `ObservableObject` and puts it into an `ObservableObject` box.
/// This is useful in the case where your SwiftUI.View needs to change the object its observing
public class Box<Value: ObservableObject>: ObservableObject {
    
    public var value: Value {
        willSet { self.objectWillChange.send() }
        didSet { self.subscribe() }
    }
    
    private var token: AnyCancellable?
    
    public init(_ value: Value) {
        self.value = value
        self.subscribe()
    }
    
    private func subscribe() {
        self.token = self.value.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}
