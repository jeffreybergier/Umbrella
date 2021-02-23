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

extension Alert {
    public init(_ error: UFError, dismissAction: @escaping () -> Void = {}) {
        if !error.options.isEmpty {
            self.init(RUFError: error, dismissAction: dismissAction)
        } else {
            self.init(UFError: error, dismissAction: dismissAction)
        }
    }
    
    private init(UFError error: UFError, dismissAction: @escaping () -> Void) {
        self.init(title: Text(error.title),
                  message: Text(error.message),
                  dismissButton: .cancel(Text(error.dismissTitle),
                                         action: dismissAction))
    }
    
    private init(RUFError error: UFError, dismissAction: @escaping () -> Void) {
        precondition(error.options.count == 1, "Currently only 1 recovery option is supported")
        self.init(title: Text(error.title),
                  message: Text(error.message),
                  primaryButton: .init(error.options[0]),
                  secondaryButton: .cancel(Text(error.dismissTitle),
                                           action: dismissAction))
    }
}

extension Alert.Button {
    public init(_ option: RecoveryOption) {
        if option.isDestructive {
            self = .destructive(Text(option.title), action: option.perform)
        } else {
            self = .default(Text(option.title), action: option.perform)
        }
    }
}
