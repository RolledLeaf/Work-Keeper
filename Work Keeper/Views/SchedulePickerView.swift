import SwiftUI

struct SchedulePickerView: View {
    @Binding var isPresented: Bool
    @State private var selectedDate: Date
    let minimumDate: Date
    let onAssign: (Date) -> Void
    @Environment(\.dismiss)
    private var dismiss

    init(isPresented: Binding<Bool>, initialDate: Date = Date(), minimumDate: Date = Date(), onAssign: @escaping (Date) -> Void) {
        self._isPresented = isPresented
        self._selectedDate = State(initialValue: initialDate)
        self.minimumDate = minimumDate
        self.onAssign = onAssign
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Выберите дату и время")
                    .font(.custom(SFPro.bold.rawValue, size: 19))
                    .padding(.top, 8)

                DatePicker("",
                           selection: $selectedDate,
                           in: minimumDate...,
                           displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .onAppear {
                        UIDatePicker.appearance().minuteInterval = 5
                    }
                    .labelsHidden()
                    .padding(.horizontal)

                Spacer()

                HStack(spacing: 12) {
                    Button("Отмена") {
                        withAnimation { dismiss() }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.custom(.scheduleCancelButton))
                    .cornerRadius(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.custom(.taskTextGray).opacity(0.3), lineWidth: 1)
                    )

                    Button(action: {
                        onAssign(selectedDate)
                        withAnimation { dismiss() }
                    }) {
                        Text("Назначить")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .disabled(selectedDate < minimumDate)
                    .background(selectedDate < minimumDate ? Color.gray.opacity(0.5) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top)
            .navigationBarHidden(true)
        }
    }
}
