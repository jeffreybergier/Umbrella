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

// MARK: Crossplatform support

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
    public func sheetCover<T: Identifiable>(item: Binding<T?>,
                                            onDismiss: (() -> Void)? = nil,
                                            @ViewBuilder content: @escaping (T) -> some View)
                                            -> some View
    {
        #if os(macOS)
        self.sheet(item: item, onDismiss: onDismiss, content: content)
        #else
        self.fullScreenCover(item: item, onDismiss: onDismiss, content: content)
        #endif
    }
    public func sheetCover(isPresented: Binding<Bool>,
                           onDismiss: (() -> Void)? = nil,
                           @ViewBuilder content: @escaping () -> some View)
                           -> some View
    {
        #if os(macOS)
        self.sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
        #else
        self.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: content)
        #endif
    }
}

/// Cross-platform environment value for TintColor
public struct EnvironmentTintColor: EnvironmentKey {
    public static var defaultValue: Color = {
        #if os(macOS)
        Color(nsColor: NSColor.controlAccentColor)
        #else
        Color(uiColor: UIColor.tintColor)
        #endif
    }()
}

extension EnvironmentValues {
    public var tintColor: Color {
        self[EnvironmentTintColor.self]
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
    
    public typealias Tuple = (horizontal: Value, vertical: Value)
    
    public enum Value: Int, Hashable, Codable {
        case tiny, compact, regular
    }
    
    public init() {}

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical
    
    public var wrappedValue: Tuple {
        (horizontal: self.horizontal == .compact ? .compact : .regular,
         vertical: self.vertical == .compact ? .compact : .regular)
    }
    #elseif os(watchOS)
    public var wrappedValue: Tuple {
        (horizontal: .tiny, vertical: .tiny)
    }
    #else
    public var wrappedValue: Tuple {
        (horizontal: .regular, vertical: .regular)
    }
    #endif
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

// MARK: Presentation Helpers

extension View {
    public func popover<C: Collection & ExpressibleByArrayLiteral, V: View>(
        items: Binding<C>,
        @ViewBuilder content: @escaping (C) -> V
    ) -> some View
    {
        return self.popover(isPresented: items.isPresented) {
            content(items.wrappedValue)
        }
    }
    
    public func sheet<C: Collection & ExpressibleByArrayLiteral, V: View>(
        items: Binding<C>,
        @ViewBuilder content: @escaping (C) -> V,
        onDismiss: (() -> Void)? = nil
    )
    -> some View
    {
        return self.sheet(isPresented: items.isPresented, onDismiss: onDismiss) {
            content(items.wrappedValue)
        }
    }
    
    public func sheetCover<C: Collection & ExpressibleByArrayLiteral, V: View>(
        items: Binding<C>,
        @ViewBuilder content: @escaping (C) -> V,
        onDismiss: (() -> Void)? = nil
    )
    -> some View
    {
        return self.sheetCover(isPresented: items.isPresented, onDismiss: onDismiss) {
            content(items.wrappedValue)
        }
    }
}

// MARK: State Management Helpers

extension View {
    /// Performs `.onChange` but also performs on initial load via `.onAppear` modifier
    public func onLoadChange<T: Equatable>(of change: T, perform: @escaping (T) -> Void) -> some View {
        self.onChange(of: change, perform: perform)
            .onAppear { perform(change) }
    }
}
