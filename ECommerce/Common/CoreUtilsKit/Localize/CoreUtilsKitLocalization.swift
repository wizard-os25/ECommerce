

import Foundation

public enum CoreUtilsKitLocalization: String {
    case point_unit
    case required_touch_id
    case required_face_id
    
    public var localized: String {
        return rawValue.localized(using: "")
    }
}

