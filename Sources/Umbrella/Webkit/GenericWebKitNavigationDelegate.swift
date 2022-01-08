//
//  Created by Jeffrey Bergier on 2021/02/19.
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

import WebKit
import SwiftUI
import Collections

/// Provides a basic WKNavigationDelegate with expected behavior for showing simple web views.
/// Note, this class is not tested because there are too many custom types from WebKit.
public class GenericWebKitNavigationDelegate: NSObject, WKNavigationDelegate {
    
    public enum Error: UserFacingError {
        case invalidURL(URL)
        
        public var errorCode: Int {
            switch self {
            case .invalidURL:
                return 1001
            }
        }
        public var message: LocalizedStringKey {
            switch self {
            case .invalidURL(let url):
                return "Phrase.ErrorInvalidURL\(url.absoluteString)"
            }
        }
    }
    
    public typealias OnError = (UserFacingError) -> Void
    
    public var errors: Deque<UFError>
    public var onError: OnError?
    
    public init(_ errors: Deque<UFError>, onError: OnError? = nil) {
        self.errors = errors
        self.onError = onError
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        preferences: WKWebpagePreferences,
                        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void)
    {
        let url = navigationAction.request.url!
        guard
            let comp = URLComponents(url: url, resolvingAgainstBaseURL: true),
            comp.scheme == "http" || comp.scheme == "https" || comp.scheme == "about"
        else {
            decisionHandler(.cancel, preferences)
            let localizedError = Error.invalidURL(url)
            self.errors.append(localizedError)
            self.onError?(localizedError)
            return
        }
        decisionHandler(.allow, preferences)
    }
    
    public func webView(_ webView: WKWebView,
                        didFail navigation: WKNavigation!,
                        withError error: Swift.Error)
    {
        let localizedError = GenericError(error as NSError)
        self.errors.append(localizedError)
        self.onError?(localizedError)
    }
    
    public func webView(_ webView: WKWebView,
                        didFailProvisionalNavigation navigation: WKNavigation!,
                        withError error: Swift.Error)
    {
        let localizedError = GenericError(error as NSError)
        self.errors.append(localizedError)
        self.onError?(localizedError)
    }
}
