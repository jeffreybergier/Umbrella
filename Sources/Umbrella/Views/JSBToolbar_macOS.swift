//
//  Created by Jeffrey Bergier on 2022/12/18.
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

public struct JSBToolbar_macOS: ViewModifier {

    private var title:  LocalizedString
    private var done:   ActionLocalization?
    private var cancel: ActionLocalization?
    private var delete: ActionLocalization?
    
    public var actionDone:   (() -> Void)?
    public var actionCancel: (() -> Void)?
    public var actionDelete: (() -> Void)?

    public init(title:  LocalizedString,
                done:   ActionLocalization? = nil,
                cancel: ActionLocalization? = nil,
                delete: ActionLocalization? = nil,
                doneAction:   (() -> Void)? = nil,
                cancelAction: (() -> Void)? = nil,
                deleteAction: (() -> Void)? = nil)
    {
        self.title = title
        self.done = done
        self.cancel = cancel
        self.delete = delete
        self.actionDone = doneAction
        self.actionCancel = cancelAction
        self.actionDelete = deleteAction
    }
    
    public func body(content: Content) -> some View {
        #if os(macOS)
        VStack {
            self.fakeToolbar
                .padding()
            content
            Spacer()
        }
        #else
        Text("JSBToolbar_macOS unavailable")
        #endif
    }
    
    private var fakeToolbar: some View {
        ZStack {
            // This can overlap with buttons, but at least its centered
            JSBToolbarButtonStyleDone
                .action(text: .init(title: self.title))
                .label
            HStack {
                if let cancel {
                    JSBToolbarButtonStyleCancel
                        .action(text: cancel)
                        .button(item: self.actionCancel, action: { $0() })
                }
                if let delete {
                    JSBToolbarButtonStyleDelete
                        .action(text: delete)
                        .button(item: self.actionDelete, action: { $0() })
                }
                Spacer()
                if let done {
                    JSBToolbarButtonStyleDone
                        .action(text: done)
                        .button(item: self.actionDone, action: { $0() })
                }
            }
        }
    }
}
