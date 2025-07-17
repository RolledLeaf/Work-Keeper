import SwiftUI

struct TaskView: View {
 
    @State var textFieldText = "Установить впн на роутер Keenetic"
    @State var commentText = " Win 11 pro (3BN89-7W2HJ-HDRGD-7PJ9D-PYT6Y), Of (CBNTB-M333J-HQGD9-J9CHT-MKQ4X) (375023 440170 561052 "

    
    var body: some View {
        
       
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            VStack {
                
                Text("Просмотр задания")
                    .font(.custom(SFPro.regular.rawValue, size: 25))
                
                HStack {
                    
                    VStack {
                        Text("Герман")
                            .font(.custom(SFPro.bold.rawValue, size: 20))
                        Spacer()
                            .frame(height: 6)
                        
                        Text("+7 999 222 33 44")
                            .font(.custom(SFPro.regular.rawValue, size: 16))
                            .foregroundColor(.custom(.taskTextGray))
                    }
                    
                    Spacer()
                    
                    
                    ZStack {
                        Color.custom(.taskViewGreen)
                        Text("Завершено")
                            .frame(width: 133, height: 33)
                        
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                    }
                    .frame(width: 133, height: 33)
                    .cornerRadius(10)
                    
                    
                }
                .padding(.top, 24)
                .padding(.leading, 32)
                .padding(.trailing, 20)
                
                Spacer()
                    .frame(height: 28)
           
                ZStack {
                    Color.custom(.inactiveFiledGray)
                      
                    VStack {
                        HStack {
                            
                            Image("mapPinBlack")
                                .offset(x: 20)
                                
                               
                            Spacer()
                            
                            Text("Центральный проезд Хорошевского Серебряного Бора 12")
                                .font(.custom(SFPro.regular.rawValue, size: 17))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .frame(maxWidth: 306)
                                .offset(y: 7)
                            
                            Spacer()
                                
                            
                        }
                        HStack{
                            Spacer()
                            Rectangle()
                                .frame(width: 345, height: 0.5)
                                .padding(.top, 4)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Image("calendar")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            
                            
                            Text("17 июля 2025")
                            
                            Spacer()
                            
                            Image(systemName: "clock")
                            
                            Text("11:00")
         
                        }
                        .padding(.leading, 21)
                        .padding(.trailing, 21)
                        
                        Spacer()
                    }
                 
                }
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                )
                .frame(height: 105)
                .padding(.horizontal, 16)
                
                Spacer()
                    .frame(height: 15)
                
                HStack {
                    Text("Задание")
                        .font(.custom(SFPro.regular.rawValue, size: 16))
                        .foregroundColor(.custom(.taskTextGray))
                    
                     Spacer()
                    
                    Image("pen")
                    
                }
                .padding(.leading, 30)
                .padding(.trailing, 37)
                
                ZStack {
                    Color.custom(.inactiveFiledGray)
                    VStack {
                        
                        Text(textFieldText)
                            .font(.custom(SFPro.regular.rawValue, size: 18))
                            .multilineTextAlignment(.center)

                            .frame(height: 82, alignment: .center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(height: 82)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                
                HStack {
                    Text("Комментарий")
                        .font(.custom(SFPro.regular.rawValue, size: 16))
                        .foregroundColor(.custom(.taskTextGray))
                    
                     Spacer()
                    
                    Image("pen")
                    
                }
                .padding(.leading, 30)
                .padding(.trailing, 37)
                
                ZStack {
                    Color.custom(.inactiveFiledGray)
                    VStack {
                        
                        Text(commentText)
                            .font(.custom(SFPro.regular.rawValue, size: 18))
                            .multilineTextAlignment(.center)

                            .frame(height: 96, alignment: .center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(height: 96)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                
                Spacer()
                    .frame(height: 25)
                
                HStack {
                    Text("Оплата")
                        .font(.custom(SFPro.regular.rawValue, size: 16))
                        .foregroundColor(.custom(.taskTextGray))
                    
                    Spacer()
                }
                .padding(.leading, 30)
                
                ZStack {
                    Color.custom(.inactiveFiledGray)
                    VStack {
                        HStack {
                            Text("Договорились")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            Text("3000")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                        .padding(.top, 15)
                        
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 340, height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                        }
                        
                        HStack {
                            Text("Издержки")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            Text("3000")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                       
                        
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 340, height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                        }
                        
                        HStack {
                            Text("Доплата")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                            Spacer()
                            Text("3000")
                                .font(.custom(SFPro.regular.rawValue, size: 20))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                       
                        
                        HStack {
                            Spacer()
                            Rectangle()
                                .frame(width: 340, height: 1)
                                .foregroundColor(Color.custom(.strokeGray))
                        }
                        
                        HStack {
                            Text("Итого")
                                .font(.custom(SFPro.bold.rawValue, size: 24))
                            Spacer()
                            Text("3000")
                                .font(.custom(SFPro.bold.rawValue, size: 24))
                        }
                        .padding(.leading, 29)
                        .padding(.trailing, 18)
                        Spacer()
                    }
    
                }
                .cornerRadius(8)
                .frame(height: 190)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 0.5)
                        .opacity(0.5)
                        .padding(.horizontal, 16)
                )
                Spacer()
            }
        }
    }
}


#Preview {
    TaskView()
}
