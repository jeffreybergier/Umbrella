//
//  Created by Jeffrey Bergier on 2022/02/20.
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

// Useful regex for finding strings
// (["'])(?:(?=(\\?))\2.)*?\1

// TODO: Change LocalizationKey into a real type?
public typealias LocalizedString = String
public typealias LocalizationKey = String

/// Use to localize strings, find images, or other assets from Bundles placed into the environment.
/// Implement class that conforms to `EnvironmentBundleProtocol` and then place it in the environment.
@propertyWrapper public struct EnvironmentBundle<B: EnvironmentBundleProtocol>: DynamicProperty {
    @EnvironmentObject private var bundle: B
    public init() {}
    public var wrappedValue: B {
        return self.bundle
    }
}

public protocol EnvironmentBundleProtocol: ObservableObject {
    var bundle: Bundle { get }
}

extension EnvironmentBundleProtocol {
    public func image(named: String) -> Image? {
        return Image(named, bundle: self.bundle)
    }
    public func localized(key: LocalizationKey) -> LocalizedString {
        return self.bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    public func url(name: String, extension: String) -> URL? {
        return self.bundle.url(forResource: name, withExtension: `extension`)
    }
}
