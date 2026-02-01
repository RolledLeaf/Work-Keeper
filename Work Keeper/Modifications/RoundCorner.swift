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
    
    
    static func taskCardHeight(for width: CGFloat) -> CGFloat {
        switch width {
        case 393: //iPhone 16 Pro, 16, 15 Pro, 15, 14 Pro
            return 170
        case 414: //iPhone 11 Pro Max, XS Max, 11, XR, 8 Plus, 7 Plus, 6s Plus, 6 Plus
            return 170
        case 428: //iPhone 14 Plus, 13 Pro Max, 12 Pro Max
            return 170
        case 390: //iPhone 14, 13 Pro, 13, 12 Pro, 12
            return 170
        case 375:  //*iPhone 13 mini, 12 mini, 11 Pro, XS, X, SE (3rd/2nd gen), 8, 7, 6s, 6
            return 170
           
        default:
            return 170
        }
    }
    
    static func taskCardWidth(for width: CGFloat) -> CGFloat {
        switch width {
        case 414: //iPhone 11 Pro Max, XS Max, 11, XR, 8 Plus, 7 Plus, 6s Plus, 6 Plus
            return 170
        case 390: //iPhone 14, 13 Pro, 13, 12 Pro, 12
            return 173
        case 375:
            return 165
        default:
            return 175
        }
    }
    
    //    iPhone 16 Pro Max / 17 Pro Max: 440 x 956 pt
    //    iPhone 16 Pro / 17 Pro: 402 x 874 pt
    //    iPhone 16 / 15 / 14 Pro: 393 x 852 pt
    //    iPhone 16 Plus / 15 Pro Max / 15 Plus / 14 Pro Max: 430 x 932 pt
    //    iPhone 14 Plus / 13 Pro Max / 12 Pro Max: 428 x 926 pt
    //    iPhone 14 / 13 Pro / 13 / 12 Pro / 12: 390 x 844 pt
        
    //    Older & Compact Models
    //    iPhone 13 mini / 12 mini / 11 Pro / XS / X: 375 x 812 pt
    //    iPhone 11 Pro Max / XS Max / XR: 414 x 896 pt
    //    iPhone 11: 414 x 896 pt
    //    iPhone 8 Plus / 7 Plus / 6s Plus: 414 x 736 pt
    //    iPhone SE (3rd/2nd gen) / 8 / 7 / 6s / 6: 375 x 667 pt
    //
    
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
