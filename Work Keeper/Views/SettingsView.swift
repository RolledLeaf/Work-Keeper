import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var auth: AuthService

    @State private var isUploading = false
    @State private var showResultAlert = false
    @State private var resultMessage = ""
    private var syncTrigger: SyncService.Trigger = .manual

    var body: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    guard let ownerId = auth.session?.user.id else {
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
                    if isUploading {
                        ProgressView()
                    }
                    Text(isUploading ? "Синхронизация…" : "Sync All")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isUploading)

            Spacer()
        }
        .padding()
        .navigationTitle("Настройки")
        .alert("Синхронизация", isPresented: $showResultAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(resultMessage)
        }
    }
}
