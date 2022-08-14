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

// MARK: Action

/// Use as an easy way to configure Actions.
/// Provides convenience methods for creating Buttons and Labels.
/// To construct create `ActionLocalization` then construct `ActionStyleImp`.
/// On either instance, call `actionWith:` method to create `Action`.
/// Use `some ActionStyle` to hide implementation details from your UI code.
/// Can be constructed manually with `ActionImp` or by implementing custom type.
public protocol Action {
    associatedtype Style: ActionStyle
    
    var localization: ActionLocalization { get }
    var style: Style { get }
}

public struct ActionImp<S: ActionStyle>: Action {
    
    public var style: S
    public var localization: ActionLocalization
    
    public init(style: S, localization: ActionLocalization) {
        self.style = style
        self.localization = localization
    }
}

// MARK: Action Style

/// Configure the style of your Button or Label
public protocol ActionStyle {
    associatedtype LS: LabelStyle
    associatedtype M: ViewModifier
    
    var label: LS { get }
    var button: ButtonRole? { get }
    var modifier: M { get }
}

extension ActionStyle {
    public func action(text localization: ActionLocalization) -> some Action {
        return ActionImp(style: self, localization: localization)
    }
}

public struct ActionStyleImp<LS: LabelStyle, M: ViewModifier>: ActionStyle {
    
    public var button: ButtonRole?
    public var label: LS
    public var modifier: M
    
    public init(button: ButtonRole? = nil, label: LS, modifier: M) {
        self.button = button
        self.label = label
        self.modifier = modifier
    }
    
    public init(button: ButtonRole? = nil) where LS == DefaultLabelStyle, M == EmptyModifier {
        self.button = button
        self.label = DefaultLabelStyle()
        self.modifier = EmptyModifier()
    }
    
    public init(button: ButtonRole? = nil, modifier: M) where LS == DefaultLabelStyle {
        self.button = button
        self.label = DefaultLabelStyle()
        self.modifier = modifier
    }
    
    public init(button: ButtonRole? = nil, label: LS) where M == EmptyModifier {
        self.button = button
        self.label = label
        self.modifier = EmptyModifier()
    }
}

// MARK: Action Localization

/// Configure the text of the Button or Label
public struct ActionLocalization {
    /// Image for the label
    public var image: ActionLabelImage?
    /// Visible label and accessibility label
    public var title: LocalizedString
    /// Accessibility hint
    public var hint: LocalizedString?
    public var shortcut: KeyboardShortcut?
    
    public init(title: LocalizedString,
                hint: LocalizedString? = nil,
                image: ActionLabelImage? = nil,
                shortcut: KeyboardShortcut? = nil)
    {
        self.image = image
        self.title = title
        self.hint = hint
        self.shortcut = shortcut
    }
    
    public func action<S: ActionStyle>(style: S) -> some Action {
        return ActionImp(style: style, localization: self)
    }
}

public enum ActionLabelImage {
    case system(String)
    case custom(Image)
    public var image: Image {
        switch self {
        case .custom(let image): return image
        case .system(let name): return Image(systemName: name)
        }
    }
}

// MARK: Labels

extension Action {
    public var label: some View {
        return self.raw_label()
            .modifier(self.style.modifier)
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
    }
    
    @ViewBuilder private func raw_label() -> some View {
        if let image = self.localization.image {
            Label {
                Text(self.localization.title)
            } icon: {
                image.image
            }
            .labelStyle(self.style.label)
        } else {
            Text(self.localization.title)
        }
    }
}

// MARK: Buttons

extension Action {
    
    public func button(_ isEnabled: ActionEnableBool) -> some View {
        return self.raw_button(action: isEnabled.action)
                   .disabled(!isEnabled.isEnabled)
    }

    
    public func button<T>(_ isEnabled: ActionEnableItem<T>) -> some View {
        let action: () -> Void = {
            guard let item = isEnabled.item else { return }
            isEnabled.action(item)
        }
        return self.raw_button(action: action)
                   .disabled(isEnabled.item == nil)
    }
    
    public func button<C>(_ isEnabled: ActionEnableItems<C>) -> some View {
        let action: () -> Void = {
            isEnabled.action(isEnabled.items)
        }
        return self.raw_button(action: action)
                   .disabled(isEnabled.items.isEmpty)
    }
    
    public func button(isEnabled: Bool = true,
                       action: @escaping () -> Void)
                       -> some View
    {
        let isEnabled = ActionEnableBool(isEnabled, action: action)
        return self.button(isEnabled)
    }
    
    public func button<T>(item: T?,
                          action: @escaping (T) -> Void)
                          -> some View
    {
        let isEnabled = ActionEnableItem(item, action: action)
        return self.button(isEnabled)
    }
    
    public func button<C: Collection>(items: C,
                          action: @escaping (C) -> Void)
                          -> some View
    {
        let isEnabled = ActionEnableItems(items, action: action)
        return self.button(isEnabled)
    }
    
    private func raw_button(action: @escaping () -> Void) -> some View {
        Button(action: action, label: self.raw_label)
            .if(self.localization.shortcut) {
                $0.keyboardShortcut($1)
            }
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
            .modifier(self.style.modifier)
    }
}

public struct ActionEnableBool {
    public var isEnabled: Bool
    public var action: () -> Void
    public init(_ isEnabled: Bool = true, action: @escaping () -> Void) {
        self.isEnabled = isEnabled
        self.action = action
    }
}

public struct ActionEnableItem<T> {
    public var item: T?
    public var action: (T) -> Void
    public init(_ item: T?, action: @escaping (T) -> Void) {
        self.item = item
        self.action = action
    }
}

public struct ActionEnableItems<C: Collection> {
    public var items: C
    public var action: (C) -> Void
    public init(_ items: C, action: @escaping (C) -> Void) {
        self.items = items
        self.action = action
    }
}
