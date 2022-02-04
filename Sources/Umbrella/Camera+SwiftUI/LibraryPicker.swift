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
import PhotosUI

public struct LibraryPicker: View {
    
    public typealias JPEGResult = Result<Data,Error>
    public typealias JPEGSelection = (JPEGResult?) -> Void
        
    private let selectionClosure: JPEGSelection
    
    public init(selection: @escaping JPEGSelection) {
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
    
    private let selectionClosure: LibraryPicker.JPEGSelection
    
    internal init?(_ selection: @escaping LibraryPicker.JPEGSelection) {
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
    private let selectionClosure: LibraryPicker.JPEGSelection
    internal init(_ selection: @escaping LibraryPicker.JPEGSelection) {
        self.selectionClosure = selection
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let item = results.first?.itemProvider else {
            // User cancelled
            self.selectionClosure(nil)
            return
        }
        var result: LibraryPicker.JPEGResult?
        let wait1 = DispatchSemaphore(value: 0)
        item.loadDataRepresentation(forTypeIdentifier: UTType.jpeg.identifier) { _data, error in
            if let error = error {
                error.log()
                result = .failure(error)
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
                    error.log()
                    result = .failure(error)
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
    
    public typealias JPEGResult = Result<Data,Error>
    public typealias JPEGSelection = (JPEGResult?) -> Void
    
    @State private var result: JPEGResult?    
    private let selectionClosure: JPEGSelection
    
    public init(selection: @escaping JPEGSelection) {
        self.selectionClosure = selection
    }
    public var body: some View {
        LibraryPickerUnavailable()
    }
}
#endif

internal struct LibraryPickerUnavailable: View {
    @Environment(\.dismiss) private var dismiss
    private let selectionClosure: LibraryPicker.JPEGSelection
    internal init(_ selection: @escaping LibraryPicker.JPEGSelection) {
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
