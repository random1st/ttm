import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    let projects: [Project]
    let timerManager: TimerManager
    @Binding var showingAddProject: Bool
    @Binding var newProjectName: String

    var activeProjects: [Project] {
        projects.filter { !$0.isArchived }
    }

    var body: some View {
        VStack(spacing: 0) {
            if activeProjects.isEmpty {
                emptyState
            } else {
                projectsList
            }

            addProjectSection
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "timer")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            VStack(spacing: 4) {
                Text("No projects")
                    .font(.headline)
                Text("Add your first project below")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            showingAddProject = true
        }
    }

    private var projectsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(activeProjects.enumerated()), id: \.element.id) { index, project in
                    ProjectRowView(
                        project: project,
                        index: index < 9 ? index + 1 : nil,
                        timerManager: timerManager,
                        onDelete: { deleteProject(project) }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var addProjectSection: some View {
        VStack(spacing: 8) {
            Divider()

            if showingAddProject {
                HStack(spacing: 8) {
                    TextField("Project name", text: $newProjectName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addProject()
                        }

                    Button("Add") {
                        addProject()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newProjectName.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button {
                        showingAddProject = false
                        newProjectName = ""
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            } else {
                Button {
                    showingAddProject = true
                } label: {
                    Label("Add Project", systemImage: "plus.circle")
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
    }

    private func addProject() {
        let name = newProjectName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let colors = ["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#5856D6", "#AF52DE"]
        let color = colors.randomElement() ?? "#007AFF"

        let project = Project(name: name, colorHex: color)
        modelContext.insert(project)
        try? modelContext.save()

        newProjectName = ""
        showingAddProject = false
    }

    private func deleteProject(_ project: Project) {
        if timerManager.isRunning(project: project) {
            timerManager.stop(project: project, context: modelContext)
        }
        modelContext.delete(project)
        try? modelContext.save()
    }
}
