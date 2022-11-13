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
    @ViewBuilder
    public func view<Backup: View, Content: View>(
        @ViewBuilder content: @escaping (Self) -> Content,
        @ViewBuilder onEmpty: @escaping () -> Backup
    ) -> some View
    {
        if self.isEmpty == false  {
            content(self)
        } else {
            onEmpty()
        }
    }
    
    @ViewBuilder
    public func view<Content: View>(
        @ViewBuilder content: @escaping (Self) -> Content
    ) -> some View
    {
        self.view(content: content, onEmpty: {})
    }
}

extension Optional {
    
    @ViewBuilder
    public func view<Backup: View, Content: View>(
        @ViewBuilder content: @escaping (Wrapped) -> Content,
        @ViewBuilder onNIL: @escaping () -> Backup
    ) -> some View
    {
        if let self {
            content(self)
        } else {
            onNIL()
        }
    }
    
    @ViewBuilder
    public func view<Backup: View, Content: View, O1>(
        _ other1: O1?,
        @ViewBuilder content: @escaping (Wrapped, O1) -> Content,
        @ViewBuilder onNIL: @escaping () -> Backup
    ) -> some View
    {
        if let self, let other1 {
            content(self, other1)
        } else {
            onNIL()
        }
    }
    
    @ViewBuilder
    public func view<Backup: View, Content: View, O1, O2>(
        _ other1: O1?,
        _ other2: O2?,
        @ViewBuilder content: @escaping (Wrapped, O1, O2) -> Content,
        @ViewBuilder onNIL: @escaping () -> Backup
    ) -> some View
    {
        if let self, let other1, let other2 {
            content(self, other1, other2)
        } else {
            onNIL()
        }
    }
    
    @ViewBuilder
    public func view<Content: View>(
        @ViewBuilder content: @escaping (Wrapped) -> Content
    ) -> some View
    {
        self.view(content: content, onNIL: {})
    }
    
    @ViewBuilder
    public func view<Content: View, O1>(
        _ other1: O1?,
        @ViewBuilder content: @escaping (Wrapped, O1) -> Content
    ) -> some View
    {
        self.view(other1, content: content, onNIL: {})
    }
    
    @ViewBuilder
    public func view<Content: View, O1, O2>(
        _ other1: O1?,
        _ other2: O2?,
        @ViewBuilder content: @escaping (Wrapped, O1, O2) -> Content
    ) -> some View
    {
        self.view(other1, other2, content: content, onNIL: {})
    }
}
