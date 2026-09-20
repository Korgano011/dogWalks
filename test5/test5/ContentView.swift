import SwiftUI
import Playgrounds

struct SavedWalk: Codable, Identifiable {
    var id = UUID()
    let walk: String
    let date: Date
}

struct ContentView: View {
    
    @State private var selectedWalk = "Morning"
    
    let walks = ["Morning", "Afternoon", "Evening"]
    @State private var day = Date()
    @AppStorage("savedWalks") private var savedWalksData = Data()
    @State private var savedWalks: [SavedWalk] = []
    @State private var showDuplicateAlert = false
    
    var body: some View {
        ScrollView {
        VStack(spacing: 20) {
            Image("quinnie")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .shadow(radius: 4)
            Text("Select walk")
            Picker("Select a walk", selection: $selectedWalk) {
                
                ForEach(walks, id: \.self) { walk in
                    Text(walk)
                    
                }
            }
            DatePicker("Walk date", selection: $day, displayedComponents: .date)
            Text("You need to take Quinn for the \(selectedWalk.lowercased()) walk on:")
            Text(day.formatted(date: .complete, time: .omitted))
                .font(.headline)

            Button("Save walk") {
                let isDuplicate = savedWalks.contains {
                    $0.walk == selectedWalk && Calendar.current.isDate($0.date, inSameDayAs: day)
                }
                if isDuplicate {
                    showDuplicateAlert = true
                    return
                }
                savedWalks.append(SavedWalk(walk: selectedWalk, date: day))
                savedWalks.sort { $0.date < $1.date }
                persist()
            }
            .buttonStyle(.borderedProminent)

            if !savedWalks.isEmpty {
                Divider()
                Text("Saved walks")
                    .font(.title3.bold())
                ForEach(savedWalks) { saved in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(saved.date.formatted(date: .complete, time: .omitted))
                            Text(saved.walk)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            savedWalks.removeAll { $0.id == saved.id }
                            persist()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .padding()
        }
        .alert("Already saved", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The \(selectedWalk.lowercased()) walk on \(day.formatted(date: .abbreviated, time: .omitted)) is already in your list.")
        }
        .onAppear {
            savedWalks = (try? JSONDecoder().decode([SavedWalk].self, from: savedWalksData)) ?? []
        }

    }

    private func persist() {
        savedWalksData = (try? JSONEncoder().encode(savedWalks)) ?? Data()
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
