//
//  Created by Jeffrey Bergier on 2021/02/01.
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
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

public enum Either<A, B> {
    case a(A), b(B)
}

public struct If<A: ViewModifier, B: ViewModifier>: ViewModifier {
    private let value: Either<A, B>?
    public init(_ value: Either<A, B>?) {
        self.value = value
    }
    public init(_ isTrue: Bool, _ yes: A, _ no: B) {
        self.value = isTrue ? .a(yes) : .b(no)
    }
    @ViewBuilder public func body(content: Content) -> some View {
        if let value = self.value {
            switch value {
            case .a(let a):
                content.modifier(a)
            case .b(let b):
                content.modifier(b)
            }
        } else {
            content
        }
    }
}

extension If {
    public static func mac(and isTrue: Bool, _ yes: A, _ no: B) -> If<A, B> {
        #if os(macOS)
        return If(isTrue, yes, no)
        #else
        return If(nil)
        #endif
    }
    public static func mac(_ yes: A) -> If<A, B> where B == Never {
        #if os(macOS)
        return If(.a(yes))
        #else
        return If(nil)
        #endif
    }
    public static func iOS(and isTrue: Bool, _ yes: A, _ no: B) -> If<A, B> {
        #if os(iOS)
        return If(isTrue, yes, no)
        #else
        return If(nil)
        #endif
    }
    public static func iOS(and isTrue: Bool, _ yes: A) -> If<A, B> where B == Never {
        #if os(iOS)
        guard isTrue else { return If(nil) }
        return If(.a(yes))
        #else
        return If(nil)
        #endif
    }
    public static func iOS(_ yes: A) -> If<A, B> where B == Never {
        #if os(iOS)
        return If(.a(yes))
        #else
        return If(nil)
        #endif
    }
    public static func some(_ some: A?) -> If<A,B> where B == Never {
        guard let some = some else { return If(nil) }
        return If(.a(some))
    }
}

extension Never: ViewModifier {}
