//
//  Created by Jeffrey Bergier on 2022/06/17.
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
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

/// Use as an easy way to configure Actions.
/// Provides convenience methods for creating Buttons and Labels
public struct Action {
    
    public var style: Style
    public var localization: Localization
    
    public init(_ style: Style, _ localization: Localization) {
        self.style = style
        self.localization = localization
    }
    
    /// Configure the text of the Action
    public struct Localization {
        /// Gets set as the visible label and accessibility label
        public var title: LocalizedString
        /// Gets set as the accessibility hint
        public var hint: LocalizedString?
        public var shortcut: KeyboardShortcut?
    }
    /// Configure the style of the Action
    public struct Style {
        public enum Label {
            case automatic, label, icon, title
        }
        public enum Image {
            case system(String)
            case custom(SwiftUI.Image)
        }
        public var image: Image
        public var style: Label
        public var button: ButtonRole?
        
        public init(style: Label = .automatic,
                    image: Image,
                    button: ButtonRole? = nil)
        {
            self.style = style
            self.image = image
            self.button = button
        }
    }
}

// MARK: Buttons
extension Action {
    public func button<C>(_ isEnabled: EnableItems<C>) -> some View {
        let action: () -> Void = {
            isEnabled.action(isEnabled.items)
        }
        return Button(action: action, label: self.raw_label)
            .disabled(isEnabled.items.isEmpty)
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
    }
    
    public func button<T>(_ isEnabled: EnableItem<T>) -> some View {
        let action: () -> Void = {
            guard let item = isEnabled.item else { return }
            isEnabled.action(item)
        }
        return Button(action: action, label: self.raw_label)
            .disabled(isEnabled.item == nil)
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
    }
    
    public func button(_ isEnabled: EnableBool) -> some View {
        Button(action: isEnabled.action, label: self.raw_label)
            .disabled(!isEnabled.isEnabled)
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
    }
    
    public struct EnableBool {
        public var isEnabled: Bool
        public var action: () -> Void
        public init(isEnabled: Bool = true, action: @escaping () -> Void) {
            self.isEnabled = isEnabled
            self.action = action
        }
    }
    
    public struct EnableItem<T> {
        public var item: T?
        public var action: (T) -> Void
        public init(item: T?, action: @escaping (T) -> Void) {
            self.item = item
            self.action = action
        }
    }
    
    public struct EnableItems<C: Collection> {
        public var items: C
        public var action: (C) -> Void
        public init(items: C, action: @escaping (C) -> Void) {
            self.items = items
            self.action = action
        }
    }
}

// MARK: Labels
extension Action {
    public var label: some View {
        return self.raw_label()
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
    }
    
    private func raw_label() -> some View {
        return Label {
            Text(self.localization.title)
        } icon: {
            switch self.style.image {
            case .system(let image):
                SwiftUI.Image(systemName: image)
            case .custom(let image):
                image
            }
        }
        .modifier(LabelStyler(self.style.style))
    }
}

fileprivate struct LabelStyler: ViewModifier {
    private let style: Action.Style.Label
    init(_ style: Action.Style.Label) {
        self.style = style
    }
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.labelStyle(.automatic)
        case .label:
            content.labelStyle(.titleAndIcon)
        case .icon:
            content.labelStyle(.iconOnly)
        case .title:
            content.labelStyle(.titleOnly)
        }
    }
}
