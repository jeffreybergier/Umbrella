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
import PhotosUI

public struct LibraryPicker: View {
        
    private let selectionClosure: CameraSelection
    
    public init(selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    
    public var body: some View {
        if let picker = LibraryPickerNative(self.selectionClosure) {
            picker
        } else {
            LibraryPickerUnavailable(self.selectionClosure)
        }
    }
}

fileprivate struct LibraryPickerNative: UIViewControllerRepresentable {
    
    private let selectionClosure: CameraSelection
    
    internal init?(_ selection: @escaping CameraSelection) {
        if Permission.libraryImplicit == false {
            return nil
        }
        self.selectionClosure = selection
    }
    internal func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    internal func makeCoordinator() -> LibraryPickerNativeDelegate {
        return LibraryPickerNativeDelegate(self.selectionClosure)
    }
    internal func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
}

internal class LibraryPickerNativeDelegate: NSObject, PHPickerViewControllerDelegate {
    private let selectionClosure: CameraSelection
    internal init(_ selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let item = results.first?.itemProvider else {
            // User cancelled
            self.selectionClosure(nil)
            return
        }
        var result: CameraResult?
        let wait1 = DispatchSemaphore(value: 0)
        item.loadDataRepresentation(forTypeIdentifier: UTType.jpeg.identifier) { _data, error in
            if let error = error {
                NSLog("\(error)")
                result = .failure(.format)
            } else if let data = _data {
                result = .success(data)
            } else {
                fatalError("Error and Data were both NIL")
            }
            wait1.signal()
        }
        wait1.wait()
        if case .failure = result {
            let wait2 = DispatchSemaphore(value: 0)
            item.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { _data, error in
                if let error = error {
                    NSLog("\(error)")
                    result = .failure(.format)
                } else if let data = _data {
                    result = .success(data)
                } else {
                    fatalError("Error and Data were both NIL")
                }
                wait2.signal()
            }
            wait2.wait()
        }
        self.selectionClosure(result)
    }
}
#else
public struct LibraryPicker: View {
    
    private let selectionClosure: CameraSelection
    
    public init(selection: @escaping CameraSelection) {
        self.selectionClosure = selection
    }
    public var body: some View {
        LibraryPickerUnavailable(self.selectionClosure)
    }
}
#endif

internal struct LibraryPickerUnavailable: View {
    @Environment(\.dismiss) private var dismiss
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
