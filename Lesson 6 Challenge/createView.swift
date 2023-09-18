import SwiftUI

struct createView: View {
    @Binding var todo: Task
    @State private var newDueDate = Date()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        List {
            Text("Task: \(todo.title)")
                .foregroundColor(.primary)
            DatePicker("Due Date", selection: $newDueDate, in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .onAppear {
                    newDueDate = todo.dueDate
                }
            Button("Update Due Date") {
                todo.dueDate = newDueDate
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .preferredColorScheme(.dark)
    }
}

struct createView_Previews: PreviewProvider {
    static var previews: some View {
        createView(todo: .constant(Task(title: "Hello", dueDate: Date())))
    }
}
