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

import Foundation

/// Use with `UserFacingErrorAlert` to easily present errors to the user
public protocol UserFacingError: CustomNSError {
    /// Default implementation is "Error"
    var title: LocalizationKey { get }
    var message: LocalizationKey { get }
    /// Default implementation is "Dismiss"
    var dismissTitle: LocalizationKey { get }
    var isCritical: Bool { get }
    /// Default implementation is empty.
    /// If options are present the Alert/UI for the error should show the options
    var options: [RecoveryOption] { get }
}

public struct RecoveryOption: Identifiable {
    public var id = Int.random(in: 0..<Int.max)
    public var title: LocalizationKey
    public var isDestructive: Bool
    public var perform: () -> Void
    public init(title: LocalizationKey,
                isDestructive: Bool = false,
                perform: @escaping () -> Void)
    {
        self.title = title
        self.isDestructive = isDestructive
        self.perform = perform
    }
}
