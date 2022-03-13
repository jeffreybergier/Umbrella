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

public struct UserFacingErrorAlert<B: EnvironmentBundleProtocol>: ViewModifier {
    
    /// See EnvironmentBundle file for information
    public enum Configuration<T: EnvironmentBundleProtocol> {
        case mainBundle, environmentBundle(EnvironmentBundle<T>)
    }
    
    @Binding private var error: UserFacingError?
    private let dismissAction: ((UserFacingError) -> Void)?
    
    @EnvironmentBundle<B> private var bundle
    
    public init(_ error: Binding<UserFacingError?>,
                dismissAction: ((UserFacingError) -> Void)? = nil)
    {
        _error = error
        self.dismissAction = dismissAction
    }
    
    // TODO: Not sure if this init works
    public init(_ error: Binding<UserFacingError>?,
                dismissAction: ((UserFacingError) -> Void)? = nil)
    {
        _error = Binding {
            return error?.wrappedValue
        } set: {
            guard let newValue = $0 else { return }
            error?.wrappedValue = newValue
        }
        self.dismissAction = dismissAction
    }
    
    public func body(content: Content) -> some View {
        content.modifier(self.render())
    }
    
    /// shortcut function
    private func sc(_ key: LocalizationKey) -> LocalizedString {
        return self.bundle.localized(key: key)
    }
    
    private func render() -> some ViewModifier {
        JSBAlert(item: self.$error,
                 titleKey: self.sc(self.error?.title ?? ""),
                 message: { Text(self.sc($0.message)) })
        { error in
            ForEach(error.options) { option in
                if option.isDestructive {
                    Button(self.sc(option.title), role: .destructive) {
                        option.perform()
                        self.dismissAction?(error)
                    }
                } else {
                    Button(self.sc(option.title)) {
                        option.perform()
                        self.dismissAction?(error)
                    }
                }
            }
            Button(self.sc(error.dismissTitle), role: .cancel) {
                self.dismissAction?(error)
            }
        }
    }
}
