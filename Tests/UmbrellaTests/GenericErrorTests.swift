//
//  Created by Jeffrey Bergier on 2021/02/22.
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

import XCTest
import Umbrella
import SwiftUI

class GenericErrorTests: XCTestCase {
    
    lazy var realError: NSError = {
        do {
            try FileManager.default.contentsOfDirectory(atPath: "xxx://this-is-not-a-path")
            fatalError()
        } catch {
            return error as NSError
        }
    }()
    
    func test_initWithNSError() {
        let error = GenericError(self.realError)
        XCTAssertEqual(error.errorCode, 260)
        XCTAssertEqual(error.message.TEST_key, self.realError.localizedDescription)
        XCTAssertEqual(Set(error.errorUserInfo.keys),
                       Set(["NSUnderlyingError", "NSFilePath", "NSUserStringVariant"]))
        
        // Sanity tests
        XCTAssertNil(self.realError.localizedRecoverySuggestion)
    }
}

extension LocalizedStringKey {
    var TEST_key: String {
        let description = "\(self)"
        let components = description.components(separatedBy: "key: \"")
            .map { $0.components(separatedBy: "\",") }
        return components[1][0]
    }
}
