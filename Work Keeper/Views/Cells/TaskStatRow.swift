import SwiftUI

struct TaskStatRow: View {
    @ObservedObject var viewModel: TaskListViewModel
    
    @State var canceledTasksCountOpacity: Double = 0
  
    static let months: [String] = ["За год", "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

    let title: String
    let year: Int
    let monthIndex: Int
    
    private var completedAmount: Int {
        if monthIndex == 0 {
            return viewModel.yearCompletedTasksCount
        }
        let idx = monthIndex - 1
        guard idx >= 0 && idx < viewModel.monthlyCompletedTasksCounts.count
        else { return 0 }
            return viewModel.monthlyCompletedTasksCounts[idx]
        }
        
    private var canceledAmount: Int {
        if monthIndex == 0 {
            return viewModel.yearCanceledTasksCount
        }
        let idx = monthIndex - 1
        guard idx >= 0 && idx < viewModel.monthlyCanceledTasksCounts.count
        else { return 0 }
            return viewModel.monthlyCanceledTasksCounts[idx]
        }
    
    
    var body: some View {
  
        HStack {
        
            if title == "За год" {
                Text(title)
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                Spacer()
                
                Text("\(completedAmount)") //количество выполненных заданий
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                
                Text("\(canceledAmount)")
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .opacity(canceledTasksCountOpacity)
                    .foregroundColor(Color.custom(.taskCanceledOrange))
                    .onChange(of: canceledAmount) { _, newValue in
                        if newValue > 0 {
                            canceledTasksCountOpacity = 1
                        } else {
                            canceledTasksCountOpacity = 0
                        }
                    }
      
            } else {
                Text(title)
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                Spacer()
                Text("\(completedAmount)")
                    .font(.custom(SFPro.regular.rawValue, size: 17))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                
                Text("\(canceledAmount)")
                    .font(.custom(SFPro.bold.rawValue, size: 17))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .opacity(canceledTasksCountOpacity)
                    .foregroundColor(Color.custom(.taskCanceledOrange))
                    .onChange(of: canceledAmount) { _, newValue in
                        if newValue > 0 {
                            canceledTasksCountOpacity = 1
                        } else {
                            canceledTasksCountOpacity = 0
                        }
                    }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .onAppear {
            if canceledAmount > 0 {
                canceledTasksCountOpacity = 1
            }
        }
   
    }
    
        

    
    
}
