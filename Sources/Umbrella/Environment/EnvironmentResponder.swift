//
//  Created by Jeffrey Bergier on 2022/06/26.
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

// TODO: Not possible to make this generic yet

@available(*, deprecated, message: "Roll Your Own")
public struct EnvironmentResponderAny: EnvironmentKey {
    public static var defaultValue: ((Any) -> Void)? = nil
}

extension EnvironmentValues {
    public var anyResponder: ((Any) -> Void)? {
        get { self[EnvironmentResponderAny.self] }
        set { self[EnvironmentResponderAny.self] = newValue }
    }
}

@available(*, deprecated, message: "Use ErrorStorage")
public struct EnvironmentResponderError: EnvironmentKey {
    public static var defaultValue: (Swift.Error) -> Void = { event in
        assertionFailure("No Responder: \(event)")
    }
}

extension EnvironmentValues {
    public var errorResponder: (Swift.Error) -> Void {
        get { self[EnvironmentResponderError.self] }
        set { self[EnvironmentResponderError.self] = newValue }
    }
}
