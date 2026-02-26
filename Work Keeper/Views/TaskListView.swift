import Foundation
import SwiftUI

private struct SectionHeaderOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

private struct TaskToastModel: Identifiable, Equatable {
    let id = UUID()
    let kind: TaskToastKind
    let description: String
    let finalAmount: Double?
}

// MARK: - Empty List Placeholder View
struct EmptyListPlaceholderView: View {
    struct HeadlineLine {
        let text: String
        let color: Color
        let font: Font
        let height: CGFloat
    }

    let line1: HeadlineLine
    let line2: HeadlineLine

    // Third line supports a bold suffix like "..."
    let line3Text: String
    let line3TextFont: Font
    let line3Suffix: String
    let line3SuffixFont: Font
    let line3Color: Color
    let line3Height: CGFloat

    let hintText: String

    // Layout tuning (kept as defaults matching current Tasks placeholder)
    var topPadding: CGFloat = 299
    var leadingPadding: CGFloat = 58
    var trailingPadding: CGFloat = 0
    var hintTopPadding: CGFloat = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(line1.text)
                    .foregroundStyle(line1.color)
                    .font(line1.font)
                Spacer()
            }
            .frame(height: line1.height)

            HStack {
                Text(line2.text)
                    .foregroundStyle(line2.color)
                    .font(line2.font)
                Spacer()
            }
            .frame(height: line2.height)

            HStack {
                (Text(line3Text)
                    .foregroundStyle(line3Color)
                    .font(line3TextFont)
                 +
                 Text(line3Suffix)
                    .foregroundStyle(line3Color)
                    .font(line3SuffixFont)
                )
                Spacer()
            }
            .frame(height: line3Height)

            HStack {
                Text(hintText)
                    .foregroundStyle(Color.custom(.pitchBlack))
                    .font(.custom(Montserrat.medium.rawValue, size: 12))
                Spacer()
            }
            .frame(height: 30)
            .padding(.top, hintTopPadding)

            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
    }
}


// MARK: - Filters

struct TasksFilterView: View {
    @Binding var selectedFilters: Set<TaskStatus>
    
    let allFilters: [TaskStatus] = [.scheduled, .completed, .canceled]
    
    var body: some View {
        VStack {
            List {
                ForEach(allFilters, id: \.self) { status in
                    HStack {
                        Text(status.rawValue)
                            .font(.custom(Montserrat.regular.rawValue, size: 14))
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
                   
//                    .contentShape(Rectangle())
                   
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
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @State private var selectedDate = Date()
    @State private var listScrollPosition: Date?
    @State private var showDeleteAlert = false
    @State private var showNewTaskView = false
    @State private var showCompleteTaskView = false
    @State private var showEditTaskView = false
    
    @State private var showSchedulePicker = false
    @State private var showScrollToTopButton = false
    @State private var showFilters = false
    @State private var showPopup = false
    @State private var navigateToTaskView = false
    @State private var isSpinning = false
    @State private var showDatePickerSheet = false
    @State private var toastPresented = false
    @State private var draftDate = Date()
    @State private var syncReloadTask: Task<Void, Never>? = nil
    @State private var taskToast: TaskToastModel? = nil
    
    @State private var headerBaselineMinY: CGFloat? = nil
    
    @State private var lastCompletedFinalAmount: Double = 0.0
    @State private var selectedTask: TaskEntity?
    @State private var selectedClient: Client?
    @State private var taskToCancel: TaskEntity?
    @State private var taskToDelete: TaskEntity?
    @State private var selectedTaskForSchedule: TaskEntity?
    @State private var selectedTaskForComplete: TaskEntity?
    @State private var selectedTaskForEdit: TaskEntity?
    // Keep a reference to the ScrollViewProxy for scroll actions
    @State private var scrollProxy: ScrollViewProxy? = nil
    // Height of the header overlay for top padding and blur overlay
    
    @Binding var pendingCreatedTaskToast: String?
    
    private let headerOverlayHeight: CGFloat = 110
    private var dynamicFraction: CGFloat {
        DeviceLayout.cardRadiusForFraction(for: UIScreen.main.bounds.width)
    }
    private let timing = 2.0
    private var cellGap: CGFloat {
        if #available(iOS 26, *) {
            return 5
        } else {
            return 10
        }
    }

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
    
    private func refreshScreen() {
        loadSavedStatuses()
        let today = dayKey(Date())
        let keys = Array(viewModel.groupedTasksByDate.keys)
        if keys.contains(today) {
            listScrollPosition = today
        }
    }
    
    private func openDatePicker() {
        draftDate = selectedDate
        showDatePickerSheet = true
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
    
    private func presentTaskToast(kind: TaskToastKind, description: String, finalAmount: Double? = nil) {
        let desc = description.isEmpty ? "Без названия" : description

        taskToast = TaskToastModel(kind: kind, description: desc, finalAmount: finalAmount)

        withAnimation(.spring(response: 0.35, dampingFraction: 1.25)) {
            toastPresented = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timing) {
            withAnimation(.easeOut(duration: 0.25)) {
                toastPresented = false
                taskToast = nil
            }
        }
    }

    @ViewBuilder
    private func mainContent(proxy: ScrollViewProxy) -> some View {
        ZStack {
            Color.custom(.mainBackground)
                .ignoresSafeArea()
            
            if viewModel.groupedTasksByDate.isEmpty {
                Image(ImageResource(name: "noTasksBackgroung", bundle: .main))
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            } else {
                Color.custom(.mainBackground).ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }
            }
            
            VStack {
  
                // MARK: - Placeholder or the List beginning
                
                if viewModel.groupedTasksByDate.isEmpty {
                    EmptyListPlaceholderView(
                        line1: .init(
                            text: viewModel.searchText.isBlank ? "ЗАДАНИЙ" : "НИЧЕГО",
                            color: Color.custom(.taskViewYellow),
                            font: .custom(Montserrat.black.rawValue, size: 38),
                            height: 27
                        ),
                        line2: .init(
                            text: viewModel.searchText.isBlank ? "ПОКА" : "НЕ",
                            color: Color.custom(.taskCompleteGreen),
                            font: .custom(Montserrat.bold.rawValue, size: 38),
                            height: 27
                        ),
                        line3Text: viewModel.searchText.isBlank ? "НЕТ" : "НАЙДЕНО",
                        line3TextFont: .custom(Montserrat.regular.rawValue, size: 38),
                        line3Suffix: "...",
                        line3SuffixFont: .custom(Montserrat.black.rawValue, size: 38),
                        line3Color: Color.custom(.taskCanceledOrange),
                        line3Height: 27,
                        hintText: viewModel.searchText.isBlank ? "Создайте карточку задания, нажав на \nиконку “+“ в середине нижней панели" : ""
                    )
                } else {
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
                                        .frame(height: 14)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 10)
                                    }
                                    .frame(height: 1)
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
                                       TaskRow(viewModel: viewModel, selectedClient: $selectedClient, task: task)
                                        .padding(.vertical, cellGap) // коррекция расстояния между ячейками

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
                        .safeAreaInset(edge: .top) {
                            Color.clear
                                .frame(height: headerOverlayHeight)
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
                        .onChange(of: selectedClient) { newValue in
                            if newValue != nil {
                                showScrollToTopButton = false
                            }
                        }
                }
            }
            
           
            
            if showPopup, let task = taskToCancel {
                CancelTaskPopup(task: task, isPresented: $showPopup) { description in
                    
                   
                    viewModel.loadTasks()
                    loadSavedStatuses()
                    presentTaskToast(kind: .canceled, description: description)
                    syncService.runManualSync(auth: auth, debug: true)
                }
            }
            
            if toastPresented {
                Rectangle()
                      .fill(.ultraThinMaterial)
                      .ignoresSafeArea()
                      .transition(.opacity)
                      .opacity(0.95)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            VStack {
                HStack {
                    
                    Button(action: {
                        showFilters = true
                    }) {
                        Image(filterIcon)
                            .resizable()
                            .frame(width: 21, height: 24)
                            .foregroundStyle(.pitchBlack)
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 5)
                    
                    Button(action: openDatePicker) {
                        Image("calendar")
                            .resizable()
                            .frame(width: 28.65, height: 25)
                            .foregroundStyle(.pitchBlack)
                    }
                
                    
                    Spacer()
                    
                    if !networkMonitor.isOnline {
                        HStack {
                            
                            Text("Нет сети, работа оффлайн")
                                .font(.custom(Montserrat.regular.rawValue, size: 11))
                                .foregroundColor(.secondary)
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 15)
                        
                    } else {
                        switch syncService.phase {
                        case .syncing:
                            HStack {
                                
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
                                
                                Text("синхронизировано")
                                    .font(.custom(Montserrat.regular.rawValue, size: 11))
                                Image("syncCompleted")
                                    .resizable()
                                    .frame(width: 13.55, height: 15)
                            }
                            .frame(height: 15)
                            
                        case .failure:
                            HStack {
                                
                                Text("ошибка синхронизации")
                                    .font(.custom(Montserrat.regular.rawValue, size: 11))
                                Image("syncError")
                                    .resizable()
                                    .frame(width: 13.55, height: 15)
                            }
                            .frame(height: 15)
                            
                        case .idle:
                            Spacer().frame(height: 15)
                        }
                    }
                    
                    Spacer()
  
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                
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
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(radius: 10, y: 6)
                    
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
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 50)
            .padding(.bottom, 10)
           
            
            .ignoresSafeArea(edges: .top)
            
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedTask) { task in
                TaskView(task: task)
            }
            .navigationDestination(item: $selectedClient) { client in
                ClientProfileView(client: client, onDismiss: { refreshScreen() })
            }
        }
        .onChange(of: syncService.phase) { newPhase in
            switch newPhase {
            case .syncing:
                isSpinning = true

            case .success:
                isSpinning = false

                // After a successful sync, re-apply current DB filters so UI reflects
                // remote changes (e.g., deletedAt applied during Pull).
                syncReloadTask?.cancel()
                syncReloadTask = Task { @MainActor in
                    // small delay to let CoreData saves settle (safe, avoids race)
                    try? await Task.sleep(nanoseconds: 150_000_000) // 0.15s
                    viewModel.applyCurrentFiltersUsingDB(debug: false)
                }

            default:
                isSpinning = false
            }
        }
        .onChange(of: viewModel.didScheduleTask) { newValue in
            if newValue {
                viewModel.loadTasks()
                let desc = viewModel.lastScheduledTaskDescription ?? "Без названия"
                presentTaskToast(kind: .scheduled, description: desc)
                viewModel.didScheduleTask = false
            }
            syncService.runManualSync(auth: auth, debug: true)
        }
        .overlay(alignment: .bottomTrailing) {
            if showScrollToTopButton {
                Button(action: {
                    let today = Date()
                    selectedDate = today
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
                if let toast = taskToast {
                    if let amount = toast.finalAmount {
                        TaskToastView(kind: toast.kind, taskDescription: toast.description, finalAmount: amount)
                    } else {
                        TaskToastView(kind: toast.kind, taskDescription: toast.description)
                    }
                }
            }
            .transition(.offset(y: 40).combined(with: .opacity))
        }
        
        .sheet(isPresented: $showDatePickerSheet) {
            NavigationStack {
                VStack(spacing: 8) {
                    DatePicker(
                        "",
                        selection: $draftDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .navigationTitle("Выберите дату")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { showDatePickerSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Готово") {
                            selectedDate = draftDate
                            showDatePickerSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.fraction(0.52)])
        }
        
        
        .onChange(of: pendingCreatedTaskToast) { newValue in
            guard let description = newValue, !description.isEmpty else { return }

            presentTaskToast(kind: .scheduled, description: description)
            pendingCreatedTaskToast = nil
            viewModel.loadTasks()
            loadSavedStatuses()
        }
        
        
        .sheet(item: $selectedTaskForEdit, onDismiss: {
            loadSavedStatuses()
        }) { task in
            EditTaskView(viewModel: EditTaskViewModel(task: task), onSave: { updatedDescription in
                presentTaskToast(kind: .edited, description: updatedDescription)
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
                // обновляем данные и запоминаем данные для тост
                viewModel.loadTasks()
                presentTaskToast(kind: .completed, description: taskDescription, finalAmount: finalAmount)
                syncService.runManualSync(auth: auth, debug: true)
            }
            .presentationDetents([.fraction(dynamicFraction)])
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
            .presentationDetents([.fraction(0.39)])
        }
        
        
        .onAppear {
           refreshScreen()
        }
        
        
        
        .alert("Вы уверены?",
               isPresented: $showDeleteAlert,
               presenting: taskToDelete
        ) { task in
            Button("Удалить", role: .destructive) {
                let desc = task.taskDescription ?? "Без названия"
                
                viewModel.delete(task)
                loadSavedStatuses()
                presentTaskToast(kind: .deleted, description: desc)
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
    TaskListView(pendingCreatedTaskToast: .constant(nil))
}


//ZStack {
//                      Image("calendar")
//                          .resizable()
//                          .frame(width: 33, height: 32)
//                          .ifAvailableButtonStyleGlass()
//
//                      DatePicker("",
//                                 selection: $selectedDate,
//                                 displayedComponents: .date
//                      )
//                      .labelsHidden()
//                      .datePickerStyle(.compact)
//                      .blendMode(.destinationOver)
//                      .frame(width: 30, height: 30)
//                      .contentShape(Rectangle())
//                  }
