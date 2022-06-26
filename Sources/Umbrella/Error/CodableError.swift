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

import Foundation

public struct CodableError: Codable, CustomNSError, Identifiable {
    
    public var id: String { self.errorDomain + "::" + String(describing: self.errorCode) }
    public var errorCode: Int
    public var errorDomain: String
    public var errorUserInfo: [String: String]
    
    public init(domain: String,
                code: Int,
                userInfo: [String:String] = [:])
    {
        self.errorCode = code
        self.errorDomain = domain
        self.errorUserInfo = userInfo
    }
    
    public init(_ error: NSError) {
        self.errorCode = error.code
        self.errorDomain = error.domain
        self.errorUserInfo = error.userInfo.mapValues { String(describing: $0) }
    }
}
