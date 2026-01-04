import Foundation
import SwiftUI

private struct SectionHeaderOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}


// MARK: - Filters

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
    // MARK: - Properties
    @StateObject private var viewModel = TaskListViewModel()
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var auth: AuthService
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
    @State private var isSpinning = false
    @State private var headerBaselineMinY: CGFloat? = nil
    @State private var lastCompletedTaskDescription: String = ""
    @State private var lastCanceledTaskDescription: String = ""
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
       
        let all: Set<Status> = [.scheduled, .completed, .canceled]
        
           let selectedSet: Set<Status>
           if let statuses = viewModel.selectedStatuses, !statuses.isEmpty {
               selectedSet = Set(statuses)
           } else {
               selectedSet = all
           }

        if selectedSet == all {
            return .init(name: "filterAll", bundle: .main)
        }

        if selectedSet == [.scheduled] {
            return .init(name: "filterScheduled", bundle: .main)
        }

        if selectedSet == [.completed] {
            return .init(name: "filterCompleted", bundle: .main)
        }

        if selectedSet == [.canceled] {
            return .init(name: "filterCanceled", bundle: .main)
        }

        if selectedSet == [.completed, .canceled] {
            return .init(name: "filterCompletedCanceled", bundle: .main)
        }
        
        if selectedSet == [.scheduled, .canceled] {
            return .init(name: "filterScheduledCanceled", bundle: .main)
        }
        
       
            return .init(name: "filterScheduledCompleted", bundle: .main)
    
    
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
            
            if viewModel.groupedTasksByDate.isEmpty {
                Image(ImageResource(name: "noTasksBackgroung", bundle: .main))
                      .resizable()
                      .scaledToFit()
                      .opacity(0.03)
            } else {
                Color.custom(.mainBackground).ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }
            }
            
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
                .frame(height: 30)
                .padding(.leading, 3)
           
                HStack {
                    HStack {
                        Image("magnifyingGlass")
                        .resizable()
                        .frame(width: 21, height: 21)
                        .foregroundColor(Color.custom(.pitchBlack))
                        .padding(.leading, 20)
                    
                    TextField("Поиск задания", text: $viewModel.searchText)
                            .font(.custom(Montserrat.regular.rawValue, size: 16))
                        .onChange(of: viewModel.searchText) { newValue in
                            print("[TaskListView] searchText changed:", newValue)
                        }
                        .onSubmit {
                            hideKeyboard()
                        }
                        
                    
                    Button(action:  {
                        viewModel.searchText = ""
                        
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 18, height: 18)
                        
                    }
                    .opacity(viewModel.searchText.isEmpty ? 0 : 1)
                    .padding(.trailing, 15)
                }
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.custom(.searchFieldGray))
                        )
                    .ifAvailableGlassStyle(in: .capsule, interactive: true)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action:  {
                            viewModel.searchText = ""
                            hideKeyboard()
                        }) {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 45, height: 45)
                                .foregroundStyle(Color.custom(.pitchBlack))
                        }
                    }
                }
                
                switch syncService.phase {
                case .syncing:
                    HStack {
                        Spacer()
                        Text("синхронизация")
                            .font(.custom(Montserrat.regular.rawValue, size: 11))
                        Image("sync")
                            .resizable()
                            .frame(width: 13.55, height: 15)
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isSpinning)
                            .onAppear { isSpinning = true }
                            .onDisappear { isSpinning = false }
                    }
                    .frame(height: 15)

                case .success:
                    HStack {
                        Spacer()
                        Text("синхронизировано")
                            .font(.custom(Montserrat.regular.rawValue, size: 11))
                        Image("syncCompleted")
                            .resizable()
                            .frame(width: 13.55, height: 15)
                    }
                    .frame(height: 15)

                case .failure:
                    HStack {
                        Spacer()
                        Text("ошибка синхронизации")
                            .font(.custom(Montserrat.regular.rawValue, size: 11))
                        Image("syncError")
                            .resizable()
                            .frame(width: 13.55, height: 15)
                    }
                    .frame(height: 15)

                case .idle:
                    // Keep layout stable (optional). Remove this Spacer if you prefer the UI to collapse.
                    Spacer().frame(height: 15)
                }
                
               
                
                // MARK: - Placeholder or the List beginning
                
                if viewModel.groupedTasksByDate.isEmpty {
       
                    VStack {
                        
                        HStack {
                            Text("ЗАДАНИЙ")
                                .foregroundStyle(Color.custom(.taskViewYellow))
                                .font(.custom(Montserrat.black.rawValue, size: 38))
                            
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .frame(height: 27)
                        
                        HStack {
                            Text("ПОКА")
                                .foregroundStyle(Color.custom(.taskCompleteGreen))
                                .font(.custom(Montserrat.bold.rawValue, size: 38))
                            
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .frame(height: 27)
                        
                        HStack {
                            Text("НЕТ")
                                .foregroundStyle(Color.custom(.taskCanceledOrange))
                                .font(.custom(Montserrat.regular.rawValue, size: 38))
                            +
                            Text("...")
                                .foregroundStyle(Color.custom(.taskCanceledOrange))
                                .font(.custom(Montserrat.black.rawValue, size: 38))
                            Spacer()
                        }
                        .frame(height: 27)
                        .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text("Создайте карточку задания, нажав на \nиконку “+“ в правом верхнем углу экрана")
                                .foregroundStyle(Color.custom(.pitchBlack))
                                .font(.custom(Montserrat.medium.rawValue, size: 12))
                                .multilineTextAlignment(.leading)
                        }
                        .frame(height: 30)
                        .padding(.top, 18)
                        Spacer()
                    }
                    .padding(.top, 192)
                    .padding(.leading, 58)
                    .padding(.trailing, 30)
                
                    
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
                                            
                                            (
                                                Text(customDateFormatter.string(from: dateKey))
                                                    .font(.custom(Montserrat.regular.rawValue, size: 14))
                                                    .foregroundStyle(Color.custom(.pitchBlack))
                                                +
                                                {
                                                    if dateKey == today {
                                                        return Text(" • Сегодня")
                                                            .font(.custom(Montserrat.bold.rawValue, size: 14))
                                                            .foregroundStyle(.pitchBlack)
                                                    } else if dateKey == yesterday {
                                                        return Text(" • Вчера")
                                                            .font(.custom(Montserrat.regular.rawValue, size: 14))
                                                            .foregroundStyle(.pitchBlack)
                                                    } else if dateKey == tomorrow {
                                                        return Text(" • Завтра")
                                                            .font(.custom(Montserrat.regular.rawValue, size: 14))
                                                            .foregroundStyle(.pitchBlack)
                                                    } else {
                                                        return Text("") // без хвоста
                                                    }
                                                }()
                                            )
                                            Spacer()
                                            Text("\(viewModel.calculateDailyIncome(for: dateKey).formattedCurrency())")
                                                .font(.custom(Montserrat.bold.rawValue, size: 17))
                                                .foregroundStyle(viewModel.calculateDailyIncome(for: dateKey) > 0 ? Color.custom(.pitchBlack) : Color.custom(.taskTextGray))
                                            +
                                            Text(" ₽")
                                                .font(.custom(Montserrat.regular.rawValue, size: 17))
                                                .foregroundStyle(.pitchBlack)
                                            
                                               
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
                                        .padding(.vertical, 6) // коррекция расстояния между ячейками
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
                                                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                }
                                                .tint(Color.custom(.pureWhite))
                                                
                                                Button(action: {
                                                    selectedTaskForComplete = task
                                                    showCompleteTaskView = true
                                                }) {
                                                    Image("completed")
                                                    Text("Завершить")
                                                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                }
                                                .tint(Color.custom(.pureWhite))
                                                
                                            case .completed:
                                                Button(action: {
                                                    taskToCancel = task
                                                    withAnimation {
                                                        showPopup = true
                                                    }
                                                }) {
                                                    Image("cancel")
                                                    Text("Отменить")
                                                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                }
                                                .tint(Color.custom(.pureWhite))
                                                
                                                Button(action: {
                                                    selectedTaskForSchedule = task
                                                    showSchedulePicker = true
                                                }) {
                                                    Image("inProgress")
                                                    Text("Переназначить")
                                                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                }
                                                .tint(Color.custom(.pureWhite))
                                                
                                            case .canceled:
                                                Button(action: {
                                                    selectedTaskForSchedule = task
                                                    showSchedulePicker = true
                                                }) {
                                                    Image("inProgress")
                                                    Text("Переназначить")
                                                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                }
                                                .tint(Color.custom(.pureWhite))
                                                
                                                Button(action: {
                                                    selectedTaskForComplete = task
                                                    showCompleteTaskView = true
                                                }) {
                                                    Image("completed")
                                                    Text("Завершить")
                                                        .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                }
                                                .tint(Color.custom(.pureWhite))
                                            }
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button(action: {
                                                taskToDelete = task
                                                showDeleteAlert = true
                                            }) {
                                                Image("delete")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                Text("Удалить")
                                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                    .foregroundStyle(Color.red)
                                            }
                                            .tint(Color.custom(.pureWhite))
                                            
                                            
                                            Button(action: {
                                                selectedTaskForEdit = task
                                                showEditTaskView = true
                                            }) {
                                                Image("edit")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                Text("Изменить")
                                                    .font(.custom(Montserrat.regular.rawValue, size: 12))
                                                    .foregroundStyle(Color.custom(.pitchBlack))
                                            }
                                            .tint(Color.custom(.pureWhite))
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
            .padding(.trailing, 17)
            .padding(.leading, 16)
            
            if showPopup, let task = taskToCancel {
                CancelTaskPopup(task: task, isPresented: $showPopup) { description in
                    
                    lastCanceledTaskDescription = description
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
                    syncService.runManualSync(auth: auth, debug: true)
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
        .onChange(of: syncService.phase) { newPhase in
            switch newPhase {
            case .syncing:
                isSpinning = true
            default:
                isSpinning = false
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
                syncService.runManualSync(auth: auth, debug: true)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if showScrollToTopButton {
                Button(action: {
                    selectedDate = Date()
                }) {
                    Image("arrowUp")
                        .resizable()
                        .frame(width: 35, height: 20)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
                .transition(.scale.combined(with: .opacity))
                .opacity(viewModel.groupedTasksByDate.isEmpty ? 0.0 : 1.0)
                .ifAvailableButtonStyleGlass()
            }
        }
        
        .overlay(alignment: .center) {
            Group {
                if showCancelTaskNotification {
                    CancelTaskConfirmationView(taskDescription: $lastCanceledTaskDescription)
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

                syncService.runManualSync(auth: auth, debug: true)
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
                syncService.runManualSync(auth: auth, debug: true)
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
                syncService.runManualSync(auth: auth, debug: true)
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
                syncService.runManualSync(auth: auth, debug: true)
                
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


