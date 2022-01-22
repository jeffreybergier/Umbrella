//
//  Created by Jeffrey Bergier on 2021/02/17.
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

public typealias UFEAlert = UserFacingErrorAlert

public struct UserFacingErrorAlert: ViewModifier {
    
    @Binding private var error: UserFacingError?
    private let dismissAction: ((UserFacingError) -> Void)?
    
    public init(_ error: Binding<UserFacingError?>,
                dismissAction: ((UserFacingError) -> Void)? = nil)
    {
        _error = error
        self.dismissAction = dismissAction
    }
    
    public func body(content: Content) -> some View {
        content.modifier(self.render())
    }
    
    private func render() -> some ViewModifier {
        JSBAlert(item: self.$error,
                 titleKey: self.error?.title ?? "Noun.Error",
                 message: { Text($0.message) })
        { error in
            ForEach(error.options) { option in
                if option.isDestructive {
                    Button(option.title,
                           role: .destructive,
                           action: option.perform)
                } else {
                    Button(option.title,
                           action: option.perform)
                }
            }
            Button(error.dismissTitle, role: .cancel) {
                self.dismissAction?(error)
            }
        }
    }
}
