//
//  Created by Jeffrey Bergier on 2022/01/29.
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

#if os(iOS)

import UIKit
import UniformTypeIdentifiers

public struct CameraPicker: View {
    
    private let selectionClosure: CameraSelection
    
    public init(selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    
    public var body: some View {
        if let picker = CameraPickerNative(self.selectionClosure) {
            picker
                .background(Color.black)
        } else {
            CameraPickerUnavailable(self.selectionClosure)
        }
    }
}

internal struct CameraPickerNative: UIViewControllerRepresentable {
    
    private let selectionClosure: CameraSelection
    
    internal init?(_ selection: @escaping CameraSelection) {
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
    private let selectionClosure: CameraSelection
    internal init(_ selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let _image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        guard let image = _image else {
            self.selectionClosure(.failure(.capture))
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            self.selectionClosure(.failure(.compression))
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
    
    private let selectionClosure: CameraSelection
    
    public init(selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    
    public var body: some View {
        CameraPickerUnavailable(self.selectionClosure)
    }
}
#endif

internal struct CameraPickerUnavailable: View {
    private let selectionClosure: CameraSelection
    internal init(_ selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    @ViewBuilder internal var body: some View {
        NavigationView {
            Text("Unsupported")
                .navigationTitle("Camera")
                .toolbar {
                    Button("Done") { self.selectionClosure(nil) }
                }
        }
    }
}
