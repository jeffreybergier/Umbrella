//
//  Created by Jeffrey Bergier on 2021/01/28.
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

import Combine
import CoreData
import Collections

/// Represents the progress of something that is long running and can produce
/// errors upon startup and errors while running. I use this to reflect the status
/// of NSPersistentCloudKitContainer sync. But its generic enough to be used for
/// many types of long-running / background processes.
/// Use `AnyContinousProgress` to get around AssociatedType compile errors.
public protocol ContinousProgress: ObservableObject {
    /// Fixed error that only occurs on startup and doesn't change
    /// for the lifetime of the process.
    var initializeError: UserFacingError? { get }
    var progress: Progress { get }
    /// When an error occurs, append it to the Queue.
    var errors: Deque<UFError> { get set }
}

public class AnyContinousProgress: ContinousProgress {
    
    public let objectWillChange: ObservableObjectPublisher
    public var initializeError: UserFacingError? { _initializeError() }
    public var progress: Progress { _progress() }
    public var errors: Deque<UFError> {
        get { _errors_get() }
        set { _errors_set(newValue) }
    }
    
    private var _initializeError: () -> UserFacingError?
    private var _progress: () -> Progress
    private var _errors_get: () -> Deque<UFError>
    private var _errors_set: (Deque<UFError>) -> Void
    
    public init<T: ContinousProgress>(_ progress: T) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        self.objectWillChange = progress.objectWillChange
        _initializeError      = { progress.initializeError }
        _progress             = { progress.progress }
        _errors_get           = { progress.errors }
        _errors_set           = { progress.errors = $0 }
    }
}

/// Use when you have no progress to report
public class NoContinousProgress: ContinousProgress {
    public let initializeError: UserFacingError? = nil
    public let progress: Progress = .init()
    public var errors: Deque<UFError> = .init()
    public init() {}
}
