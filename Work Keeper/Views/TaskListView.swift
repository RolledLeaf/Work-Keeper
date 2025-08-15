import Foundation
import SwiftUI



let customDateFormatter: DateFormatter = DateFormatter.taskDateFormatter

private func dayKey(_ date: Date) -> Date {
    Calendar.current.startOfDay(for: date)
}

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    
    @State private var selectedDate = Date()
    @State private var showNewTaskView = false
    @State private var showCompleteTaskView = false
    @State private var showEditTaskView = false
    
    @State private var showPopup = false
    @State private var selectedTask: Task?
    @State private var taskToCancel: Task?
    @State private var navigateToTaskView = false

    @State private var selectedTaskForComplete: Task?
    @State private var selectedTaskForEdit: Task?
    @State private var listScrollPosition: Date?
    

    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            Color(.white).edgesIgnoringSafeArea(.all)
                .onTapGesture { hideKeyboard() }

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
                            .fill(Color.custom(.searchFieldGray))
                    )

                if viewModel.groupedTasksByDate.isEmpty {
                    Spacer()
                        .frame(height: 117)

                    Image("noTasksPlaceholder")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .frame(width: 266, height: 273)
                        .padding(.leading, 65)

                    Text("Заданий пока нет")
                        .font(.custom(SFPro.regular.rawValue, size: 24))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Spacer()
                } else {
                    Spacer()
                        .frame(height: 38)
                    NavigationStack {
                        ScrollViewReader { proxy in
                            List {
                                ForEach(viewModel.groupedTasksByDate.keys.sorted(by: >), id: \.self) { dateKey in
                                    Section(header: Text(customDateFormatter.string(from: dateKey)).font(.headline)) {
                                        ForEach(
                                            (viewModel.groupedTasksByDate[dateKey] ?? [])
                                                .sorted { $0.scheduledAt ?? Date.distantPast < $1.scheduledAt ?? Date.distantPast }
                                        ) { task in
                                            TaskRow(task: task)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    selectedTask = task
                                                }
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    switch task.status {
                                                    case .scheduled:
                                                        Button(action: {
                                                            taskToCancel = task
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
                                                        
                                                    case .completed:
                                                        Button(action: {
                                                            taskToCancel = task
                                                            withAnimation {
                                                                showPopup = true
                                                            }
                                                        }) {
                                                            Image("cancel")
                                                            Text("Отменить")
                                                        }
                                                        .tint(Color.custom(.taskCanceledOrange))
                                                        
                                                        Button(action: {
                                                            viewModel.scheduleTask(task: task)
                                                            viewModel.loadTasks()
                                                        }) {
                                                            Image("inProgress")
                                                            Text("Запланировать")
                                                        }
                                                        .tint(Color.custom(.taskViewYellow))
                                                        
                                                    case .canceled:
                                                        Button(action: {
                                                            viewModel.scheduleTask(task: task)
                                                            viewModel.loadTasks()
                                                        }) {
                                                            Image("inProgress")
                                                            Text("Запланировать")
                                                        }
                                                        .tint(Color.custom(.taskViewYellow))
                                                        
                                                        Button(action: {
                                                            selectedTaskForComplete = task
                                                            showCompleteTaskView = true
                                                        }) {
                                                            Image("completed")
                                                            Text("Завершить")
                                                        }
                                                        .tint(Color.custom(.taskCompleteGreen))
                                                    }
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
                                                        selectedTaskForEdit = task
                                                        showEditTaskView = true
                                                    }) {
                                                        Image("edit")
                                                        Text("Редактировать")
                                                    }
                                                    .tint(Color.custom(.editButtonGray))
                                                }
                                        }
                                    }
                                    .id(dateKey)
                                    .listRowSeparator(.hidden)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.clear)
                                    )
                                }
                            }
                            .scrollPosition(id: $listScrollPosition)
                            .onChange(of: selectedDate) { newValue in
                                let target = dayKey(newValue)
                                let keys = Array(viewModel.groupedTasksByDate.keys)
                                
                                let destination = keys.contains(target)
                                           ? target
                                           : keys.min(by: { abs($0.timeIntervalSince(target)) < abs($1.timeIntervalSince(target)) })

                                       if let destination {
                                           withAnimation {
                                               proxy.scrollTo(destination, anchor: .top)
                                           }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .padding(.leading, -20)
                            .padding(.trailing, -20)
                            .navigationDestination(item: $selectedTask) { task in
                                TaskView(task: task)
                            }
                        }
                    }
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
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
                                    if let task = taskToCancel {
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
                                .frame(height: 42)
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
    }

    var body: some View {
        NavigationStack {
            mainContent
        }
        .sheet(isPresented: $showNewTaskView, onDismiss: {
            viewModel.loadTasks()
        }) {
            NewTaskView()
        }
        .sheet(item: $selectedTaskForEdit, onDismiss: {
            viewModel.loadTasks()
        }) { task in
            EditTaskView(viewModel: EditTaskViewModel(task: task))
        }
        .sheet(item: $selectedTaskForComplete, onDismiss: {
            viewModel.loadTasks()
        }) { task in
            CompleteTaskView(viewModel: CompleteTaskViewModel(task: task))
        }
        .onAppear {
            viewModel.loadTasks()
        }
        
        .onAppear {
            // При первом открытии — проскроллим к сегодняшнему дню, если есть секция
            let today = dayKey(Date())
            let keys = Array(viewModel.groupedTasksByDate.keys)
            if keys.contains(today) {
                listScrollPosition = today
            }
        }
    }
}

#Preview {
    TaskListView()
}
