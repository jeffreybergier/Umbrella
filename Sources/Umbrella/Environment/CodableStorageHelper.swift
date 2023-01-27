//
//  Created by Jeffrey Bergier on 2023/01/27.
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
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

internal class CodableStorageHelper<Value: Codable>: ObservableObject {
    
    // Not sure if storing these helps performance
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    // Not sure if cache actually helps performance
    private var cache: [String: Value] = [:]
    private let onError: OnError?
    
    internal init(_ onError: OnError?) {
        self.onError = onError
    }
    
    internal func readCacheOrDecode(_ rawValue: String?) -> Value? {
        do {
            guard let rawValue else { return nil }
            if let cache = self.cache[rawValue] { return cache }
            guard let data = Data(base64Encoded: rawValue) else { return nil }
            return try self.decoder.decode(Value.self, from: data)
        } catch {
            self.onError?(error)
            guard self.onError == nil else { return nil }
            NSLog(String(describing: error))
            assertionFailure(String(describing: error))
            return nil
        }
    }
    
    internal func encodeAndCache(_ newValue: Value) -> String? {
        do {
            let data = try self.encoder.encode(newValue)
            let rawValue = data.base64EncodedString()
            self.cache[rawValue] = newValue
            return rawValue
        } catch {
            self.onError?(error)
            guard self.onError == nil else { return nil }
            NSLog(String(describing: error))
            assertionFailure(String(describing: error))
            return nil
        }
    }
}
