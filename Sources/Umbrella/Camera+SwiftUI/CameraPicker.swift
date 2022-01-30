//
//  Created by Jeffrey Bergier on 2022/01/29.
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

import SwiftUI

#if os(iOS)

import UIKit
import UniformTypeIdentifiers

public struct CameraPicker: View {
    
    public typealias JPEGResult = Result<Data,Error>
    public typealias JPEGSelection = (JPEGResult?) -> Void
    
    @State private var result: JPEGResult?
    @Environment(\.dismiss) private var dismiss
    
    private let selectionClosure: JPEGSelection
    
    public init(selection: @escaping JPEGSelection) {
        self.selectionClosure = selection
    }
    
    public var body: some View {
        let _picker = CameraPickerNative() { result in
            self.result = result
            self.dismiss()
        }
        Group {
            if let picker = _picker {
                picker
                    .background(Color.black)
            } else {
                CameraPickerUnavailable()
            }
        }
        .onDisappear {
            self.selectionClosure(self.result)
        }
    }
}

internal struct CameraPickerNative: UIViewControllerRepresentable {
    
    private let selectionClosure: LibraryPicker.JPEGSelection
    
    internal init?(_ selection: @escaping LibraryPicker.JPEGSelection) {
        if case .incapable = Permission.camera {
            return nil
        }
        self.selectionClosure = selection
    }
    
    internal func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        picker.mediaTypes = [UTType.image.identifier]
        picker.delegate = context.coordinator
        return picker
    }
    
    internal func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> CameraPickerNativeDelegate {
        return CameraPickerNativeDelegate(self.selectionClosure)
    }
}

internal class CameraPickerNativeDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let selectionClosure: LibraryPicker.JPEGSelection
    internal init(_ selection: @escaping LibraryPicker.JPEGSelection) {
        self.selectionClosure = selection
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let _image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        guard let image = _image else {
            // TODO: Create error here
            self.selectionClosure(nil)
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            // TODO: Create error here
            self.selectionClosure(nil)
            return
        }
        self.selectionClosure(.success(data))
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.selectionClosure(nil)
    }
}
#else
public struct CameraPicker: View {
    
    public typealias JPEGResult = Result<Data,Error>
    public typealias JPEGSelection = (JPEGResult?) -> Void
    
    @State private var result: JPEGResult?
    private let selectionClosure: JPEGSelection
    
    public init(selection: @escaping JPEGSelection) {
        self.selectionClosure = selection
    }
    
    public var body: some View {
        CameraPickerUnavailable()
            .onDisappear {
                self.selectionClosure(self.result)
            }
    }
}
#endif

internal struct CameraPickerUnavailable: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder internal var body: some View {
        NavigationView {
            Text("Unsupported")
                .navigationTitle("Camera")
                .toolbar {
                    Button("Done") { self.dismiss() }
                }
        }
    }
}
