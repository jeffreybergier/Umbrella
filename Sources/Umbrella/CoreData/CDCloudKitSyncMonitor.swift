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

// Highly inspired by
// https://github.com/ggruen/CloudKitSyncMonitor/blob/main/Sources/CloudKitSyncMonitor/SyncMonitor.swift

/// Shows continuous progress of CloudKit syncing via NSPersistentCloudKitContainer.
/// Note, this class is not tested because it relies on NSNotificationCenter and other singletons.
@MainActor
@available(iOS 14.0, OSX 11.0, *)
public class CDCloudKitSyncMonitor: ObservableObject {
    
    public var progressBox: ObserveBox<ContinousProgress> = .init(.init())
    
    private let syncName = NSPersistentCloudKitContainer.eventChangedNotification
    private let accountName = Notification.Name.CKAccountChanged
    private var io: Set<UUID> = []
    
    /// If container is not NSPersistentCloudKitContainer this class never shows any progress.
    public init(_ container: NSPersistentContainer) {
        guard container is NSPersistentCloudKitContainer else {
            NSLog("CloudKitContainerContinuousProgress can only be show progress of sync with NSPersistentCloudKitContainer")
            return
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(self.NC_observeSyncEvent(_:)),
                       name: self.syncName,
                       object: container)
        nc.addObserver(self,
                       selector: #selector(self.NC_observeAccount),
                       name: self.accountName,
                       object: nil)
        Task {
            await self.observeAccount()
        }
    }
    
    @objc nonisolated private func NC_observeAccount() {
        Task {
            await self.observeAccount()
        }
    }
    
    private func observeAccount() async {
        guard ISTESTING == false else { return }
        do {
            let account = try await CKContainer.default().accountStatus()
            switch account {
            case .available:
                return
            case .couldNotDetermine, .restricted, .noAccount, .temporarilyUnavailable:
                fallthrough
            @unknown default:
                self.objectWillChange.send()
                self.progressBox.value.errors.append(CPAccountStatus(account))
            }
        } catch {
            NSLog(String(describing: error))
            self.objectWillChange.send()
            self.progressBox.value.errors.append(error)
        }
    }
    
    @objc nonisolated private func NC_observeSyncEvent(_ aNotification: Notification) {
        let key = NSPersistentCloudKitContainer.eventNotificationUserInfoKey
        guard let event = aNotification.userInfo?[key] as? NSPersistentCloudKitContainer.Event else { return }
        let identifier = event.identifier
        let error = event.error
        Task {
            await self.observeSyncEvent(identifier: identifier, error: error)
        }
    }
    
    private func observeSyncEvent(identifier: UUID, error: Error?) {
        self.objectWillChange.send()
        if let error = error {
            NSLog(String(describing: error))
            self.progressBox.value.errors.append(error)
        }
        if self.io.contains(identifier) {
            self.io.remove(identifier)
            self.progressBox.value.progress.completedUnitCount += 1
        } else {
            self.io.insert(identifier)
            self.progressBox.value.progress.totalUnitCount += 1
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: self.syncName, object: nil)
        NotificationCenter.default.removeObserver(self, name: self.accountName, object: nil)
    }
}

public enum CPAccountStatus: Int, CustomNSError {
    case couldNotDetermine = 0
    case restricted = 2
    case noAccount = 3
    case temporarilyUnavailable = 4
    
    public var errorCode: Int { self.rawValue }
    public static var errorDomain: String {
        "com.saturdayapps.Umbrella.ContinuousProgressError"
    }
}

extension CPAccountStatus {
    public init(_ system: CKAccountStatus) {
        let attempt = CPAccountStatus(rawValue: system.rawValue)
        self = attempt ?? .couldNotDetermine
    }
    public var systemValue: CKAccountStatus {
        return CKAccountStatus(rawValue: self.rawValue) ?? .couldNotDetermine
    }
}
