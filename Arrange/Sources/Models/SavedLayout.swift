import Foundation

struct SavedLayout: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var preset: LayoutPreset
    var slots: [Slot]

    struct Slot: Codable {
        let col: Int
        let app: Int
        let bundleId: String
        let appName: String
    }
}
