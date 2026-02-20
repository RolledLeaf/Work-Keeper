import SwiftUI

struct PressImageButtonStyle: ButtonStyle {
    let normalImage: String
    let pressedImage: String

    func makeBody(configuration: Configuration) -> some View {
       
            
        ZStack {
                   Circle()
                       .fill(Color.custom(.bckgFieldGray))

                   Circle()
                       .stroke(Color.custom(.strokeGray), lineWidth: 0.5)

                   Image(configuration.isPressed ? pressedImage : normalImage)
                       .resizable()
                       .frame(width: 17.31, height: 14)
                       .tint(Color.custom(.pitchBlack))
               }
               .frame(width: 30, height: 30)
        
    }
}
