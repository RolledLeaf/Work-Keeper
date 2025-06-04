import Foundation
import SwiftUI



struct Task: Identifiable {
    var id = UUID()
    let scheduledAt: Date
    let client: Client
    let taskDescription: String
    let taskComment: String?
    let isCompleted: Status
    let contractAmount: Double
    let cost: Double
    var totalAmount: Double {
        contractAmount - cost
    }
}

struct Client {
    let firstName: String
    let lastName: String?
    let address: Address
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


let date1 = Date()


let address1 = Address(street: "Тверская", houseNumber: "12", apartmentNumber: "45", entranceNumber: "3", floorNumber: 8, isPrivateHouse: false)
let dianaAddress = Address(street: "Стромынка", houseNumber: "4", apartmentNumber: "61", entranceNumber: "3", floorNumber: 5, isPrivateHouse: false)
let juliaAddress = Address(street: "Кирова", houseNumber: "1", apartmentNumber: "2", entranceNumber: nil, floorNumber: nil, isPrivateHouse: true)


let clientBoris = Client(firstName: "Борис", lastName: "Джонсон", address: address1, phoneNumber: "+79995552211")
let clientDiana = Client(firstName: "Диана", lastName: nil, address: dianaAddress, phoneNumber: "+79994468872")
let clientJulia = Client(firstName: "Юлия", lastName: "Петрова", address: juliaAddress, phoneNumber: "+79991234567")

let task1 = Task(scheduledAt: date1, client: clientBoris, taskDescription: "Встретиться с Борисом Джонсоном", taskComment: "", isCompleted: .scheduled, contractAmount: 35000, cost: 500)
let task2 = Task(scheduledAt: date1, client: clientDiana, taskDescription: "Установить Windows 11", taskComment: nil, isCompleted: .completed, contractAmount: 5000, cost: 950)
let task3 = Task(scheduledAt: date1, client: clientJulia, taskDescription: "Настроить роутер", taskComment: "Не получилось. Роутер не включается", isCompleted: .canceled, contractAmount: 0, cost: 0)

let tasks = [task1, task2, task3]

struct TaskListView: View {
    var body: some View {
        VStack {
            
            HStack {
                Button(action: {
                    //действие
                }) {
                    Image("today")
                }
                
                
                Button(action: {
                    //action
                }) {
                    Image("filters")
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                
                Button(action: {
                    //action
                }) {
                    Image("calendar")
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
            
            
            Spacer()
                .frame(height: 37)
           
            if tasks.isEmpty {
                Image("noTasksPlaceholder")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .frame(width: 266, height: 273)
                    .padding(.leading, 65)
                
                
                Text("Заданий пока нет")
                    .font(.custom("SFPro", size: 24))
                    .fontWeight(.bold)
                .multilineTextAlignment(.center) } else {
                    List(tasks) { task in
                        TaskRow(task: task)
                        Color(.clear)
                            .padding(.bottom, 8)
                            .listRowSeparator(.hidden)
                    }
                }
            
            Spacer()
            
        }
        .padding(.trailing, 16)
        .padding(.leading, 16)
    }
}

#Preview {
    TaskListView()
}
