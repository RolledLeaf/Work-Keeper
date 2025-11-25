import Foundation
import SwiftUI

private struct SectionHeaderOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

struct TasksFilterView: View {
    @Binding var selectedFilters: Set<TaskStatus>
    
    let allFilters: [TaskStatus] = [.scheduled, .completed, .canceled]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    selectedFilters = [.scheduled, .completed, .canceled]
                }) {
                    Text("Выбрать все")
                        .padding(.trailing, 6)
                }
            }
            
            
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
                        
                        
                        // Toggle the tapped status
                        if selectedFilters.contains(status) {
                            selectedFilters.remove(status)
                        } else {
                            selectedFilters.insert(status)
                        }
                        
                        // If nothing remains selected, fall back to .all
                        if selectedFilters.isEmpty {
                            selectedFilters = [.scheduled, .completed, .canceled]
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Фильтры")
            .padding(.top, 8)
        }
    }
}

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
  
    @State private var selectedDate = Date()
    @State private var listScrollPosition: Date?
    @State private var showDeleteAlert = false
    @State private var showNewTaskView = false
    @State private var showCompleteTaskView = false
    @State private var showEditTaskView = false
    @State private var showCompleteTaskNotification = false
    @State private var showCancelTaskNotification = false
    @State private var showScheduleTaskNotification = false
    @State private var showDeleteTaskNotification = false
    @State private var showEditTaskNotification = false
    @State private var showSchedulePicker = false
    @State private var showScrollToTopButton = false
    @State private var showFilters = false
    @State private var showPopup = false
    @State private var navigateToTaskView = false
    @State private var headerBaselineMinY: CGFloat? = nil
    @State private var lastCompletedTaskDescription: String = ""
    @State private var lastCanceletedTaskDescription: String = ""
    @State private var lastScheduleTaskDescription: String = ""
    @State private var lastDeletedTaskDescription: String = ""
    @State private var lastEditedTaskDescription: String = ""
    @State private var lastCompletedFinalAmount: Double = 0.0
    @State private var selectedTask: TaskEntity?
    @State private var taskToCancel: TaskEntity?
    @State private var taskToDelete: TaskEntity?
    @State private var selectedTaskForSchedule: TaskEntity?
    @State private var selectedTaskForComplete: TaskEntity?
    @State private var selectedTaskForEdit: TaskEntity?
    // Keep a reference to the ScrollViewProxy for scroll actions
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    private var filterIcon: ImageResource {
        // полный набор фильтров
        let all: Set<TaskStatus> = [.scheduled, .completed, .canceled]
        let selected = viewModel.selectedFilters

        // Примеры названий ассетов — подставь свои реальные:
        // filterAll, filterScheduled, filterCompleted, filterCanceled, filterMixed

        if selected == all {
            return .init(name: "filterAll", bundle: .main)      // ничего не отфильтровано
        }

        if selected == [.scheduled] {
            return .init(name: "filterScheduled", bundle: .main)
        }

        if selected == [.completed] {
            return .init(name: "filterCompleted", bundle: .main)
        }

        if selected == [.canceled] {
            return .init(name: "filterCanceled", bundle: .main)
        }

        if selected == [.completed, .canceled] {
            return .init(name: "filterCompletedCanceled", bundle: .main)
        }
        
        if selected == [.scheduled, .canceled] {
            return .init(name: "filterScheduledCanceled", bundle: .main)
        }
        
        if selected == [.scheduled, .completed] {
            return .init(name: "filterScheduledCompleted", bundle: .main)
        }
        
        return .init(name: "filterMixed", bundle: .main)
    }
   
    let customDateFormatter: DateFormatter = DateFormatter.taskDateFormatter
    
    private func dayKey(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    private func loadSavedStatuses() {
        if let saved = viewModel.loadSavedStatusesFromUserDefaults(key: UserDefaultsKeys.tasksFilter.rawValue) {
            viewModel.selectedStatuses = saved
            
            // Обновляем UI-множетсво TaskStatus для чекбоксов
            viewModel.selectedFilters = Set(saved.map { viewModel.statusToTaskStatus($0) })
        } else {
            viewModel.selectedFilters = [.scheduled, .completed, .canceled]
            viewModel.selectedStatuses = nil
        }
    }

    func scrollToTop() {
        guard let proxy = scrollProxy else { return }
        let today = dayKey(Date())
        withAnimation {
            proxy.scrollTo(today, anchor: .top)
        }
    }
    
    func scrollToToday() {
       selectedDate = Date()
    }
    
 
    
 
    
    @ViewBuilder
    private func mainContent(proxy: ScrollViewProxy) -> some View {
        ZStack {
            Color.custom(.mainBackground).ignoresSafeArea()
                .onTapGesture { hideKeyboard() }
            
            VStack {
                HStack {
 
                    Button(action: {
                        showFilters = true
                    }) {
                        Image(filterIcon)
                            .font(.system(size: 30, weight: .regular))
                            .foregroundStyle(.pitchBlack)
                            .ifAvailableButtonStyleGlass()
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 5)
                    
                    ZStack {
                        Image("calendar")
                            .frame(width: 30, height: 30)
                            .ifAvailableButtonStyleGlass()
                        
                        DatePicker("",
                                   selection: $selectedDate,
                                   displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .blendMode(.destinationOver)
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showNewTaskView = true
                    }) {
                        Image("plus")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.pitchBlack)
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
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                        
                    }
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
                        List {
                            ForEach(viewModel.groupedTasksByDate.keys.sorted(by: >), id: \.self) { dateKey in
                                Section(header:
                                    ZStack {
                                        HStack {
                                            let today = dayKey(Date())
                                            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
                                            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
                                            
                                            Text(customDateFormatter.string(from: dateKey)).font(.custom(Montserrat.regular.rawValue, size: 14))
                                                .foregroundStyle(Color.custom(.pitchBlack))
                                            if dateKey == today {
                                                
                                                Text("• Сегодня")
                                                    .font(.custom(Montserrat.bold.rawValue, size: 14))
                                                    .foregroundStyle(.pitchBlack)
                                            } else if dateKey == yesterday {
                                                Text("• Вчера")
                                                    .font(.custom(Montserrat.regular.rawValue, size: 14))
                                                    .foregroundStyle(.pitchBlack)
                                            } else if dateKey == tomorrow {
                                                Text("• Завтра")
                                                    .font(.custom(Montserrat.regular.rawValue, size: 14))
                                                    .foregroundStyle(.pitchBlack)
                                            }
                                            Spacer()
                                            Text("\(viewModel.calculateDailyIncome(for: dateKey).formattedCurrency())")
                                                .font(.custom(Montserrat.bold.rawValue, size: 17))
                                                .foregroundStyle(viewModel.calculateDailyIncome(for: dateKey) > 0 ? Color.custom(.pitchBlack) : Color.custom(.taskTextGray))
                                        }
                                        .frame(height: 17)
                                    }
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .preference(key: SectionHeaderOffsetKey.self,
                                                            value: geo.frame(in: .named("taskList")).minY)
                                        }
                                    )
                                ) {
                                    ForEach(
                                        (viewModel.groupedTasksByDate[dateKey] ?? [])
                                            .sorted { $0.scheduledAt ?? Date.distantPast < $1.scheduledAt ?? Date.distantPast }
                                    ) { task in
                                        TaskRow(viewModel: viewModel, task: task
                                        )
                                        
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedTask = task
                                            showScrollToTopButton = false
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
                                                    selectedTaskForSchedule = task
                                                    showSchedulePicker = true
                                                }) {
                                                    Image("inProgress")
                                                    Text("Запланировать")
                                                }
                                                .tint(Color.custom(.taskViewYellow))
                                                
                                            case .canceled:
                                                Button(action: {
                                                    selectedTaskForSchedule = task
                                                    showSchedulePicker = true
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
                            .listRowBackground(Color.custom(.mainBackground))
                        }
                        
                        .coordinateSpace(name: "taskList")
                        .scrollPosition(id: $listScrollPosition)
                        .onPreferenceChange(SectionHeaderOffsetKey.self) { minY in
                            print("[TaskListView] topAnchor minY:", minY)

                            // Initialize baseline on first measurement
                            if headerBaselineMinY == nil {
                                headerBaselineMinY = minY
                                print("[TaskListView] baselineHeaderMinY set to", headerBaselineMinY ?? 0)
                            }

                            let baseline = headerBaselineMinY ?? minY
                            let delta = baseline - minY // >0 when user scrolled down

                          
                            let todayKey = dayKey(Date())
                            let selectedKey = dayKey(selectedDate)
                            let isSelectedToday = selectedKey == todayKey

                            // threshold in points — tune empirically
                            let threshold: CGFloat = 400
                            let scrolledDownEnough = delta > threshold

                            if !isSelectedToday || scrolledDownEnough {
                                withAnimation(.easeInOut) { showScrollToTopButton = true }
                            } else {
                                withAnimation(.easeInOut) { showScrollToTopButton = false }
                            }
                        }
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
                        .listRowSpacing(6)
                        .listStyle(PlainListStyle())
                        .padding(.leading, -16)
                        .padding(.trailing, -17)
                        .navigationDestination(item: $selectedTask) { task in
                            TaskView(task: task)
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
                    
                    lastCanceletedTaskDescription = description
                    viewModel.loadTasks()
                    loadSavedStatuses()
                    
                    
                    withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                        showCancelTaskNotification = true
                    }
                    
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
            ScrollViewReader { proxy in
                mainContent(proxy: proxy)
                    .onAppear {
                        self.scrollProxy = proxy
                    }
            }
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
        .overlay(alignment: .bottomTrailing) {
            if showScrollToTopButton {
                Button(action: {
                    selectedDate = Date()
                }) {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
                .transition(.scale.combined(with: .opacity))
                .ifAvailableButtonStyleGlass()
            }
        }
        
        .overlay(alignment: .center) {
            Group {
                if showCancelTaskNotification {
                    CancelTaskConfirmationView(taskDescription: $lastCanceletedTaskDescription)
                        .transition(.offset(y: 40).combined(with: .opacity))
                } else if showDeleteTaskNotification {
                    DeleteTaskConfirmationView(taskDescription: $lastDeletedTaskDescription)
                        .transition(.offset(y: 40).combined(with: .opacity))
                } else if showEditTaskNotification {
                    EditTaskConfirmationView(taskDescription: $lastEditedTaskDescription)
                        .transition(.offset(y: 40).combined(with: .opacity))
                } else if showCompleteTaskNotification {
                    CompleteTaskConfirmationView(taskDescription: $lastCompletedTaskDescription, finalAmount: $lastCompletedFinalAmount)
                        .transition(.offset(y: 40).combined(with: .opacity))
                } else if showScheduleTaskNotification {
                    ScheduleTaskConfirmationView(taskDescription: $lastScheduleTaskDescription)
                        .transition(.offset(y: 40).combined(with: .opacity))
                }
            }
        }
        
        
        
        .sheet(isPresented: $showNewTaskView, onDismiss: {
            loadSavedStatuses()
        }) {
            NewTaskView(onComplete: { description in
                // тут получаем объект новой задачи
                lastScheduleTaskDescription = description
                
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showScheduleTaskNotification = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showScheduleTaskNotification = false
                    }
                }
                
                viewModel.loadTasks()
            })
        }
        
        
        .sheet(item: $selectedTaskForEdit, onDismiss: {
            loadSavedStatuses()
        }) { task in
            EditTaskView(viewModel: EditTaskViewModel(task: task), onSave: { updatedDescription in
                lastEditedTaskDescription = updatedDescription
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showEditTaskNotification = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showEditTaskNotification = false
                    }
                }
            })
        }
        
        .sheet(item: $selectedTaskForSchedule, onDismiss: {
            loadSavedStatuses()
        }) { task in
            SchedulePickerView(isPresented: .constant(true),
                               initialDate: task.scheduledAt ?? Date(),
                               minimumDate: Date()) { chosenDate in
                viewModel.scheduleTask(task, at: chosenDate)
            }
                               .presentationDetents([.fraction(0.25)])
        }
        
        .sheet(item: $selectedTaskForComplete, onDismiss: {
            loadSavedStatuses()
        }) { task in
            CompleteTaskView(viewModel: CompleteTaskViewModel(task: task)) { taskDescription, finalAmount in
                // обновляем данные и запоминаем данные для тоста
                viewModel.loadTasks()
                //                loadSavedStatuses()
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
                TasksFilterView(selectedFilters: $viewModel.selectedFilters)
                    .navigationTitle("Фильтры")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Готово") {
                                let collected = viewModel.selectedFilters.flatMap { viewModel.taskStatusToStatus($0) }
                                // Убираем дубликаты
                                let unique = Array(Set(collected))
                                print("[Filters] Выбраны статусы (raw):", unique.map { $0.rawValue })
                                
                                UserDefaults.standard.set(unique.map { $0.rawValue }, forKey: UserDefaultsKeys.tasksFilter.rawValue)
                                if let saved = UserDefaults.standard.array(forKey: UserDefaultsKeys.tasksFilter.rawValue) as? [String] {
                                    print("[Filters] Сохранено в UserDefaults:", saved)
                                }
                                
                                let allSet: Set<TaskStatus> = [.scheduled, .completed, .canceled]
                                let isAllSelected = viewModel.selectedFilters == allSet
                                
                                // Для VM: если пользователь явно выбрал все — ставим nil (нет фильтра)
                                let statusesForVM: [Status]? = isAllSelected ? nil : (unique.isEmpty ? nil : unique)
                                
                                // Apply filter and close
                                viewModel.selectedStatuses = statusesForVM
                                showFilters = false
                            }
                        }
                    }
                    .presentationDragIndicator(.visible)
            }
            .presentationDetents([.fraction(0.45)])
        }
        
        
        .onAppear {
            
            loadSavedStatuses()
            
            // Скролл к сегодняшнему (оставляем как есть)
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
                let desc = task.taskDescription ?? "Без названия"
                
                
                lastDeletedTaskDescription = desc
                viewModel.delete(task)
                loadSavedStatuses()
                
                
                withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
                    showDeleteTaskNotification = true
                }
                // Автоскрытие
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showDeleteTaskNotification = false
                    }
                }
                
            }
            Button("Отмена", role: .cancel) {
                loadSavedStatuses()
            }
        } message: { task in
            Text("Задание «\(task.taskDescription ?? "Без названия")» будет удалено безвозвратно.")
        }
    }
}

#Preview {
    TaskListView()
}


