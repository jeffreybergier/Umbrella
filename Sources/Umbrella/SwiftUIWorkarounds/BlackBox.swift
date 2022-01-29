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

/// Takes any value and puts it into a box that is `ObservableObject`.
/// Also makes it `Identifiable` if the value is `Identifiable`
public class BlackBox<Value>: ObservableObject {
    public var isObservingValue: Bool
    public let objectDidChange = ObservableObjectPublisher()
    public var value: Value {
        willSet {
            guard self.isObservingValue else { return }
            self.objectWillChange.send()
        }
        didSet {
            ("BlackBoxDidSet: " + String(describing: self.value)).log(as: .verbose)
            guard self.isObservingValue else { return }
            self.objectDidChange.send()
        }
    }
    public init(_ value: Value, isObservingValue: Bool = true) {
        self.value = value
        self.isObservingValue = isObservingValue
    }
}

extension BlackBox: Identifiable where Value: Identifiable {
    public var id: Value.ID {
        return self.value.id
    }
}
