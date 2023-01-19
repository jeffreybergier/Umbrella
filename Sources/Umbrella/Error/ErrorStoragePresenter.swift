//
//  Created by Jeffrey Bergier on 2022/11/20.
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

extension ErrorStorage {
    public struct Presenter<B: EnvironmentBundleProtocol>: ViewModifier {
        
        private let router: (Error) -> any UserFacingError
        private let onDismiss: (Error) -> Void
        
        private let isAlreadyPresenting: Bool
        @Binding private var toPresent: ErrorStorage.Identifier?
        
        public init(isAlreadyPresenting: Bool,
                              toPresent: Binding<ErrorStorage.Identifier?>,
                                 router: @escaping (Error) -> any UserFacingError,
                              onDismiss: @escaping (Error) -> Void = { _ in })
        {
            _toPresent = toPresent
            self.isAlreadyPresenting = isAlreadyPresenting
            self.router = router
            self.onDismiss = onDismiss
        }
        
        public func body(content: Content) -> some View {
            content
                .modifier(
                    _Mover(isAlreadyPresenting: self.isAlreadyPresenting,
                               toPresent: self.$toPresent)
                )
                .modifier(
                    _Presenter<B>(toPresent: self.$toPresent,
                                   router: self.router,
                                   onDismiss: self.onDismiss)
                )
        }
        
    }
}

extension ErrorStorage {
    internal struct _Mover: ViewModifier {
        
        @ErrorStorage private var storage
        
        private let isAlreadyPresenting: Bool
        @Binding private var toPresent: ErrorStorage.Identifier?
        
        internal init(isAlreadyPresenting: Bool,
                      toPresent: Binding<ErrorStorage.Identifier?>)
        {
            _toPresent = toPresent
            self.isAlreadyPresenting = isAlreadyPresenting
        }
        
        internal func body(content: Content) -> some View {
            content
                .onLoadChange(of: self.storage.all,
                              perform: self.update(_:))
                .onLoadChange(of: self.isAlreadyPresenting,
                              perform: self.update(_:))
        }
        
        private func update(_: Any) {
            guard self.isAlreadyPresenting == false else { return }
            self.toPresent = self.storage.all.first
        }
    }
    
    internal struct _Presenter<B: EnvironmentBundleProtocol>: ViewModifier {
        
        private let router: (Error) -> any UserFacingError
        private let onDismiss: (Error) -> Void
        @Binding private var toPresent: ErrorStorage.Identifier?
        
        @ErrorStorage private var storage
        @EnvironmentObject private var bundle: B
        
        internal init(toPresent:   Binding<ErrorStorage.Identifier?>,
                      router:    @escaping (Error) -> any UserFacingError,
                      onDismiss: @escaping (Error) -> Void = { _ in })
        {
            _toPresent = toPresent
            self.router = router
            self.onDismiss = onDismiss
        }
        
        internal func body(content: Content) -> some View {
            content
                .alert(error: self.isUserFacingError,
                       bundle: self.bundle)
            {
                self.toPresent.map { self.storage.remove($0) }
                self.onDismiss($0)
            }
        }
        
        private var isUserFacingError: Binding<UserFacingError?> {
            Binding {
                guard let identifier = self.toPresent else { return nil }
                guard let error = self.storage.error(for: identifier) else {
                    self.storage.remove(identifier)
                    self.toPresent = nil
                    return nil
                }
                return self.router(error)
            } set: {
                guard $0 == nil else { return }
                self.toPresent = nil
            }
        }
    }
}
