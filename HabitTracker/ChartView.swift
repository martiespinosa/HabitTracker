//
//  ChartView.swift
//  HabitTracker
//
//  Created by Martí Espinosa Farran on 5/7/24.
//

import SwiftUI
import Charts
 
struct PieSlice: Identifiable {
    let id = UUID()
    let value: Double
    let label: String
    let color = Color.accentColor
}

struct ChartView: View {
    let habitsForDay: [Habit]
    
    var body: some View {
        if !habitsForDay.isEmpty {
            Chart {
                ForEach(createSlices()) { slice in
                    SectorMark(
                        angle: .value("Habit", slice.value),
                        innerRadius: .ratio(0.8)
                    )
                    .foregroundStyle(by: .value("Type", slice.label))
                    .cornerRadius(allHabitsCompleted ? 0 : 100)
                }
            }
            .chartLegend(.hidden)
            .chartForegroundStyleScale([
                "Completed": Color.green,
                "Incomplete": Color.clear
            ])
        }
    }
    
    private var allHabitsCompleted: Bool {
        return habitsForDay.allSatisfy { $0.isCompleted }
    }
    
    func createSlices() -> [PieSlice] {
        guard !habitsForDay.isEmpty else {
            return [
                PieSlice(value: 100, label: "No Data")
            ]
        }
        
        let totalHabits = habitsForDay.count
        let completedHabits = habitsForDay.filter { $0.isCompleted }.count
        let incompleteHabits = totalHabits - completedHabits
        
        let completedPercentage = Double(completedHabits) / Double(totalHabits) * 100
        let incompletePercentage = Double(incompleteHabits) / Double(totalHabits) * 100
        
        return [
            PieSlice(value: completedPercentage, label: "Completed"),
            PieSlice(value: incompletePercentage, label: "Incomplete")
        ]
    }
}

#Preview {
    @State var sampleHabitList = DailyHabitList()
    sampleHabitList.setHabits([
        Habit(name: "Read", description: "Read for 30 minutes", isCompleted: true),
        Habit(name: "Exercise", description: "Workout for 1 hour", isCompleted: false),
        Habit(name: "Meditate", description: "Meditate for 10 minutes", isCompleted: true)
    ], for: Date.now)
    
    return CalendarView(dailyHabitList: $sampleHabitList)
}
