import Foundation

public enum CoreUtilsKitLocalization: String {
    case currency_unit
    case currency_thousand
    case currency_million
    case currency_billion
    case point_unit
    case required_touch_id
    case required_face_id
    
    public var localized: String {
        return rawValue.localized(using: "")
    }
    
//    public var localized: String {
//        if VDSConfigure.shared.isCocoaPodsState() {
//            let bundle = Bundle(for: VDSConfigure.self)
//            if let bundleUrl = bundle.url(forResource: "CoreUtilsKitBundle", withExtension: "bundle") {
//                let podBundle = Bundle(url: bundleUrl)
//                return rawValue.localized(using: "CoreUtilsKit", in: podBundle)
//            }
//            return ""
//        } else {
//            return rawValue.localized(using: "CoreUtilsKit", in: Bundle(for: VDSConfigure.self))
//        }
//    }
}
