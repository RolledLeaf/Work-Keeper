import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.custom(.splashBackground).edgesIgnoringSafeArea(.all)
            
            Image("SplashScreen")
                .resizable()
                .scaledToFill()
                
//                .offset(x: -30)
            VStack {
   
                ProgressView("Загрузка…")
                    .foregroundStyle(.whiteOnly)
                    .progressViewStyle(.circular)
                    .font(.custom(Montserrat.regular.rawValue, size: 15))
                    .padding(.top, 250)
            }
        }
       
       
    }
}

#Preview {
    SplashView()
}
