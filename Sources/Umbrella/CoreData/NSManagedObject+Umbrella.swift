//
//  Created by Jeffrey Bergier on 2022/11/18.
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

extension NSManagedObject {
    /// From Apple Docs:
    /// true if Core Data will ask the persistent store to delete the object during the next save operation, otherwise false.
    /// It may return false at other times, particularly after the object has been deleted.
    /// The immediacy with which it will stop returning true depends on where the object is in the process of being deleted.
    /// If the receiver is a fault, accessing this property does not cause it to fire.
    // public var isDeleted: Bool
    
    /// More complete check for `isDeleted` as built-in one is not very useful
    public var isDeleted_noReally: Bool {
        if self.isDeleted {
            return true
        }
        if self.managedObjectContext == nil {
            return true
        }
        return false
    }
    
    /// Most complete check for `isDeleted` as built-in one is not very useful.
    /// Slower than `isDeleted_noReally` IF it needs to query the managed object context.
    public var isDeleted_noReally_noLikeSeriously: Bool {
        if self.isDeleted_noReally {
            return true
        }
        // From SO: https://stackoverflow.com/a/7896369
        let cloneObject = try? self.managedObjectContext?
                                   .existingObject(with: self.objectID)
        return cloneObject == nil
    }
}
