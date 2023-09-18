import SwiftUI
import SwiftPersistence

struct Task: Hashable, Identifiable, Codable {
    var title: String
    var id = UUID()
    var dueDate: Date
}

struct ContentView: View {
    @State var dueDate = Date()
    @State var addNew = false
    @State var taskName = ""
    @Persistent("listOfTodos") var listOfTodos: [Task] = []
    @State private var scrollOffset: CGFloat = 0
    @State private var taskToDelete: Task?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let titleOffset = min(0, -scrollOffset)
                List {
                    ForEach($listOfTodos) { $todo in
                        NavigationLink(destination: createView(todo: $todo)) {
                            VStack(alignment: .leading) {
                                Text(todo.title)
                                Text("Due: \(todo.dueDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(action: {
                                taskToDelete = todo
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
                .offset(y: titleOffset + 10)
                .onPreferenceChange(TitleOffsetPreferenceKey.self) { offset in
                    scrollOffset = offset
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: TitleOffsetPreferenceKey.self,
                            value: proxy.frame(in: .global).minY
                        )
                    }
                )
            }
            .navigationBarTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        Button {
                            addNew.toggle()
                        } label: {
                            Text("Create New Task")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addNew) {
                List {
                    TextField("Input task", text: $taskName)
                    DatePicker(selection: $dueDate, in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!..., label: { Text("Due Date") })
                        .datePickerStyle(GraphicalDatePickerStyle())
                    Button {
                        listOfTodos.append(Task(title: taskName, dueDate: dueDate))
                        taskName = ""
                    } label: {
                        Text("Create")
                    }
                }
                .preferredColorScheme(.dark)
            }
            .alert(item: $taskToDelete) { task in
                Alert(
                    title: Text("Delete Task"),
                    message: Text("Are you sure you want to delete this task?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let index = listOfTodos.firstIndex(where: { $0.id == task.id }) {
                            listOfTodos.remove(at: index)
                        }
                        taskToDelete = nil
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TitleOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
