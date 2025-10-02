import SwiftUI
import CoreData


// Кнопка-поле, открывающее wheel-пикер годов. Инкапсулирую и могу переиспользовать
struct YearPickerField: View {
    @Binding var year: Int
    @State private var isPresented = false
    
    var years: [Int] = Array(2000...Calendar.current.component(.year, from: Date()))

    var body: some View {
        Button {
            isPresented = true
        } label: {
            HStack(spacing: 6) {
                Text("\(year)")
                    .font(.body)
                
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
        .popover(isPresented: $isPresented) {
            YearWheelPickerView(year: $year, years: years)
                .frame(maxWidth: .infinity)
                .presentationDetents([.fraction(0.25)])
        }
    }
}

//Это pop up меню с выбором года
struct YearWheelPickerView: View {
    @Binding var year: Int
    let years: [Int]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Picker("Год", selection: $year) {
                ForEach(years, id: \.self) { y in
                    Text("\(y)").tag(y)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .frame( height: 135)
            .padding(.top, 15)
           
            Divider()

            HStack {
                Spacer()
                Button("Готово") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 5)
        }
        .padding()
    }
}

enum TopBar: String, CaseIterable, Identifiable {
    case income = "Доходы"
    case clients = "Клиенты"
    case tasks = "Задачи"
    var id: String { self.rawValue }
}



struct StatisticsView: View {
    
    @State var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var tab: TopBar = .income
    @Environment(\.managedObjectContext) private var context
    @StateObject private var incomeVM: IncomeViewModel

    init(context: NSManagedObjectContext) {
        _incomeVM = StateObject(wrappedValue: IncomeViewModel(context: context))
    }
    
    var body: some View {

        VStack {
            
            
            HStack {
                Text("Статистика")
                    .font(.custom(SFPro.regular.rawValue, size: 20))
                Spacer()
                
          
                YearPickerField(year: $selectedYear)
            }
            .padding(.horizontal)

           
            
            Picker("", selection: $tab) {
                ForEach(TopBar.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
            
           content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch tab {
            case .income:
            IncomeView(viewModel: incomeVM, year: selectedYear)
        case .clients:
            Text("Клиенты")
        case .tasks:
            Text("Задачи")
        }
    }
    
}



