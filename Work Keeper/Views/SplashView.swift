import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.custom(.splashBackground).edgesIgnoringSafeArea(.all)
            
            Image("SplashScreen")
        
                .scaledToFit()
                

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
