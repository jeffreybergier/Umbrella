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

@MainActor // TODO: Update this to safe when SwiftUI allows
public struct EnvironmentCustomBundle: @preconcurrency EnvironmentKey {
    public static var defaultValue: Bundle = .main
}

extension EnvironmentValues {
    public var bundle: Bundle {
        get { self[EnvironmentCustomBundle.self] }
        set { self[EnvironmentCustomBundle.self] = newValue }
    }
}

extension Bundle {
    public func image(named: String) -> JSBImage? {
        JSBImage.image(named: named, in: self)
    }
    public func localized(key: LocalizationKey,
                          value: String? = nil,
                          table: String? = nil)
                       -> LocalizedString
    {
        self.localizedString(forKey: key, value: value, table: table)
    }
}
