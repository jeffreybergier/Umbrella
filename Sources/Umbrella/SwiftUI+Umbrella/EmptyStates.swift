//
//  Created by Jeffrey Bergier on 2022/07/17.
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

extension Collection {
    public func view<Backup: View, Content: View>(
        @ViewBuilder content: @escaping (Self) -> Content,
        @ViewBuilder onEmpty: @escaping () -> Backup
    ) -> some View
    {
        NotEmpty(self, content: content, onEmpty: onEmpty)
    }
}

extension Optional {
    public func view<Backup: View, Content: View>(
        @ViewBuilder content: @escaping (Wrapped) -> Content,
        @ViewBuilder onNIL: @escaping () -> Backup
    ) -> some View
    {
        NotNIL(self, content: content, onNIL: onNIL)
    }
}

public struct NotEmpty<Value: Collection, Backup: View, Content: View>: View {
    
    private let value: Value
    private let backup: () -> Backup
    private let content: (Value) -> Content
    
    public init(_ value: Value,
                @ViewBuilder content: @escaping (Value) -> Content,
                @ViewBuilder onEmpty: @escaping () -> Backup)
    {
        self.value = value
        self.backup = onEmpty
        self.content = content
    }
    
    @ViewBuilder public var body: some View {
        if self.value.isEmpty {
            self.backup()
        } else {
            self.content(self.value)
        }
    }
}

public struct NotNIL<Value, Backup: View, Content: View>: View {
    
    private let value: Value?
    private let backup: () -> Backup
    private let content: (Value) -> Content
    
    public init(_ value: Value?,
                @ViewBuilder content: @escaping (Value) -> Content,
                @ViewBuilder onNIL: @escaping () -> Backup)
    {
        self.value = value
        self.backup = onNIL
        self.content = content
    }
    
    @ViewBuilder public var body: some View {
        if let value {
            self.content(value)
        } else {
            self.backup()
        }
    }
}
