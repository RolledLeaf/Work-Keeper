import SwiftUI

struct TasksView: View {
    @ObservedObject var viewModel: TaskListViewModel
    
    
    
    let year: Int
    
    private let months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    var body: some View {
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Color.white
                   
                        HStack {
                            Text("Выполнено: ")
                                .font(Font.custom(SFPro.bold.rawValue, size: 22))
                             
                            
                            Spacer()
                                .frame(width: 30)
                            
                            Text("\(viewModel.tasksCount)")
                                .font(Font.custom(SFPro.bold.rawValue, size: 22))

                            Spacer()
                                .frame(width: 60)
                            
                            Text("Отмены: ")
                                .font(Font.custom(SFPro.bold.rawValue, size: 22))
                               
                            
                            Spacer()
                                .frame(width: 30)
                            Text("\(viewModel.canceledTasksCount)")
                                .font(Font.custom(SFPro.bold.rawValue, size: 22))
                                .foregroundColor(Color.custom(.taskCanceledOrange))
                                
                                
                    }
     
                }
                .frame(height: 50)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .padding(.horizontal, 10)
                )
                
                List {
                    TaskStatRow(viewModel: viewModel, title: months[0], year: year, monthIndex: 0)
                        .listRowSeparator(.hidden)
                    
                    ForEach(1...12, id: \.self) { m in
                        TaskStatRow(viewModel: viewModel, title: months[m], year: year, monthIndex: m)
                            .listRowSeparator(.hidden)
                    }
                }
                
                
                Spacer()
            }
            
        }
        .onAppear {
            viewModel.loadAlltasksCount()
            viewModel.loadAllCanceledTasksCount()
            viewModel.loadMonthlyCompletedTasks(year: year)
            viewModel.loadMonthlyCanceledTasks(year: year)
        }
        
       
    }
    private func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f.string(from: (value as Int) as NSNumber) ?? "0"
    }
}
