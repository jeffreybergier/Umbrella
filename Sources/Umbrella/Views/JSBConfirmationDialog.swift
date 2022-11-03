//
//  Created by Jeffrey Bergier on 2022/01/16.
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

@available(*, deprecated, message: "Is this used?")
public struct JSBConfirmationDialog<P, A: View, T: StringProtocol>: ViewModifier {
    @Binding private var isPresented: Bool
    private var titleKey: T
    private var presenting: P?
    private var actions: (P) -> A
    public init(item: Binding<P?>,
                titleKey: T,
                @ViewBuilder actions: @escaping (P) -> A)
    {
        self.titleKey = titleKey
        self.actions = actions
        self.presenting = item.wrappedValue
        _isPresented = Binding {
            item.wrappedValue != nil
        } set: { newValue in
            guard newValue == false else { return }
            item.wrappedValue = nil
        }
    }
    public func body(content: Content) -> some View {
        content
            .confirmationDialog(self.titleKey,
                                isPresented: self.$isPresented,
                                presenting: self.presenting,
                                actions: self.actions)
    }
}
