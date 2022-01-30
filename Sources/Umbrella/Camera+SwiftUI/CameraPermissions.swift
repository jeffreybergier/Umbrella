//
//  Created by Jeffrey Bergier on 2022/01/30.
//  Copyright © 2021 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

#if os(iOS)
import UIKit
import Photos
#endif
import AVFoundation

public enum Permission {
    case allowed
    case restricted
    case denied
    case incapable
}

extension Permission {
    public static var camera: Permission {
        #if os(iOS)
        if
            UIImagePickerController.isCameraDeviceAvailable(.rear) == false,
            UIImagePickerController.isCameraDeviceAvailable(.front) == false
        {
            return .incapable
        }
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .allowed
        case .notDetermined:
            fallthrough
        @unknown default:
            return .allowed
        }
        #else
        return .incapable
        #endif
    }
    /// Implicit ability without needing user permission
    /// Available with `PHPickerViewController`
    public static var libraryImplicit: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
    /// Explicit Permission
    public static var libraryReadWrite: Permission {
        #if os(iOS)
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .allowed
        case .notDetermined:
            fallthrough
        case .limited:
            fallthrough
        @unknown default:
            return .allowed
        }
        #else
        return .incapable
        #endif
    }
}
