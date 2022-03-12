//
//  Created by Jeffrey Bergier on 2022/01/30.
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
