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
    public struct Presenter: ViewModifier {
        
        /// HACK because SwiftUI needs to let things settle before trying to present next error
        #if os(watchOS)
        /// TODO: Remove watch long delay. Needed because dismissing errors takes forever.
        public static var HACK_errorDelay: DispatchTime { .now() + 0.4 }
        #else
        public static var HACK_errorDelay: DispatchTime { .now() + 0.1 }
        #endif
        
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
                    _Presenter(toPresent: self.$toPresent,
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
                .onReceive(self.storage.nextErrorPub) { _ in
                    self.update()
                }
                .onChange(of: self.isAlreadyPresenting) { _ in
                    self.update()
                }
                .onAppear() {
                    self.update()
                }
        }
        
        private func update() {
            DispatchQueue.main.asyncAfter(deadline: Presenter.HACK_errorDelay) {
                guard
                    let identifier = self.storage.nextError,
                    self.isAlreadyPresenting == false
                else { return }
                self.toPresent = identifier
            }
        }
    }
    
    internal struct _Presenter: ViewModifier {
        
        private let router: (Error) -> any UserFacingError
        private let onDismiss: (Error) -> Void
        @Binding private var toPresent: ErrorStorage.Identifier?
        
        @ErrorStorage private var storage
        @Environment(\.bundle) private var bundle
        
        internal init(toPresent: Binding<ErrorStorage.Identifier?>,
                      router:    @escaping (Error) -> any UserFacingError,
                      onDismiss: @escaping (Error) -> Void = { _ in })
        {
            _toPresent     = toPresent
            self.router    = router
            self.onDismiss = onDismiss
        }
        
        internal func body(content: Content) -> some View {
            content
                .alert(error: self.isUserFacingError,
                       bundle: self.bundle)
            { error in
                let presented = self.toPresent
                let storage = self.storage
                DispatchQueue.main.asyncAfter(deadline: Presenter.HACK_errorDelay) {
                    presented.map { storage.remove($0) }
                }
                self.toPresent = nil
                self.onDismiss(error)
            }
        }
        
        private var isUserFacingError: Binding<UserFacingError?> {
            Binding {
                guard let identifier = self.toPresent else { return nil }
                return self.storage.error(for: identifier).map { self.router($0) }
            } set: {
                guard $0 == nil else { return }
                self.toPresent = nil
            }
        }
    }
}
