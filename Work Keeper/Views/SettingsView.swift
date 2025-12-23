import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var auth: AuthService

    @State private var isUploading = false
    @State private var showResultAlert = false
    @State private var resultMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Button("Pull (Supabase → CoreData)") {
                Task {
                    guard let ownerId = auth.session?.user.id else {
                        resultMessage = "Нет активной сессии. Сначала войди в аккаунт."
                        showResultAlert = true
                        return
                    }

                    isUploading = true
                    defer { isUploading = false }

                    let service = PullSyncService(context: context)
                    do {
                        try await service.run(ownerId: ownerId, debug: true)
                        resultMessage = "Pull завершён успешно."
                    } catch {
                        resultMessage = "Ошибка Pull: \(error.localizedDescription)"
                    }
                    showResultAlert = true
                }
            }
            .buttonStyle(.bordered)
            .disabled(isUploading)

            Button {
                Task {
                    guard let ownerId = auth.session?.user.id else {
                        resultMessage = "Нет активной сессии. Сначала войди в аккаунт."
                        showResultAlert = true
                        return
                    }

                    isUploading = true
                    defer { isUploading = false }

                    let service = InitialUploadService(context: context)
                    do {
                        try await service.run(ownerId: ownerId, debug: true)
                        resultMessage = "Initial Upload завершён успешно."
                    } catch {
                        resultMessage = "Ошибка Initial Upload: \(error.localizedDescription)"
                    }
                    showResultAlert = true
                }
            } label: {
                HStack {
                    if isUploading {
                        ProgressView()
                    }
                    Text(isUploading ? "Загрузка…" : "Initial Upload")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isUploading)

            Text("Initial Upload загружает локальные (оффлайн) данные в Supabase. Обычно достаточно выполнить один раз после включения облака. Pull — подтягивает данные из Supabase в CoreData.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

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
