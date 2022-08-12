//
//  Created by Jeffrey Bergier on 2022/07/04.
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

import SwiftUI

extension Binding {
    public func map<T>(get: @escaping (Value) -> T, set: @escaping (T) -> Value) -> Binding<T> {
        .init {
            get(self.wrappedValue)
        } set: {
            self.wrappedValue = set($0)
        }
    }
}

extension Binding {
    public func compactMap<T>(`default`: T) -> Binding<T> where Value == Optional<T> {
        self.map(get: { $0 ?? `default` }, set: { $0 })
    }
}

extension Binding where Value == Optional<URL> {
    @available(*, deprecated, message: "This causes bugs where all the text disappears")
    public func mapString(default defaultValue: String = "") -> Binding<String> {
        self.map(get: { $0?.absoluteString ?? defaultValue }, set: { URL(string: $0) })
    }
    public func compactMap() -> Binding<URL> {
        self.map(get: { $0 ?? URL(string: "about:blank")! }, set: { $0 })
    }
}

extension Binding where Value == URL {
    @available(*, deprecated, message: "This causes bugs where all the text disappears")
    public func mapString(default defaultValue: URL = URL(string: "about:blank")!) -> Binding<String> {
        self.map(get: { $0.absoluteString }, set: { URL(string: $0) ?? defaultValue })
    }
}

extension Binding where Value == Optional<String> {
    public func compactMap() -> Binding<String> {
        self.map(get: { $0 ?? "" }, set: { $0 })
    }
}

extension Binding where Value == Optional<Int> {
    public func compactMap() -> Binding<Int> {
        self.map(get: { $0 ?? 0 }, set: { $0 })
    }
}

extension Binding where Value == Optional<Double> {
    public func compactMap() -> Binding<Double> {
        self.map(get: { $0 ?? 0 }, set: { $0 })
    }
}

extension Binding where Value == Bool {
    public var flipped: Binding<Bool> {
        self.map(get: { !$0 }, set: { !$0 })
    }
}

extension Binding where Value == Optional<Bool> {
    public func compactMap() -> Binding<Bool> {
        self.map(get: { $0 ?? false }, set: { $0 })
    }
}

extension Binding where Value: Collection & ExpressibleByArrayLiteral {
    public var isPresented: Binding<Bool> {
        return Binding<Bool> {
            !self.wrappedValue.isEmpty
        } set: {
            guard $0 == false else { return }
            self.wrappedValue = []
        }
    }
}
