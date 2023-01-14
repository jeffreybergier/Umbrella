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

/// Conform to this protoocal to help systemize your conversion to and from CodableError
@available(*, deprecated, message:"Use `TODO:Something`")
public protocol CodableErrorConvertible {
    init?(decode: CodableError)
    var encode: CodableError { get }
}

/// Use to store errors in something that requires codable such as `SceneStorage` / `AppStorage`
@available(*, deprecated, message:"Use `TODO:Something`")
public struct CodableError: Codable, CustomNSError, Identifiable, Hashable {
    
    public var id: UUID = .init()
    public var errorCode: Int
    public var errorDomain: String
    public var arbitraryData: Data?
    
    public init(domain: String,
                code: Int,
                arbitraryData: Data? = nil)
    {
        self.errorCode = code
        self.errorDomain = domain
        self.arbitraryData = arbitraryData
    }
    
    public init(_ error: Swift.Error) {
        assert(type(of: error) != CodableError.self)
        self.init(error as NSError)
    }
    
    public init(_ error: NSError) {
        self.errorCode = error.code
        self.errorDomain = error.domain
        self.arbitraryData = String(describing: error).data(using: .utf8)
    }
}
