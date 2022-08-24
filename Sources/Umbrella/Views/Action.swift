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

/// Make the creation of buttons and labels that are accessible and have keyboard shortcuts easy.
/// Customize by using `outerModifier`. Make sophisitcated labels using `innerModifier`.
/// Use `some ActionStyle` with `ActionStyleImp` to hide implementation details.
public protocol ActionStyle {
    associatedtype LS: LabelStyle
    associatedtype M1: ViewModifier
    associatedtype M2: ViewModifier
    
    /// Define the system role of the button
    var buttonRole:    ButtonRole? { get }
    /// Choose how the label shows the icon
    var labelStyle:    LS { get }
    /// Style and modify the entire button / label
    var outerModifier: M1 { get }
    /// Style and modify the text inside the label but not the whole label
    var innerModifier: M2 { get }
}

extension ActionStyle {
    public func action(text localization: ActionLocalization) -> some Action {
        return ActionImp(style: self, localization: localization)
    }
}

public struct ActionStyleImp<LS: LabelStyle, M1: ViewModifier, M2: ViewModifier>: ActionStyle {
    
    public var buttonRole: ButtonRole?
    public var labelStyle: LS
    public var outerModifier: M1
    public var innerModifier: M2
    
    public init(buttonRole: ButtonRole? = nil, labelStyle: LS, outerModifier: M1, innerModifier: M2) {
        self.buttonRole = buttonRole
        self.labelStyle = labelStyle
        self.outerModifier = outerModifier
        self.innerModifier = innerModifier
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
            .modifier(self.style.outerModifier)
            .accessibilityLabel(self.localization.title)
            .if(self.localization.hint) {
                $0.accessibilityHint($1)
            }
    }
    
    @ViewBuilder private func raw_label() -> some View {
        if let image = self.localization.image {
            Label {
                Text(self.localization.title)
                    .modifier(self.style.innerModifier)
            } icon: {
                image.image
            }
            .labelStyle(self.style.labelStyle)
        } else {
            Text(self.localization.title)
                .modifier(self.style.innerModifier)
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
            .modifier(self.style.outerModifier)
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

// MARK: Convenience initializers
extension ActionStyleImp {
    public init(buttonRole: ButtonRole? = nil) where LS == DefaultLabelStyle, M1 == EmptyModifier, M2 == EmptyModifier {
        self.buttonRole = buttonRole
        self.labelStyle = DefaultLabelStyle()
        self.outerModifier = EmptyModifier()
        self.innerModifier = EmptyModifier()
    }
    
    public init(buttonRole: ButtonRole? = nil, outerModifier: M1) where LS == DefaultLabelStyle, M2 == EmptyModifier {
        self.buttonRole = buttonRole
        self.labelStyle = DefaultLabelStyle()
        self.outerModifier = outerModifier
        self.innerModifier = EmptyModifier()
    }
    
    public init(buttonRole: ButtonRole? = nil, innerModifier: M2) where LS == DefaultLabelStyle, M1 == EmptyModifier {
        self.buttonRole = buttonRole
        self.labelStyle = DefaultLabelStyle()
        self.outerModifier = EmptyModifier()
        self.innerModifier = innerModifier
    }
    
    public init(buttonRole: ButtonRole? = nil, outerModifier: M1, innerModifier: M2) where LS == DefaultLabelStyle {
        self.buttonRole = buttonRole
        self.labelStyle = DefaultLabelStyle()
        self.outerModifier = outerModifier
        self.innerModifier = innerModifier
    }
    
    public init(buttonRole: ButtonRole? = nil, labelStyle: LS) where M1 == EmptyModifier, M2 == EmptyModifier {
        self.buttonRole = buttonRole
        self.labelStyle = labelStyle
        self.outerModifier = EmptyModifier()
        self.innerModifier = EmptyModifier()
    }
    
    public init(buttonRole: ButtonRole? = nil, labelStyle: LS, outerModifier: M1) where M2 == EmptyModifier {
        self.buttonRole = buttonRole
        self.labelStyle = labelStyle
        self.outerModifier = outerModifier
        self.innerModifier = EmptyModifier()
    }
    
    public init(buttonRole: ButtonRole? = nil, labelStyle: LS, innerModifier: M2) where M1 == EmptyModifier {
        self.buttonRole = buttonRole
        self.labelStyle = labelStyle
        self.outerModifier = EmptyModifier()
        self.innerModifier = innerModifier
    }
}
