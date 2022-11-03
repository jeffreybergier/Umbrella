//
//  Created by Jeffrey Bergier on 2022/05/12.
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

public enum Platform {
    case iOS, tvOS, macOS, watchOS
}

extension View {
    @ViewBuilder public func `if`(
        _ platform: Platform,
        @ViewBuilder modify: (Self) -> some View
    ) -> some View
    {
        if platform.boolValue {
            modify(self)
        } else {
            self
        }
    }
    
    @ViewBuilder public func `if`<Input>(
        value item: Input?,
        @ViewBuilder modify: (Self, Input) -> some View
    ) -> some View
    {
        if let item = item {
            modify(self, item)
        } else {
            self
        }
    }
    
    @ViewBuilder public func `if`(
        bool: Bool,
        @ViewBuilder modify: (Self) -> some View
    ) -> some View
    {
        if bool {
            modify(self)
        } else {
            self
        }
    }
    
    @ViewBuilder public func `if`(
        bool: Bool,
        @ViewBuilder modify: (Self) -> some View,
        @ViewBuilder else: (Self) -> some View
    ) -> some View
    {
        if bool {
            modify(self)
        } else {
            `else`(self)
        }
    }
    
    /// Lifts the current view into a closure so you can easily customize
    public func lift(@ViewBuilder modify: (Self) -> some View) -> some View {
        modify(self)
    }
}

extension Platform {
    public var boolValue: Bool {
        switch self {
        case .iOS:
            #if os(iOS)
            return true
            #else
            return false
            #endif
        case .tvOS:
            #if os(tvOS)
            return true
            #else
            return false
            #endif
        case .macOS:
            #if os(macOS)
            return true
            #else
            return false
            #endif
        case .watchOS:
            #if os(watchOS)
            return true
            #else
            return false
            #endif
        }
    }
}

