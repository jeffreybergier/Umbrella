//
//  Created by Jeffrey Bergier on 2021/02/19.
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

public struct GenericError: UserFacingError {
    public var errorCode: Int
    public var errorUserInfo: [String : Any]
    public var message: LocalizedStringKey
    public var options: [RecoveryOption]
    
    public init(errorCode: Int,
                errorUserInfo: [String : Any] = [:],
                message: LocalizedStringKey,
                options: [RecoveryOption] = [])
    {
        self.errorCode = errorCode
        self.errorUserInfo = errorUserInfo
        self.message = message
        self.options = options
    }
    
    public init(_ error: NSError, options: [RecoveryOption] = []) {
        self.errorCode = error.code
        self.errorUserInfo = error.userInfo
        // TODO: Add support for localizedFailureReason
        self.message = .init(error.localizedDescription)
        self.options = options
    }
}
