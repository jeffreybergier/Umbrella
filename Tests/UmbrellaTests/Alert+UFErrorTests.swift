//
//  Created by Jeffrey Bergier on 2021/02/22.
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

import XCTest
import SwiftUI
import Umbrella

class AlertUFErrorTests: XCTestCase {
    
    func test_noOptions() {
        let alert = Alert(ImplicitError.all)
        var dumpS = String()
        dump(alert, to: &dumpS)
        XCTAssertTrue(dumpS.contains("style: SwiftUI.Alert.Button.Style.cancel"))
        XCTAssertTrue(dumpS.contains("My Explicit Message"))
        XCTAssertTrue(dumpS.contains("Noun.Error"))
        XCTAssertTrue(dumpS.contains("Verb.Dismiss"))
        XCTAssertFalse(dumpS.contains("MyExplicitDismiss"))
        XCTAssertFalse(dumpS.contains("MyExplicitTitle"))
        XCTAssertFalse(dumpS.contains("SwiftUI.Alert.Button.Style.destructive"))
        XCTAssertFalse(dumpS.contains("MyExplicitOption1"))
    }
    
    func test_options() {
        let alert = Alert(ExplicitError.all)
        var dumpS = String()
        dump(alert, to: &dumpS)
        XCTAssertTrue(dumpS.contains("MyExplicitDismiss"))
        XCTAssertTrue(dumpS.contains("style: SwiftUI.Alert.Button.Style.cancel"))
        XCTAssertTrue(dumpS.contains("My Explicit Message"))
        XCTAssertTrue(dumpS.contains("MyExplicitTitle"))
        XCTAssertTrue(dumpS.contains("SwiftUI.Alert.Button.Style.destructive"))
        XCTAssertTrue(dumpS.contains("MyExplicitOption1"))
        XCTAssertFalse(dumpS.contains("Noun.Error"))
        XCTAssertFalse(dumpS.contains("Verb.Dismiss"))
    }
}
