//
//  Created by Jeffrey Bergier on 2021/02/16.
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
import XCGLogger
import CryptoKit
import ServerlessLogger

/// Dummy singleton that doesn't do much except hold the default logger
public enum Loggable {
    
    public internal(set) static var `default`: XCGLogger?
    
    /// Optionally configure kPrivate keys if serverlesslogger  feature is desired
    public static func configure(endpointURL: URL? = nil,
                                 keyData: Data? = nil,
                                 delegate: ServerlessLoggerErrorDelegate? = nil)
    {
        let identifier = "ServerlessLogger"
        var _log: XCGLogger?
        if #available(iOS 13.0, *), let loggerEndpoint = endpointURL, let keyData = keyData {
            let endpoint = URLComponents(url: loggerEndpoint, resolvingAgainstBaseURL: false)!
            let key = SymmetricKey(data: keyData)
            let config = Logger.DefaultSecureConfiguration(identifier: identifier,
                                                           endpointURL: endpoint,
                                                           hmacKey: key,
                                                           logLevel: .warning,
                                                           errorDelegate: delegate)
            _log = try? Logger(configuration: config, includeDefaultXCGDestinations: true, includeDefaultJSBDestinations: true)
        }
        let log = _log ?? XCGLogger(identifier: identifier, includeDefaultDestinations: true)
        #if DEBUG
        log.setup(level: .verbose, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .debug)
        #else
        log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
        #endif
        self.default = log
    }
}
