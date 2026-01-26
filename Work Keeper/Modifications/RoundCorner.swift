import SwiftUI

enum DeviceLayout {
    static func cardRadius(for width: CGFloat) -> CGFloat {
        switch width {
        case 393: //iPhone 16 Pro, 16, 15 Pro, 15, 14 Pro
            return 36
        case 414: //iPhone 11 Pro Max, XS Max, 11, XR, 8 Plus, 7 Plus, 6s Plus, 6 Plus
            return 12
        case 428: //iPhone 14 Plus, 13 Pro Max, 12 Pro Max
            return 36
        case 390: //iPhone 14, 13 Pro, 13, 12 Pro, 12
            return 12
            //375 pt: iPhone 13 mini, 12 mini, 11 Pro, XS, X, SE (3rd/2nd gen), 8, 7, 6s, 6
        default:
            return 36
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
