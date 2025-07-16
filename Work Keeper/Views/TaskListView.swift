import Foundation
import SwiftUI



let customDateFormatter: DateFormatter = DateFormatter.taskDateFormatter
let date1 = Date()

 
    struct TaskListView: View {
        @StateObject private var viewModel = TaskListViewModel()
       
        @State private var selectedDate = Date()
        @State private var showNewTaskView = false
        @State private var showCompleteTaskView = false
        @State private var showPopup = false
        @State private var selectedTask: Task?
        @State private var selectedTaskForComplete: Task?
        
       
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
                                                    selectedTask = task
                                                    withAnimation {
                                                        showPopup = true
                                                    }
                                         
                                                }) {
                                                    Image("cancel")
                                                    Text("Отменить")
                                                }
                                                .tint(Color.custom(.taskCanceledOrange))
                                                
                                                Button(action: {
                                                    selectedTaskForComplete = task
                                                    showCompleteTaskView = true
                                                }) {
                                                    Image("completed")
                                                    Text("Завершить")
                                                }
                                                .tint(Color.custom(.taskCompleteGreen))
                                            }
                                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                                Button(action: {
                                                    viewModel.delete(task)
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
                
                if showPopup {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        VStack {
                           
                            VStack(spacing: 16) {
                                Spacer()
                                    .frame(height: 15)
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                                       .foregroundColor(.red)
                                                       .font(.system(size: 40))
                                    
                                    Text("Вы уверены, что хотите отменить задание?")
                                        .font(.custom(SFPro.regular.rawValue, size: 24))
                                                      .multilineTextAlignment(.center)
                                                      
                                }
                                
                                Text("Его статус изменится на отменённый, итоговая сумма обнулится")
                                                    
                                                        .font(.system(size: 20))
                                                    .foregroundColor(.gray)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal)
                                
                                
                                VStack(alignment: .leading) {
                                    Text("Комментарий")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                  
                                    ZStack {
                                        Color.white
                                    TextEditor(text: $viewModel.comment)
                                        .frame(height: 90)
                                        .padding(4)
                                        .lineLimit(1, reservesSpace: false)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.leading)
                                    }
                                    .frame(height: 90)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.custom(.strokeGray) ?? .gray, lineWidth: 0.5)
                                    )
                                    
                                    
                                }
                                
                                HStack {
                                    Button(action: {
                                        showPopup = false
                                    }) {
                                        ZStack {
                                            Rectangle()
                                                .tint(Color.white)
                                            Text("Нет")
                                                .tint(Color.black)
                                        }
                                    }
                                  
                                    .cornerRadius(7)
                                    .frame(width: 128)
                                    .frame(height: 42)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color(.black), lineWidth: 0.5)
                                    )
                                    
                                  Button(action: {
                                      if let task = selectedTask {
                                          let cancelVM = CancelTaskViewModel(task: task)
                                          cancelVM.comment = viewModel.comment
                                          cancelVM.cancel()
                                          
                                          }
                                      viewModel.loadTasks()
                                      withAnimation {
                                          showPopup = false
                                      }
                                  }) {
                                      ZStack {
                                          Rectangle()
                                              .tint(Color.custom(.cancelButtonRed))
                                          Text("Отменить задание")
                                              .tint(Color.white)
                                      }
                                    }
                                    .cornerRadius(7)
                                    .frame( height: 42)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 7)
                                            .stroke(Color(.black), lineWidth: 0.5)
                                    )
                                    
                                    
                                }
                                Spacer()
                                    .frame(height: 20)
  
                            }
                            .padding(.horizontal, 24)
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                            .shadow(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                
            }
            .sheet(isPresented: $showNewTaskView, onDismiss: {
                viewModel.loadTasks()
            }) {
                NewTaskView()
            }
            
            .sheet(item: $selectedTaskForComplete, onDismiss: {
                viewModel.loadTasks()
            }) { task in
                CompleteTaskView(viewModel: CompleteTaskViewModel(task: task))
            }
            
            .onAppear {
                viewModel.loadTasks()
            }
        }
    }
    
    #Preview {
        TaskListView()
    }



