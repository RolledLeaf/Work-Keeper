import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.custom(.splashBackground).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                HStack {
                    Image("splashLogo")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 162)
                }
                
                HStack {
                    Text("WORK")
                        .font(.custom(Montserrat.black.rawValue, size: 15))
                    
                    Text("KEEPER")
                        .font(.custom(Montserrat.regular.rawValue, size: 15))
                    Spacer()
                }
                .padding(.leading, 47)
                

                
                Spacer()
            }
        }
        .overlay(alignment: .bottomTrailing) {
                            HStack {
                                Spacer()
                                ProgressView("Загрузка…")
                                    .foregroundStyle(.mainBlack)
                                    .progressViewStyle(.circular)
                                    .font(.custom(Montserrat.regular.rawValue, size: 25))
                                Spacer()
                            }
                            .padding(.bottom, 180)
        }
    }
}

#Preview {
    SplashView()
}
