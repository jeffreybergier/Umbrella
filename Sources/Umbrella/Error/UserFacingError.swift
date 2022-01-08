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

public typealias UFError = UserFacingError

public protocol UserFacingError: CustomNSError {
    /// Default implementation is "Noun.Error"
    var title: LocalizedStringKey { get }
    var message: LocalizedStringKey { get }
    /// Default implementation is "Verb.Dismiss"
    var dismissTitle: LocalizedStringKey { get }
    var isCritical: Bool { get }
    /// Default implementation is empty.
    /// If options are present the Alert/UI for the error should show the options
    var options: [RecoveryOption] { get }
}

public struct RecoveryOption {
    public var title: LocalizedStringKey
    public var isDestructive: Bool
    public var perform: () -> Void
    public init(title: LocalizedStringKey,
                isDestructive: Bool = false,
                perform: @escaping () -> Void)
    {
        self.title = title
        self.isDestructive = isDestructive
        self.perform = perform
    }
}

extension UserFacingError {
    /// Default implementation. Override to customize
    public var title: LocalizedStringKey {
        return "Noun.Error"
    }
    /// Default implementation. Override to customize
    public var dismissTitle: LocalizedStringKey {
        return "Verb.Dismiss"
    }
    
    public var options: [RecoveryOption] {
        return []
    }
    public var isCritical: Bool { false }
}

extension UserFacingError {
    /// Default implementation `com.your.bundle.id.ParentType.ErrorType`
    /// Override if you want something custom or automatic implementation no longer works
    /// Automatic implementation uses fragile hackery.
    public static var errorDomain: String {
        let typeString = __typeName(self)
        let bundle = Bundle.for(type: self) ?? .main
        let id = bundle.bundleIdentifier ?? "unknown.bundleid"
        let domain = id + "." + typeString
        return domain
    }
}
