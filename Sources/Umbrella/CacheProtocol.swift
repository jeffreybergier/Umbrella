//
//  Created by Jeffrey Bergier on 2021/03/06.
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
import Foundation
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

public protocol CacheProtocol: class {
    associatedtype Key: Hashable
    associatedtype Value
    var cache: [Key: Value] { get set }
}

extension CacheProtocol {
    public subscript(key: Key, cacheMiss: () -> Value) -> Value {
        if let value = self.cache[key] {
            return value
        }
        let miss = cacheMiss()
        self.cache[key] = miss
        return miss
    }
    public subscript(key: Key) -> Value? {
        get { return self.cache[key] }
        set { self.cache[key] = newValue }
    }
    public func clear() {
        self.cache = [:]
    }
}

/// Publishes changes to T through ObjectWillChangePublisher
public class PublishedCache<K: Hashable, V>: ObservableObject, CacheProtocol {
    @Published public var cache: [K: V] = [:]
    private var tokens: Set<AnyCancellable> = []
    public init(initialCache: [K: V] = [:], clearAutomatically: Bool = false) {
        self.cache = initialCache
        guard clearAutomatically else { return }
        CacheProtocolNotification.activateShouldClear()
        NotificationCenter
            .default
            .publisher(for: CacheProtocolNotification.shouldClear)
            .sink { [weak self] _ in
                self?.clear()
            }
            .store(in: &self.tokens)
    }
}

/// Never publishes changes through ObjectWillChangePublisher
public class Cache<K: Hashable, V>: ObservableObject, CacheProtocol {
    public var cache: [K: V] = [:]
    private var tokens: Set<AnyCancellable> = []
    public init(initialCache: [K: V] = [:], clearAutomatically: Bool = false) {
        self.cache = initialCache
        guard clearAutomatically else { return }
        CacheProtocolNotification.activateShouldClear()
        NotificationCenter
            .default
            .publisher(for: CacheProtocolNotification.shouldClear)
            .sink { [weak self] _ in
                self?.clear()
            }
            .store(in: &self.tokens)
    }
}

public enum CacheProtocolNotification {
    
    public static let shouldClear = Notification.Name(rawValue: "JSBUmbrellaCacheProtocolShouldClearNotification")
    
    /// Notification fired on:
    /// `NSApplication.didResignActiveNotification`,
    /// `UIApplication.didEnterBackgroundNotification`,
    /// `UIApplication.didReceiveMemoryWarningNotification`
    public static func activateShouldClear() {
        guard self.notificationTokens.isEmpty else { return }
        let nc = NotificationCenter.default
        let clearCache: (NotificationCenter.Publisher.Output) -> Void = { _ in
            nc.post(name: self.shouldClear, object: nil)
        }
        #if canImport(AppKit)
        nc.publisher(for: NSApplication.didResignActiveNotification)
            .sink(receiveValue: clearCache)
            .store(in: &self.notificationTokens)
        #else
        nc.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink(receiveValue: clearCache)
            .store(in: &self.notificationTokens)
        nc.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink(receiveValue: clearCache)
            .store(in: &self.notificationTokens)
        #endif
    }
    
    public static func deactivateShouldClear() {
        self.notificationTokens.forEach { $0.cancel() }
        self.notificationTokens = []
    }
    
    private static var notificationTokens: Set<AnyCancellable> = []
}
