import Foundation
import SwiftUI



let customDateFormatter: DateFormatter = DateFormatter.taskDateFormatter

private func dayKey(_ date: Date) -> Date {
    Calendar.current.startOfDay(for: date)
}



struct TasksFilterView: View {
    @Binding var selectedFilters: Set<TaskStatus>

    let allFilters: [TaskStatus] = [.all, .scheduled, .completed, .canceled]

    var body: some View {
        List {
            ForEach(allFilters, id: \.self) { status in
                HStack {
                    Text(status.rawValue)
                    Spacer()

                    
                    let statusColor: Color = {
                        switch status {
                        case .scheduled: return Color.custom(.taskViewYellow)
                        case .completed: return Color.custom(.taskCompleteGreen)
                        case .canceled: return Color.custom(.taskCanceledOrange)
                        case .all: return Color.black
                        }
                    }()

                    if selectedFilters.contains(status) {
                        Image(systemName: "checkmark.square")
                            .resizable()
                            .foregroundColor(statusColor)
                            .frame(width: 22, height: 22)
                            .padding(.trailing, 8)
                    } else {
                        Image(systemName: "square")
                            .resizable()
                            .foregroundColor(statusColor.opacity(0.5))
                            .frame(width: 22, height: 22)
                            .padding(.trailing, 8)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Ensure .all behaves as a pseudo-status: when .all is selected,
                    // no other statuses can be combined. When any real status is selected,
                    // .all is removed.
                    if status == .all {
                        // Tapping "Все" selects only it
                        selectedFilters = [.all]
                        return
                    }

                    // For real statuses: remove .all if present
                    if selectedFilters.contains(.all) {
                        selectedFilters.remove(.all)
                    }

                    // Toggle the tapped status
                    if selectedFilters.contains(status) {
                        selectedFilters.remove(status)
                    } else {
                        selectedFilters.insert(status)
                    }

                    // If nothing remains selected, fall back to .all
                    if selectedFilters.isEmpty {
                        selectedFilters = [.all]
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Фильтры")
    }
}

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
   

  
    @State private var selectedDate = Date()
    @State private var showDeleteAlert = false
    @State private var showNewTaskView = false
    @State private var showCompleteTaskView = false
    @State private var showEditTaskView = false
    @State private var showCompleteTaskNotification = false
    @State private var showCancelTaskNotification = false
    @State private var showScheduleTaskNotification: Bool = false
    @State private var lastCompletedTaskDescription: String = ""
    @State private var lastCanceletedTaskDescription: String = ""
    @State private var lastScheduleTaskDescription: String = ""
    @State private var lastCompletedFinalAmount: Double = 0.0
    
    @State private var showFilters = false
    @State private var selectedFilters: Set<TaskStatus> = [.all]
    
    @State private var showPopup = false
    @State private var selectedTask: TaskEntity?
    @State private var taskToCancel: TaskEntity?
    @State private var taskToDelete: TaskEntity?
    @State private var navigateToTaskView = false

    @State private var selectedTaskForComplete: TaskEntity?
    @State private var selectedTaskForEdit: TaskEntity?
    @State private var listScrollPosition: Date?
    

    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            Color(.white).edgesIgnoringSafeArea(.all)
                .onTapGesture { hideKeyboard() }

            VStack {
                HStack {
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Image("today")
                            .resizable()
                            .frame(width: 38, height: 38)
                    }

                    Button(action: {
                        showFilters = true
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

                HStack {
                    TextField("Поиск задания", text: $viewModel.searchText)
                        .onChange(of: viewModel.searchText) { newValue in
                            print("[TaskListView] searchText changed:", newValue)
                        }
                        .padding(9)
                        .padding(.leading, 25)
                        .onSubmit {
                            hideKeyboard()
                        }
                        .background(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Spacer()
                                
                                
                            }
                                .padding(.horizontal, 10)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.custom(.searchFieldGray))
                        )
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action:  {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        
                    }
                }
                 
                 Text("Статусы заданий")
                 
                 HStack(spacing: 8) {
                      Rectangle()
                           .frame(width: 15, height: 15)
                           .foregroundColor(Color.custom(.taskCompleteGreen))
                      
                      Text("- выполнено")
                           .font(.custom(SFPro.regular.rawValue, size: 14))
                           
                      
                      Rectangle()
                           .frame(width: 15, height: 15)
                           .foregroundColor(Color.custom(.taskViewYellow))
                      
                      Text("- запланировано")
                           .font(.custom(SFPro.regular.rawValue, size: 14))
                           
                      
                      Rectangle()
                           .frame(width: 15, height: 15)
                           .foregroundColor(Color.custom(.taskCanceledOrange))
                      
                      Text("- отменено")
                           .font(.custom(SFPro.regular.rawValue, size: 14))
                 }

                if viewModel.groupedTasksByDate.isEmpty {
                  
                    VStack {
                        Image("noTasksPlaceholder")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .frame(width: 266, height: 273)
                            .padding(.leading, 65)
                        
                        Text("Заданий пока нет")
                            .font(.custom(SFPro.regular.rawValue, size: 24))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()
                } else {
                    Spacer()
                        .frame(height: 20)
                    NavigationStack {
                        ScrollViewReader { proxy in
                            List {
                                ForEach(viewModel.groupedTasksByDate.keys.sorted(by: >), id: \.self) { dateKey in
                                    Section(header: Text(customDateFormatter.string(from: dateKey)).font(.headline)) {
                                        ForEach(
                                            (viewModel.groupedTasksByDate[dateKey] ?? [])
                                                .sorted { $0.scheduledAt ?? Date.distantPast < $1.scheduledAt ?? Date.distantPast }
                                        ) { task in
                                            TaskRow(viewModel: viewModel, task: task
                                            )
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
                                                            viewModel.scheduleTask(task)

                                                        }) {
                                                            Image("inProgress")
                                                            Text("Запланировать")
                                                        }
                                                        .tint(Color.custom(.taskViewYellow))
                                                        
                                                    case .canceled:
                                                        Button(action: {
                                                            viewModel.scheduleTask(task: task)
                                                            viewModel.loadTasks()
                                                            viewModel.scheduleTask(task)

                                                            
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
                                                        taskToDelete = task
                                                        showDeleteAlert = true
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

            if showPopup, let task = taskToCancel {
                CancelTaskPopup(task: task, isPresented: $showPopup) { description in
                    // callback: обновляем локальные данные и показываем тост
                    lastCanceletedTaskDescription = description
                    viewModel.loadTasks() // обновляем список (если нужно)

                    // Показываем тост с анимацией
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                        showCancelTaskNotification = true
                    }
                    // Автоскрытие
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            showCancelTaskNotification = false
                        }
                    }
                }
            }
        }
        

       
    }

    var body: some View {
        NavigationStack {
            mainContent
        }
        .onChange(of: viewModel.didScheduleTask) { newValue in
            if newValue {
                viewModel.loadTasks()
                lastScheduleTaskDescription = viewModel.lastScheduledTaskDescription ?? "Без названия"
                withAnimation { showScheduleTaskNotification = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showScheduleTaskNotification = false }
                    viewModel.didScheduleTask = false
                }
            }
        }
        
        .overlay(alignment: .center) {
            if showCancelTaskNotification {
                CancelTaskNotificationView(taskDescription: $lastCanceletedTaskDescription)
                    .transition(.offset(y: 40).combined(with: .opacity))
            }
        }
        
        .overlay(alignment: .center) {
            if showCompleteTaskNotification {
                CompleteTaskNotificationView(taskDescription: $lastCompletedTaskDescription, finalAmount: $lastCompletedFinalAmount)
                    .transition(.offset(y: 40).combined(with: .opacity))
            }
        }
        
        .overlay(alignment: .center) {
            if showScheduleTaskNotification {
                ScheduleTaskNotificationView(taskDescription: $lastScheduleTaskDescription)
                    .transition(.offset(y: 40).combined(with: .opacity))
            }
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
            CompleteTaskView(viewModel: CompleteTaskViewModel(task: task)) { taskDescription, finalAmount in
                // обновляем данные и запоминаем данные для тоста
                viewModel.loadTasks()
                lastCompletedTaskDescription = taskDescription
                lastCompletedFinalAmount = finalAmount

                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showCompleteTaskNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showCompleteTaskNotification = false
                    }
                }
            }
        }
        .popover(isPresented: $showFilters) {
            NavigationStack {
                TasksFilterView(selectedFilters: $selectedFilters)
                    .navigationTitle("Фильтры")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Готово") {
                                // Build array of Status (or nil) from selectedFilters and apply to VM
                                let statuses: [Status]? = {
                                    // If .all is selected -> no status filter (nil)
                                    if selectedFilters.contains(.all) {
                                        return nil
                                    }
                                    var arr: [Status] = []
                                    for ts in selectedFilters {
                                        switch ts {
                                        case .scheduled:
                                            arr.append(.scheduled)
                                        case .completed:
                                            arr.append(.completed)
                                        case .canceled:
                                            arr.append(.canceled)
                                        case .all:
                                            break
                                        }
                                    }
                                    return arr.isEmpty ? nil : arr
                                }()

                                // Apply filter and close
                                viewModel.selectedStatuses = statuses
                                showFilters = false
                            }
                        }
                    }
            }
            .presentationDetents([.fraction(0.45)])
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
        .alert("Вы уверены?",
               isPresented: $showDeleteAlert,
               presenting: taskToDelete
        ) { task in
            Button("Удалить", role: .destructive) {
                viewModel.delete(task)
            }
            Button("Отмена", role: .cancel) { }
        } message: { task in
            Text("Задание «\(task.taskDescription ?? "Без названия")» будет удалено безвозвратно.")
        }
    }
}


struct TaskColoredLegend: View {
     var body: some View {
          VStack {
               
               Text("Статусы заданий")
               
               HStack(spacing: 8) {
                    Rectangle()
                         .frame(width: 15, height: 15)
                         .foregroundColor(Color.custom(.taskCompleteGreen))
                    
                    Text("- выполнено")
                         .font(.custom(SFPro.regular.rawValue, size: 14))
                         
                    
                    Rectangle()
                         .frame(width: 15, height: 15)
                         .foregroundColor(Color.custom(.taskViewYellow))
                    
                    Text("- назначено")
                         .font(.custom(SFPro.regular.rawValue, size: 14))
                         
                    
                    Rectangle()
                         .frame(width: 15, height: 15)
                         .foregroundColor(Color.custom(.taskCanceledOrange))
                    
                    Text("- отменено")
                         .font(.custom(SFPro.regular.rawValue, size: 14))
               }
          }
     }
}

#Preview {
    TaskListView()
}


