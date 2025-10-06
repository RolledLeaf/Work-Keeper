import SwiftUI

struct TasksView: View {
    @ObservedObject var viewModel: TaskListViewModel
    
    let year: Int
    
    var body: some View {
        
        ZStack {
            Color.custom(.newTaskBackgroundGray).edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Color.white
                   
                        HStack {
                            Text("Всего")
                                .font(Font.custom(SFPro.bold.rawValue, size: 24))
                                .padding(10)
                            
                            Spacer()
                            
                            
                            Text("\(viewModel.tasksCount)")
                                .font(Font.custom(SFPro.bold.rawValue, size: 24))

                            Text("(\(viewModel.canceledTasksCount))")
                                .font(Font.custom(SFPro.bold.rawValue, size: 24))
                                .foregroundColor(Color.custom(.taskCanceledOrange))
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            .padding(.horizontal, 10)
                    )
                   
                   
                }
                
                
                
                Spacer()
            }
            
        }
        .onAppear {
            viewModel.loadAlltasksCount()
            viewModel.loadMonthlyCompletedTasks(year: year)
        }
        
       
    }
    private func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return f.string(from: (value as Int) as NSNumber) ?? "0"
    }
}
