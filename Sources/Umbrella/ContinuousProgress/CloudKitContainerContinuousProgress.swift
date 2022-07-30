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

import CoreData
import Combine
import CloudKit
import Collections

// Highly inspired by
// https://github.com/ggruen/CloudKitSyncMonitor/blob/main/Sources/CloudKitSyncMonitor/SyncMonitor.swift

/// Shows continuous progress of CloudKit syncing via NSPersistentCloudKitContainer.
/// Note, this class is not tested because it relies on NSNotificationCenter and other singletons.
@available(iOS 14.0, OSX 11.0, *)
public class CloudKitContainerContinuousProgress: ContinousProgress {
    
    public enum Error: CustomNSError {
        case accountStatusCritical(NSError)
        case accountStatus(CKAccountStatus)
        case sync(NSError)
        
        public var errorCode: Int {
            switch self {
            case .accountStatusCritical:
                return 1001
            case .accountStatus:
                return 1002
            case .sync:
                return 1003
            }
        }
        public var title: String { "iCloud" }
        public var message: String {
            switch self {
            case .accountStatus:
                return "Phrase.ErroriCloudAccount"
            case .accountStatusCritical(let error), .sync(let error):
                return .init(error.localizedDescription)
            }
        }
    }
    
    public var initializeError: Swift.Error?
    public let progress: Progress
    public var errors: Deque<Swift.Error> = .init()
    
    private let syncName = NSPersistentCloudKitContainer.eventChangedNotification
    private let accountName = Notification.Name.CKAccountChanged
    private var io: Set<UUID> = []
    
    /// If container is not NSPersistentCloudKitContainer this class never shows any progress.
    public init(_ container: NSPersistentContainer) {
        self.progress = .init(totalUnitCount: 0)
        self.progress.completedUnitCount = 0
        guard container is NSPersistentCloudKitContainer else {
            NSLog("CloudKitContainerContinuousProgress can only be show progress of sync with NSPersistentCloudKitContainer")
            return
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.observeSync(_:)),
                       name: self.syncName,
                       object: container)
        nc.addObserver(self,
                       selector: #selector(self.observeAccount),
                       name: self.accountName,
                       object: nil)
        self.observeAccount()
    }
    
    @objc private func observeAccount() {
        guard ISTESTING == false else { return }
        CKContainer.default().accountStatus() { account, error in
            DispatchQueue.main.async {
                self.objectWillChange.send()
                if let error = error {
                    NSLog(String(describing: error))
                    self.initializeError = Error.accountStatusCritical(error as NSError)
                    return
                }
                switch account {
                case .available:
                    self.initializeError = nil
                case .couldNotDetermine, .restricted, .noAccount, .temporarilyUnavailable:
                    fallthrough
                @unknown default:
                    self.initializeError = Error.accountStatus(account)
                }
            }
        }
    }
    
    @objc private func observeSync(_ aNotification: Notification) {
        let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
        guard let event = aNotification.userInfo?[key]
                as? NSPersistentCloudKitContainer.Event else { return }
        DispatchQueue.main.async {
            self.objectWillChange.send()
            if let error = event.error {
                NSLog(String(describing: error))
                self.errors.append(Error.sync(error as NSError))
            }
            if self.io.contains(event.identifier) {
                self.io.remove(event.identifier)
                self.progress.completedUnitCount += 1
            } else {
                self.io.insert(event.identifier)
                self.progress.totalUnitCount += 1
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: self.syncName, object: nil)
        NotificationCenter.default.removeObserver(self, name: self.accountName, object: nil)
    }
}
