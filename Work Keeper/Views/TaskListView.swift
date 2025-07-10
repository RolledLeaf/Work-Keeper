import Foundation
import SwiftUI



let customDateFormatter: DateFormatter = DateFormatter.taskDateFormatter
let date1 = Date()

 
    struct TaskListView: View {
        @StateObject private var viewModel = TaskListViewModel()
       
        @State private var selectedDate = Date()
        @State private var showNewTaskView = false
        
        var groupedTasks: [String: [Task]] {
            Dictionary(grouping: viewModel.tasks) { task in
                let formatter = customDateFormatter
                return formatter.string(from: task.scheduledAt ?? date1) //Force operation
            }
        }
        
        var body: some View {
            
            
            
            ZStack {
                Color(.white).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        hideKeyboard()
                    }
                
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
                            showNewTaskView = true
                        }) {
                            Image("addTaskButton")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 5)
                            
                        }
                    }
                    .padding(.leading, 3)
                    
                    TextField("Поиск задания", text: .constant(""))
                        .submitLabel(.done)
                           .onSubmit {
                               hideKeyboard() // кастомная функция
                           }
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
                    
                    
                    
                    
                    if groupedTasks.isEmpty {
                        
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
            .sheet(isPresented: $showNewTaskView) {
                NewTaskView()
            }
            
            .onAppear {
                viewModel.loadTasks()
            }
        }
    }
    
    #Preview {
        TaskListView()
    }



