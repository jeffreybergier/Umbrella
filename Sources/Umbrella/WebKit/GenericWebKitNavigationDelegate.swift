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

#if canImport(WebKit)
import WebKit

/// Provides a basic WKNavigationDelegate with expected behavior for showing simple web views.
public class GenericWebKitNavigationDelegate: NSObject, WKNavigationDelegate {

    public typealias OnError = (Swift.Error) -> Void
    public var onError: OnError?
    
    public init(onError: OnError? = nil) {
        self.onError = onError
    }
    
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        preferences: WKWebpagePreferences,
                        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void)
    {
        let url = navigationAction.request.url!
        let decision = type(of: self).decision(for: url)
        if decision == .cancel {
            NSLog("Invalid URL: \(url.absoluteString)")
        }
        decisionHandler(decision, preferences)
    }
    
    public func webView(_ webView: WKWebView,
                        didFail navigation: WKNavigation!,
                        withError error: Swift.Error)
    {
        self.onError?(error)
    }
    
    public func webView(_ webView: WKWebView,
                        didFailProvisionalNavigation navigation: WKNavigation!,
                        withError error: Swift.Error)
    {
        self.onError?(error)
    }
    
    internal static func decision(for url: URL) -> WKNavigationActionPolicy {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let scheme = components?.scheme ?? ""
        if scheme == "http" || scheme == "https" || scheme == "about" {
            return .allow
        } else {
            return .cancel
        }
    }
}
#endif
