//
//  Created by Jeffrey Bergier on 2024/04/29.
//
//  MIT License
//
//  Copyright (c) 2024 Jeffrey Bergier
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

extension NotificationCenter {
    
    public func observable(_ name: Notification.Name,
                           object: AnyObject? = nil)
                           -> Observable
    {
        return .init(name, object: object, center: self)
    }
    
    public class Observable: ObservableObject {
        
        @Published public private(set) var randomNumber = -1
        @Published public private(set) var lastNotification: Notification?
        
        public let notificationName: Notification.Name
        internal private(set) weak var object: AnyObject?
        internal private(set) weak var center: NotificationCenter?
        
        public init(_ name: Notification.Name,
                    object: AnyObject? = nil,
                    center: NotificationCenter = .default)
        {
            self.notificationName = name
            self.object = object
            self.center = center
            self.enable()
        }
        
        public func enable() {
            self.randomNumber = Int.random(in: 1...100_000_000)
            self.lastNotification = nil
            let center = self.center ?? .default
            center.addObserver(
                self,
                selector: #selector(handleNotification(_:)),
                name: self.notificationName,
                object: self.object
            )
        }
        
        public func disable() {
            self.randomNumber = Int.random(in: 1...100_000_000)
            self.lastNotification = nil
            let center = self.center ?? .default
            center.removeObserver(
                self,
                name: self.notificationName,
                object: self.object
            )
        }
        
        @objc private func handleNotification(_ notification: Notification) {
            NSLog(notification.name.rawValue)
            self.randomNumber = Int.random(in: 1...100_000_000)
            self.lastNotification = notification
        }
    }
}
