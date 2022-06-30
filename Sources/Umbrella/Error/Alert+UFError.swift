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

public struct UserFacingErrorAlert<B: EnvironmentBundleProtocol, E: Error>: ViewModifier {
    
    @Binding private var error: E?
    private let transform: (E) -> UserFacingError
    private let dismissAction: ((E) -> Void)?
    
    @EnvironmentBundle<B> private var bundle
    
    public init(_ error: Binding<E?>,
                dismissAction: ((E) -> Void)? = nil,
                transform: @escaping (E) -> UserFacingError)
    {
        _error = error
        self.transform = transform
        self.dismissAction = dismissAction
    }
    
    // TODO: Fix so that if E is already user facing error I have a convenient init
//    public init(_ error: Binding<UserFacingError?>,
//                dismissAction: ((UserFacingError) -> Void)? = nil)
//    {
//        _error = error
//        self.dismissAction = dismissAction
//    }
    
    public func body(content: Content) -> some View {
        content.modifier(self.render())
    }
    
    /// shortcut function
    private func sc(_ key: LocalizationKey) -> LocalizedString {
        return self.bundle.localized(key: key)
    }
    
    private func ufe(_ input: E?) -> UserFacingError? {
        guard let input else { return nil }
        return self.transform(input)
    }
    
    // TODO: Cache this result from the transform?
    private func ufe(_ input: E) -> UserFacingError {
        self.transform(input)
    }
    
    private func render() -> some ViewModifier {
        JSBAlert(item: self.$error,
                 titleKey: self.sc(self.ufe(self.error)?.title ?? ""),
                 message: { Text(self.sc(self.ufe($0).message)) })
        { error in
            ForEach(self.ufe(error).options) { option in
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
            Button(self.sc(self.ufe(error).dismissTitle), role: .cancel) {
                self.dismissAction?(error)
            }
        }
    }
}
