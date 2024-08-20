//
//  Habit.swift
//  HabitTracker
//
//  Created by Martí Espinosa Farran on 2/7/24.
//

import Foundation
import Observation

struct Habit: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var description: String
    var isCompleted = false
    var count = 0
}

@Observable class DailyHabitList {
    var habitsByDay = [String: [Habit]]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(habitsByDay) {
                UserDefaults.standard.set(encoded, forKey: "HabitsByDay")
            }
        }
    }
    
    init() {
        if let savedHabits = UserDefaults.standard.data(forKey: "HabitsByDay") {
            if let decodedHabits = try? JSONDecoder().decode([String: [Habit]].self, from: savedHabits) {
                habitsByDay = decodedHabits
                return
            }
        }
        habitsByDay = [:]
    }
    
    func habits(for day: String) -> [Habit] {
        return habitsByDay[day] ?? []
    }
    
    func setHabits(_ habits: [Habit], for day: Date) {
        let key = dayKey(for: day)
        habitsByDay[key] = habits
    }
    
    func dayKey(for day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: day)
    }
}
