//
//  Created by Jeffrey Bergier on 2022/01/10.
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

// TODO: Update this to safe when SwiftUI allows
// @MainActor, uncommenting this causes build failure in Swift 6
public struct isFallbackKey: @preconcurrency PreferenceKey {
    @MainActor public static var defaultValue: Bool = false
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

public struct JSBText<T: StringProtocol, S: StringProtocol>: View {
    
    private let titleKey: T
    private let text: S?
    
    public init(_ titleKey: T, text: S?) {
        self.titleKey = titleKey
        self.text = text
    }
    
    public var body: some View {
        if let trimmed = self.text?.trimmed {
            Text(trimmed)
        } else {
            Text(self.titleKey)
                .preference(key: isFallbackKey.self, value: true)
        }
    }
}
