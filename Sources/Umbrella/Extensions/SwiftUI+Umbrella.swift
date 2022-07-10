//
//  Created by Jeffrey Bergier on 2021/02/17.
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
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension View {
    public var navigationBarTitleDisplayModeInline: some View {
        #if os(macOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.inline)
        #endif
    }
    public var textContentTypeURL: some View {
        #if os(macOS)
        self
        #else
        self.textContentType(.URL)
        #endif
    }
    public func editMode(force: Bool) -> some View {
        #if os(macOS)
        self
        #else
        self.environment(\.editMode, .constant(force ? .active : .inactive))
        #endif
    }
}

/// Cross-platform property wrapper for EditMode
@propertyWrapper
public struct JSBEditMode: DynamicProperty {
    
    public init() {}

    #if !os(macOS)
    @Environment(\.editMode) private var editMode
    public var wrappedValue: Bool {
        get { self.editMode?.wrappedValue.isEditing ?? false }
        nonmutating set {
            self.editMode?.wrappedValue = newValue ? .active : .inactive
        }
    }
    #else
    public var wrappedValue: Bool { true }
    #endif
}

/// Cross-platform property wrapper for SizeClass
@propertyWrapper
public struct JSBSizeClass: DynamicProperty {
    
    public struct Value {
        public var horizontal: SizeClassValue
        public var vertical: SizeClassValue
    }
    
    public enum SizeClassValue: Int, Hashable, Codable {
        case compact, regular
    }
    
    public init() {}

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical
    
    public var wrappedValue: Value {
        .init(
            horizontal: self.horizontal == .compact ? .compact : .regular,
            vertical: self.vertical == .compact ? .compact : .regular
        )
    }
    #elseif os(watchOS)
    public var wrappedValue: Value {
        .init(horizontal: .compact, vertical: .compact)
    }
    #else
    public var wrappedValue: Value {
        .init(horizontal: .regular, vertical: .regular)
    }
    #endif
}

extension View {
    /// Performs onChange but also performs on initial load via `.task` modifier
    public func onLoadChange<T: Equatable>(of change: T, perform: @escaping (T) -> Void) -> some View {
        self.onChange(of: change, perform: perform)
            .task {
                DispatchQueue.main.async { perform(change) }
            }
    }
}

extension Image {
    public init?(data: Data?) {
        guard let data else { return nil }
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        self.init(uiImage: image)
        #else
        guard let image = NSImage(data: data) else { return nil }
        self.init(nsImage: image)
        #endif
    }
    
    public init(jsbImage image: JSBImage) {
        #if canImport(UIKit)
        self.init(uiImage: image)
        #else
        self.init(nsImage: image)
        #endif
    }
    
    public init?(jsbImage image: JSBImage?) {
        guard let image else { return nil }
        self.init(jsbImage: image)
    }
}
