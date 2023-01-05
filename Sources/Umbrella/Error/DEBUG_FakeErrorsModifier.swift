//
//  Created by Jeffrey Bergier on 2022/08/27.
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

#if DEBUG

public struct DEBUG_FakeErrorsModifier: ViewModifier {
    
    public static let defaultErrorProducer: (Int) -> Error = { _ in
        NSError(domain: "UMBRELLA_DEBUG_ERROR",
                code: Int.random(in: 100...100_000_000))
    }
    
    @State private var iteration = 0
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    @Environment(\.errorResponder) private var errorChain
    
    private let errorProducer: (Int) -> Error

    public init(_ errorProducer: @escaping (Int) -> Error = defaultErrorProducer) {
        self.errorProducer = errorProducer
    }
    
    public func body(content: Content) -> some View {
        content
            .onReceive(self.timer) { _ in
                self.errorChain(self.errorProducer(self.iteration))
                self.iteration += 1
            }
    }
}

#endif
