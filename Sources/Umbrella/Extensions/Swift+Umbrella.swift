//
//  Created by Jeffrey Bergier on 2020/12/02.
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

extension AnyRandomAccessCollection {
    public static var empty: Self { .init([]) }
}

extension RandomAccessCollection {
    public func eraseToAnyRandomAccessCollection() -> AnyRandomAccessCollection<Self.Element> {
        return AnyRandomAccessCollection(self)
    }
}

extension Result {
    public var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    public var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    /// Lazily chains multiple result closures.
    /// On error, stops and returns error.
    /// On success, continues and returns last success.
    /// - Parameter next: Closure to execute on success, passing in result of last operation.
    /// - Returns: Last success or first failure.
    public func reduce<NewSuccess>(_ next: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value): return next(value)
        case .failure(let error): return .failure(error)
        }
    }
}

/// Returns the same output of `_typeName` but missing the framework name at the beginning
public func __typeName(_ input: Any.Type) -> String {
    return _typeName(input)
        .components(separatedBy: ".")
        .dropFirst()
        .joined(separator: ".")
}

// Internal for testing only
internal func __typeName_framework(_ input: Any.Type) -> String {
    return _typeName(input)
        .components(separatedBy: ".")
        .first ?? "unknownbundle"
}

extension Bundle {
    /// Uses fragile (and slow) method to find Bundle for a non-objective-c type
    /// If you need the bundle for an Objective-C type, please use the correct initalizer
    public static func `for`(type input: Any.Type) -> Bundle? {
        let check1: (Bundle) -> Bool = {
            !($0.bundleIdentifier ?? "com.apple").hasPrefix("com.apple")
        }
        let check2: (Bundle) -> Bool = {
            ($0.bundleIdentifier ?? "")
                .lowercased()
                .hasSuffix(
                    __typeName_framework(input).lowercased()
                )
        }
        let allBundles = Bundle.allBundles + Bundle.allFrameworks
        return allBundles.first(where: { check1($0) && check2($0) })
    }
}
