// swift-tools-version:5.3
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
        .macOS(.v10_15), .iOS(.v13)
    ],
    products: [
        .library(
            name: "Umbrella",
            targets: ["Umbrella"]
        ),
        .library(
            name: "TestUmbrella",
            targets: ["TestUmbrella"]
        ),
    ],
    dependencies: [
        .package(
            name: "ServerlessLogger",
            url: "https://github.com/jeffreybergier/JSBServerlessLogger.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "Umbrella",
            dependencies: ["ServerlessLogger"],
            path: "Sources/Umbrella"
        ),
        .target(
            name: "TestUmbrella",
            dependencies: [],
            path: "Sources/TestUmbrella"
        ),
        .testTarget(
            name: "UmbrellaTests",
            dependencies: ["Umbrella", "TestUmbrella"],
            path: "Tests/UmbrellaTests"
        ),
    ]
)
