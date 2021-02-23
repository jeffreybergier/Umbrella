//
//  Created by Jeffrey Bergier on 2021/02/18.
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

public typealias ErrorQueue = PublishQueue<UserFacingError>
/// Add ErrorQueue to environment so any view can append errors.
/// Use ErrorQueuePresenter at a high level in your SwiftUI structure to present errors.
/// This class is not thread-safe. Only use from Main thread.
public class PublishQueue<T>: ObservableObject {
    
    @Published public var current: IdentBox<T>? { didSet { self.update() } }
    public var queue: Queue<T> = [] { didSet { self.update() } }
    
    public init() { }
    
    private var timer: Timer?
    public func update() {
        guard self.current == nil, self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false)
        { [weak self] timer in
            self?.current = self?.queue.pop().map { IdentBox($0) }
            timer.invalidate()
            self?.timer = nil
        }
    }
    
    deinit {
        self.timer?.invalidate()
    }
}

/// Gets ErrorQueue from Environment and presents errors
public struct ErrorQueuePresenter: ViewModifier {
    @EnvironmentObject private var errorQ: ErrorQueue
    public init() {}
    public func body(content: Content) -> some View {
        content.alert(item: self.$errorQ.current) { box in
            Alert(box.value)
        }
    }
}

/// Clear view that gets ErrorQueue from Environment and presents errors
public struct ErrorQueuePresenterView: View {
    public init() {}
    public var body: some View {
        Color.clear.modifier(ErrorQueuePresenter())
    }
}
