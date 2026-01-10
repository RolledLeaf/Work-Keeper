import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var isUploading = false
    @State private var showResultAlert = false
    @State private var resultMessage = ""
    @State private var logoutAlertIsPresented = false

    private var syncTrigger: SyncService.Trigger = .manual

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
            .buttonStyle(.borderedProminent)
            .disabled(isUploading)

            Spacer()
            
            Button {
                logoutAlertIsPresented = true
            } label: {
                HStack {
                    Text("Выйти")
                    Image(systemName: "rectangle.portrait.and.arrow.forward")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

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
            Button("Выйти и очистить данные", role: .destructive) {
                Task {
                    // purge local CoreData via handler set in App
                    auth.purgeLocalDataHandler?()
                    await auth.signOut()
                    dismiss()
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Локальные данные будут удалены с устройства, чтобы следующий пользователь не увидел ваши записи.")
        }
    }
}
