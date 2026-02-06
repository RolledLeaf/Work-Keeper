import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.custom(.splashBackground).edgesIgnoringSafeArea(.all)
            
          
                

            VStack {
                Spacer()
                
                HStack {
                    Image("splashLogo")
                    Spacer()
                }
                
                HStack {
                    Text("WORK")
                        .font(.custom(Montserrat.black.rawValue, size: 15))
                    
                    Text("KEEPER")
                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                    Spacer()
                }
                .padding(.leading, 47)
                
                HStack {
                   
                    ProgressView("Загрузка…")
                        .foregroundStyle(.mainBlack)
                        .progressViewStyle(.circular)
                        .font(.custom(Montserrat.regular.rawValue, size: 25))
                        .padding(.top, 50)
                    
                }
                
                Spacer()
            }
        }
       
       
    }
}

#Preview {
    SplashView()
}
