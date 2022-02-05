//
//  Created by Jeffrey Bergier on 2022/02/05.
//  Copyright © 2021 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public typealias CameraResult = Result<Data, CameraError>
public typealias CameraSelection = (CameraResult?) -> Void

public enum CameraError: Int, CustomNSError, Codable {

    /// The domain of the error.
    static public var errorDomain: String { "com.saturdayapps.waterme.umbrella.camera" }
    /// The error code within the given domain.
    public var errorCode: Int { return self.rawValue }
    /// The user-info dictionary.
    public var errorUserInfo: [String: Any] {
        return [
            NSUnderlyingErrorKey: String(reflecting: self)
        ]
    }

    case capture
    case format
    case compression
}
