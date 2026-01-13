import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var isUploading = false
    @State private var showResultAlert = false
    @State private var resultMessage = ""

    @State private var logoutAlertIsPresented = false
    @State private var hasPendingUnsyncedChanges = false
    @State private var pendingUnsyncedCount: Int = 0

    @State private var syncFailedLogoutConfirmIsPresented = false
    @State private var syncFailedMessage = ""

    private var syncTrigger: SyncService.Trigger = .manual

    private func countPendingUnsyncedChanges() async -> Int {
        await context.perform {
            func count(_ entityName: String) -> Int {
                let req = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                req.predicate = NSPredicate(format: "needsSync == YES")
                return (try? context.count(for: req)) ?? 0
            }

            // Adjust entity names if yours differ in the Core Data model.
            let entityNames = ["TaskEntity", "Client", "Address", "Street"]
            return entityNames.reduce(0) { $0 + count($1) }
        }
    }

    private func presentLogoutAlert() {
        Task {
            let c = await countPendingUnsyncedChanges()
            pendingUnsyncedCount = c
            hasPendingUnsyncedChanges = c > 0
            logoutAlertIsPresented = true
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            Button {
                Task {
                    guard let ownerId = auth.userId else {
                        resultMessage = "Нет активной сессии. Сначала войди в аккаунт."
                        showResultAlert = true
                        return
                    }

                    isUploading = true
                    defer { isUploading = false }

                    let sync = SyncService(context: context)
                    await sync.syncAll(ownerId: ownerId, trigger: syncTrigger, debug: true)

                    switch sync.phase {
                    case .success:
                        resultMessage = "Синхронизация завершена успешно."
                    case .failure(let msg):
                        resultMessage = "Ошибка синхронизации: \(msg)"
                    default:
                        resultMessage = ""
                    }

                    showResultAlert = true
                }
            } label: {
                HStack {
                    if isUploading { ProgressView() }
                    Text(isUploading ? "Синхронизация…" : "Sync All")
                }
                .frame(maxWidth: .infinity)
            }
           
            .ifAvailableButtonStyleGlass()
            .disabled(isUploading)

            Spacer()
            
            
            if let email = auth.userEmail {
                Text("\(email)")
                    .font(.custom(Montserrat.regular.rawValue, size: 12))
            }
            
                Button {
                    presentLogoutAlert()
                } label: {
                    HStack {
                        Text("Выйти")
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                    }
                    .frame(maxWidth: .infinity)
                }
                .foregroundStyle(Color.custom(.deleteButtonRed))
                .ifAvailableButtonStyleGlass()
            

            Spacer()
        }
        .padding()
        .navigationTitle("Настройки")
        .alert("Синхронизация", isPresented: $showResultAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
        .alert("Выйти из профиля?", isPresented: $logoutAlertIsPresented) {
            if hasPendingUnsyncedChanges {
                Button("Синхронизировать и выйти") {
                    Task {
                        guard let ownerId = auth.userId else {
                            auth.purgeLocalDataHandler?()
                            await auth.signOut()
                            dismiss()
                            return
                        }

                        isUploading = true
                        defer { isUploading = false }

                        let sync = SyncService(context: context)
                        await sync.syncAll(ownerId: ownerId, trigger: .manual, debug: true)

                        switch sync.phase {
                        case .success:
                            // Sync succeeded -> safe to logout & purge.
                            auth.purgeLocalDataHandler?()
                            await auth.signOut()
                            dismiss()

                        case .failure(let msg):
                            // Ask the user whether to logout anyway.
                            syncFailedMessage = msg
                            syncFailedLogoutConfirmIsPresented = true

                        default:
                            // If phase is neither success nor failure, treat as failure.
                            syncFailedMessage = "Синхронизация не завершилась."
                            syncFailedLogoutConfirmIsPresented = true
                        }
                    }
                }

                Button("Выйти без синхронизации", role: .destructive) {
                    Task {
                        auth.purgeLocalDataHandler?()
                        await auth.signOut()
                        dismiss()
                    }
                }

                Button("Отмена", role: .cancel) { }
            } else {
                Button("Выйти и очистить данные", role: .destructive) {
                    Task {
                        auth.purgeLocalDataHandler?()
                        await auth.signOut()
                        dismiss()
                    }
                }
                Button("Отмена", role: .cancel) { }
            }
        } message: {
            if hasPendingUnsyncedChanges {
                Text("Есть несинхронизированные изменения (\(pendingUnsyncedCount)). При выходе локальные данные будут удалены. Синхронизировать перед выходом?")
            } else {
                Text("Локальные данные будут удалены с устройства, чтобы следующий пользователь не увидел ваши записи.")
            }
        }
        .alert("Синхронизация не удалась", isPresented: $syncFailedLogoutConfirmIsPresented) {
            Button("Выйти без синхронизации", role: .destructive) {
                Task {
                    auth.purgeLocalDataHandler?()
                    await auth.signOut()
                    dismiss()
                }
            }
            Button("Остаться", role: .cancel) { }
        } message: {
            Text("Ошибка синхронизации: \(syncFailedMessage)\n\nЕсли выйти сейчас, несинхронизированные изменения могут быть потеряны.")
        }
    }
}
