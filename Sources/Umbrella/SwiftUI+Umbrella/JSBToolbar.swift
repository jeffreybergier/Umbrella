//
//  Created by Jeffrey Bergier on 2022/06/25.
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

public struct JSBToolbar: ViewModifier {

    private var title:  LocalizedString
    private var done:   ActionLocalization
    private var cancel: ActionLocalization?
    private var delete: ActionLocalization?
    
    public var actionDone:   () -> Void
    public var actionCancel: (() -> Void)?
    public var actionDelete: (() -> Void)?
    
    private var styleDone:   some ActionStyle = ActionStyleImp(label: .titleOnly)
    private var styleCancel: some ActionStyle = ActionStyleImp(button: .cancel, label: .titleOnly)
    private var styleDelete: some ActionStyle = ActionStyleImp(button: .destructive, label: .titleOnly)

    public init(title:  LocalizedString,
                done:   ActionLocalization,
                cancel: ActionLocalization? = nil,
                delete: ActionLocalization? = nil,
                doneAction: @escaping () -> Void,
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
        content
            .navigationTitle(self.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    self.styleDone.action(text: self.done).button(action: self.actionDone)
                }
                ToolbarItem(placement: .cancellationAction) {
                    if let cancel {
                        self.styleCancel
                            .action(text: cancel)
                            .button(item: self.actionCancel, action: { $0() })
                    } else if let delete {
                        self.styleDelete
                            .action(text: delete)
                            .button(item: self.actionDelete, action: { $0() })
                    }
                }
            }
            .navigationBarTitleDisplayModeInline
    }
}
