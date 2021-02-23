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
extension Binding where Value == EditMode {
    public var isEditing: Bool {
        switch self.wrappedValue {
        case .transient, .active:
            return true
        case .inactive:
            fallthrough
        @unknown default:
            return false
        }
    }
}

extension UserInterfaceSizeClass {
    public var isCompact: Bool {
        switch self {
        case .regular:
            return false
        case .compact:
            fallthrough
        @unknown default:
            return true
        }
    }
}
#endif

public enum Force {
    public struct EditMode: ViewModifier {
        #if canImport(UIKit)
        @State var editMode: SwiftUI.EditMode = .active
        #endif
        public init() {}
        public func body(content: Content) -> some View {
            #if canImport(UIKit)
            return content.environment((\.editMode), self.$editMode)
            #else
            return content
            #endif
        }
    }
    public struct PlainListStyle: ViewModifier {
        public init() {}
        public func body(content: Content) -> some View {
            #if canImport(UIKit)
            return content.listStyle(SwiftUI.PlainListStyle())
            #else
            return content
            #endif
        }
    }
    
    public struct SidebarStyle: ViewModifier {
        public init() {}
        #if os(macOS)
        public func body(content: Content) -> some View {
            content.listStyle(SidebarListStyle())
        }
        #else
        @ViewBuilder public func body(content: Content) -> some View {
            if UIDevice.current.userInterfaceIdiom == .pad {
                content.listStyle(SidebarListStyle())
            } else {
                content.listStyle(InsetGroupedListStyle())
            }
        }
        #endif
    }
}
