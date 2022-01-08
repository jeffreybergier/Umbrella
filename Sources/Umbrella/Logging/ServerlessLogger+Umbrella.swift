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

import XCGLogger
import Foundation

/// Use this file to make any Type in the system loggable

/// Must call Loggable.configure before first use
public var log: XCGLogger = XCGLogger.default

extension String: LoggableProtocol {}

// Can't extend a protocol to inherit another protocol
extension Error /*: LoggableProtocol */ {
    public func log(in log: XCGLogger? = Umbrella.log,
                    as level: XCGLogger.Level = .error,
                    functionName: StaticString = #function,
                    fileName: StaticString = #file,
                    lineNumber: Int = #line,
                    userInfo: [String: Any] = [:])
    {
        LoggableProtocolImp(on: self,
                            in: log,
                            as: level,
                            functionName: functionName,
                            fileName: fileName,
                            lineNumber: lineNumber,
                            userInfo: userInfo)
    }
}

/// Extend any type with this protocol to get logging behavior for free.
/// If you can't extend your object because its already a protocol,
/// use `LoggableProtocolImp` to get the behavior manually.
public protocol LoggableProtocol { }

extension LoggableProtocol {
    /// Log this object
    public func log(in log: XCGLogger? = Umbrella.log,
                    as level: XCGLogger.Level = .error,
                    functionName: StaticString = #function,
                    fileName: StaticString = #file,
                    lineNumber: Int = #line,
                    userInfo: [String: Any] = [:])
    {
        LoggableProtocolImp(on: self,
                            in: log,
                            as: level,
                            functionName: functionName,
                            fileName: fileName,
                            lineNumber: lineNumber,
                            userInfo: userInfo)
    }
}

/// Implementation of how the logging function should work
// swiftlint:disable:next function_parameter_count
internal func LoggableProtocolImp(on object: Any,
                                  in log: XCGLogger? = Umbrella.log,
                                  as level: XCGLogger.Level,
                                  functionName: StaticString,
                                  fileName: StaticString,
                                  lineNumber: Int,
                                  userInfo: [String: Any])
{
    guard let log = log else {
        NSLog("Attempted to log but LogConfigure not performed yet.")
        return
    }

    if let error = object as? UserFacingError, error.isCritical == false {
        log.info(object, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
        return
    }

    log.logln(object, level: level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo)
}

