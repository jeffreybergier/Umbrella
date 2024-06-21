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
    @available(iOS,      deprecated: 17.0, message: "Use `toolbarTitleDisplayMode()` instead")
    @available(macOS,    deprecated: 14.0, message: "Use `toolbarTitleDisplayMode()` instead")
    @available(tvOS,     deprecated: 17.0, message: "Use `toolbarTitleDisplayMode()` instead")
    @available(watchOS,  deprecated: 10.0, message: "Use `toolbarTitleDisplayMode()` instead")
    @available(visionOS, deprecated: 1.0,  message: "Use `toolbarTitleDisplayMode()` instead")
    public var navigationBarTitleDisplayModeInline: some View {
        #if os(macOS) || os(tvOS)
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
        #if os(macOS) || os(watchOS)
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

@MainActor // TODO: Update this to safe when SwiftUI allows
public struct EnvironmentTintColor: @preconcurrency EnvironmentKey {
    public static var defaultValue: Color = {
        #if os(macOS)
        Color(nsColor: NSColor.controlAccentColor)
        #elseif os(watchOS)
        Color(uiColor: WKApplication.shared().globalTintColor)
        #else
        Color(uiColor: UIColor.tintColor)
        #endif
    }()
}

extension EnvironmentValues {
    /// Cross-platform environment value for TintColor
    public var tintColor: Color {
        self[EnvironmentTintColor.self]
    }
}

/// Cross-platform property wrapper for EditMode
@propertyWrapper
public struct JSBEditMode: DynamicProperty {
    
    public init() {}

    #if os(macOS) || os(watchOS)
    public var wrappedValue: Bool { true }
    #else
    @Environment(\.editMode) private var editMode
    public var wrappedValue: Bool {
        get { self.editMode?.wrappedValue.isEditing ?? false }
        nonmutating set {
            self.editMode?.wrappedValue = newValue ? .active : .inactive
        }
    }
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

/// Provides a crossplatform form. On macOS `SwiftUI.Form` does not include a scrollview
/// but on iOS it does. `JSBForm` provides a scrollview on macOS and uses the included one on iOS.
public struct JSBForm<Content: View>: View {
    
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    #if os(macOS)
    public var body: some View {
        ScrollView {
            Form {
                self.content()
            }
        }
    }
    #else
    public var body: some View {
        Form {
            self.content()
        }
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
        #if os(watchOS) || os(tvOS)
        return self.sheet(items: items, content: content, onDismiss: nil)
        #else
        return self.popover(isPresented: items.mapBool()) {
            content(items.wrappedValue)
        }
        #endif
    }
    
    public func sheet<C: Collection & ExpressibleByArrayLiteral, V: View>(
        items: Binding<C>,
        @ViewBuilder content: @escaping (C) -> V,
        onDismiss: (() -> Void)? = nil
    )
    -> some View
    {
        return self.sheet(isPresented: items.mapBool(), onDismiss: onDismiss) {
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
        return self.sheetCover(isPresented: items.mapBool(), onDismiss: onDismiss) {
            content(items.wrappedValue)
        }
    }
    
    /// Removed redundent `isPresented` and `presenting` arguments
    public func alert<A: View, M: View, T, S: StringProtocol>(
        item: Binding<T?>,
        title: S,
        @ViewBuilder actions: (T) -> A,
        @ViewBuilder message: (T) -> M
    ) -> some View
    {
        self.alert(title,
                   isPresented: item.mapBool(),
                   presenting: item.wrappedValue,
                   actions: actions,
                   message: message)
    }
    
    /// Removed redundent `isPresented` and `presenting` arguments
    public func confirmationDialog<A: View, M: View, T, S: StringProtocol>(
        item: Binding<T?>,
        title: S,
        titleVisibility: Visibility = .automatic,
        @ViewBuilder actions: (T) -> A,
        @ViewBuilder message: (T) -> M
    ) -> some View
    {
        self.confirmationDialog(title,
                                isPresented: item.mapBool(),
                                titleVisibility: titleVisibility,
                                presenting: item.wrappedValue,
                                actions: actions,
                                message: message)
    }
    
    /// Removed redundent `isPresented` and `presenting` arguments
    public func confirmationDialog<C: Collection & ExpressibleByArrayLiteral, A: View, M: View, S: StringProtocol>(
        items: Binding<C>,
        title: S,
        titleVisibility: Visibility = .automatic,
        @ViewBuilder actions: (C) -> A,
        @ViewBuilder message: (C) -> M
    ) -> some View
    {
        self.confirmationDialog(title,
                                isPresented: items.mapBool(),
                                titleVisibility: titleVisibility,
                                presenting: items.wrappedValue,
                                actions: actions,
                                message: message)
    }
}

// MARK: State Management Helpers

extension View {
    /// Performs `.onChange` but also performs on initial load. If `async` is set to `YES`,
    /// then the `task` closure is used to perform the initual work. If `async` is set to `NO`,
    /// the initial work is performed in the `onAppear` closure. This will be called any time
    /// the view appears. There is no logic to detect only first appear.
    /// - Parameters:
    ///   - value: Equatable value to watch for changes
    ///   - async: use async to allow the view to appear before performing the initial work
    ///   - perform: closure to perform on load and change
    @available(iOS,      deprecated: 17.0, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @available(macOS,    deprecated: 14.0, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @available(tvOS,     deprecated: 17.0, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @available(watchOS,  deprecated: 10.0, message: "Use `onChange` with a two or zero parameter action closure instead.")
    @available(visionOS, deprecated: 1.0,  message: "Use `onChange` with a two or zero parameter action closure instead.")
    public func onLoadChange<T: Equatable>(of value: T,
                                           async: Bool = false,
                                           perform: @escaping (T) -> Void)
                                           -> some View
    {
        self.onChange(of: value, perform: perform)
            .if(bool: async) {
                $0.task { DispatchQueue.main.async { perform(value) }}
            } else: {
                $0.onAppear { perform(value) }
            }
    }
}
