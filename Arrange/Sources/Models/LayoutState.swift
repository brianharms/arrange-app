import Foundation
import Observation

@Observable
class LayoutState {
    var preset: LayoutPreset
    private var undoStack: [LayoutPreset] = []

    init(preset: LayoutPreset) {
        self.preset = preset
    }

    var canUndo: Bool {
        !undoStack.isEmpty
    }

    func pushUndo() {
        undoStack.append(preset)
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
    }

    @discardableResult
    func undo() -> Bool {
        guard let previous = undoStack.popLast() else { return false }
        preset = previous
        return true
    }

    func reset(to preset: LayoutPreset) {
        pushUndo()
        self.preset = preset
    }
}
