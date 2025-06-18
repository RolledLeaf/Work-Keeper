import Foundation
import SwiftUI



struct Task: Identifiable {
    var id = UUID()
    let scheduledAt: Date
    let client: Client
    let isRemote: Bool
    let taskDescription: String
    let taskComment: String?
    let isCompleted: Status
    let paymentMethod: PaymentMethod?
    let contractAmount: Int
    let cost: Int
    let extraPayment: Int
    var totalAmount: Int {
        contractAmount - cost + extraPayment
    }
}

struct Client: Identifiable {
    var id = UUID()
    let firstName: String
    let lastName: String?
    let address: Address?
    let phoneNumber: String
    //let task: [Task]?
}

struct Address {
    let street: String
    let houseNumber: String
    let apartmentNumber: String?
    let entranceNumber: String?
    let floorNumber: Int?
    let isPrivateHouse: Bool
}

let customDateFormatter: DateFormatter = DateFormatter.taskDateFormatter
let date1 = Date()
let today1 = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 11, hour: 10, minute: 30))
let today2 = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 11, hour: 14, minute: 00))
let tomorrow = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12, hour: 10, minute: 0))
let twoDaysAgo = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10, hour: 10, minute: 0))


let address1 = Address(street: "Тверская", houseNumber: "12", apartmentNumber: "45", entranceNumber: "3", floorNumber: 8, isPrivateHouse: false)
let dianaAddress = Address(street: "Центральный проезд Хорошевского Серебряного Бора", houseNumber: "4", apartmentNumber: "61", entranceNumber: "3", floorNumber: 5, isPrivateHouse: false)
let juliaAddress = Address(street: "Кирова", houseNumber: "1", apartmentNumber: nil, entranceNumber: nil, floorNumber: nil, isPrivateHouse: true)
let address2 = Address(street: "Нагатинская", houseNumber: "22", apartmentNumber: "14", entranceNumber: "4Б", floorNumber: 12, isPrivateHouse: false)


let clientBoris = Client(firstName: "Борис", lastName: "Джонсон", address: address1, phoneNumber: "+79995552211")
let clientDiana = Client(firstName: "Диана", lastName: nil, address: dianaAddress, phoneNumber: "+79994468872")
let clientJulia = Client(firstName: "Юлия", lastName: "Петрова", address: juliaAddress, phoneNumber: "+79991234567")
let clientPetr = Client(firstName: "Петр", lastName: "Иванов", address: address2, phoneNumber: "+79996664599")

let task1 = Task(scheduledAt: tomorrow ?? date1, client: clientBoris, isRemote: false, taskDescription: "Встретиться с Борисом Джонсоном", taskComment: "", isCompleted: .scheduled, paymentMethod: nil, contractAmount: 3500, cost: 500, extraPayment: 1000)
let task2 = Task(scheduledAt: today1 ?? date1, client: clientDiana, isRemote: false, taskDescription: "Установить Windows 11", taskComment: nil, isCompleted: .completed, paymentMethod: .creditCard, contractAmount: 5000, cost: 950, extraPayment: 500)
let task3 = Task(scheduledAt: today2 ?? date1, client: clientJulia, isRemote: false, taskDescription: "Купить в магазине и настроить роутер keenetic. Сдача остаётся мне", taskComment: "Не получилось. Роутер не включается", isCompleted: .canceled, paymentMethod: nil, contractAmount: 0, cost: 0, extraPayment: 0)
let task4 = Task(scheduledAt: twoDaysAgo ?? date1, client: clientPetr, isRemote: true, taskDescription: "Office install Office install Office install Office install Office install ", taskComment: nil, isCompleted: .scheduled, paymentMethod: nil, contractAmount: 1500, cost: 500, extraPayment: 0)

let tasks: [Task] = [task1, task2, task3, task4]


    
    struct TaskListView: View {
        @State private var selectedDate = Date()
        
        var groupedTasks: [String: [Task]] {
            Dictionary(grouping: tasks) { task in
                let formatter = customDateFormatter
                return formatter.string(from: task.scheduledAt)
            }
        }
        
        var body: some View {
            VStack {
              
                HStack {
                    Button(action: {
                        //действие
                    }) {
                        Image("today")
                            .resizable()
                            .frame(width: 38, height: 38)
                    }
                   
                    
                    
                    Button(action: {
                        //action
                    }) {
                        Image("filters")
                            .resizable()
                            .frame(width: 35, height: 35)
                    }
                   
                    .padding(.leading, 8)
                    .padding(.trailing, 10)
                    
                    ZStack {
                        Image("calendar")
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        DatePicker("",
                                   selection: $selectedDate,
                                   displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .blendMode(.destinationOver)
                        .frame(width: 35, height: 35)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        //действие
                    }) {
                        Image("addTaskButton")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 5)
                        
                    }
                }
                .padding(.leading, 3)
                
                TextField("Поиск задания", text: .constant(""))
                    .padding(9)
                    .padding(.leading, 25)
                    .background(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                            .padding(.leading, 10)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.custom(.searchFieldGray) ?? .searchFieldGray)
                    )
                
                
              
                
                if tasks.isEmpty {
                    
                    Spacer()
                        .frame(height: 117)
                    
                    Image("noTasksPlaceholder")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .frame(width: 266, height: 273)
                        .padding(.leading, 65)
                    
                    
                    Text("Заданий пока нет")
                        .font(.custom("SFPROREGULAR", size: 24))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: 38)
                    List {
                        ForEach(groupedTasks.keys.sorted { $0 > $1 }, id: \.self) { dateKey in
                            Section(header: Text(dateKey).font(.headline)) {
                                ForEach(groupedTasks[dateKey] ?? []) { task in
                                    TaskRow(task: task)
                                    
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                             Button(action: {
                                                    //действие
                                                }) {
                                                        Image("cancel")
                                                        Text("Отменить")
                                                }
                                                .tint(Color.custom(.taskCanceledOrange))

                                            Button(action: {
                                                   //действие
                                               }) {
                                                       Image("completed")
                                                       Text("Завершить")
                                               }
                                                .tint(Color.custom(.taskCompleteGreen))
                                            }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(action: {
                                                   //действие
                                               }) {
                                                Image("delete")
                                                       Text("Удалить")
                                               }
                                               .tint(Color.custom(.deleteButtonRed))

                                           Button(action: {
                                                  //действие
                                              }) {
                                                      Image("edit")
                                                      Text("Редактировать")
                                              }
                                              .tint(Color.custom(.editButtonGray))
                                           }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.clear)
                            )
                        }
                    }
                    
                    .listStyle(PlainListStyle())
                    .padding(.leading, -20)
                    .padding(.trailing, -20)
                }
            }
            
            .padding(.trailing, 16)
            .padding(.leading, 16)
        }
    }
    
    #Preview {
        TaskListView()
    }



