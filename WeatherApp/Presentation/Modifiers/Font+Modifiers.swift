import SwiftUI

enum AvenirNextWeight: String {
    case regular = "AvenirNextLTPro-Regular"
    case bold = "AvenirNextLTPro-Bold"
}

extension View {

    func avenirNextFont(_ weight: AvenirNextWeight, size: CGFloat) -> some View {
        font(.custom(weight.rawValue, size: size))
    }
}
