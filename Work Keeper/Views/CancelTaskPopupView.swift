
import SwiftUI

struct CancelTaskPopup: View {
    let task: TaskEntity
    @Binding var isPresented: Bool
    var onCancel: (String) -> Void
    
    private let maxCommentCharactersCount: Int = 300
    @State private var commentTextOpacity: Double = 0

    @StateObject private var vm: CancelTaskViewModel

    init(task: TaskEntity, isPresented: Binding<Bool>, onCancel: @escaping (String) -> Void) {
        self._vm = StateObject(wrappedValue: CancelTaskViewModel(task: task))
        self._isPresented = isPresented
        self.onCancel = onCancel
        self.task = task
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
              
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 40))
                    Text("Вы уверены, что хотите отменить задание?")
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                }
                Text("Его статус изменится на отменённый, итоговая сумма обнулится")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                TextEditor(text: $vm.comment)
                    .frame(height: 90)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    .onChange(of: vm.comment) { newValue in
                        if newValue.count > maxCommentCharactersCount {
                            vm.comment = String(newValue.prefix(maxCommentCharactersCount))
                        }
                        if vm.comment.count >= maxCommentCharactersCount {
                            commentTextOpacity = 1
                        } else {
                            commentTextOpacity = 0
                        }
                    }

                HStack {
                    Button("Нет") { isPresented = false }
                        .frame(width: 120, height: 44)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                    Button("Отменить задание") {
                        vm.cancel()
                        let desc = task.taskDescription ?? "Без названия"
                        onCancel(desc)
                        // закроем попап — родитель сможет показать тост при обработке onCancel
                        isPresented = false
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .padding(24)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
