// swift-tools-version:6.0.0
//
//  Created by Jeffrey Bergier on 2021/02/23.
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

import PackageDescription

let package = Package(
    name: "Umbrella",
    platforms: [
        .watchOS(.v8),
        .macOS(.init(stringLiteral: "12.3")),
        .macCatalyst(.init(stringLiteral: "15.4")),
        .tvOS(.init(stringLiteral: "15.4")),
        .iOS(.init(stringLiteral: "15.4")),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Umbrella",
            targets: ["Umbrella"]
        ),
    ],
    targets: [
        .target(
            name: "Umbrella",
            dependencies: [],
            path: "Sources/Umbrella"
        ),
    ],
    swiftLanguageModes: [.version("6")]
)
