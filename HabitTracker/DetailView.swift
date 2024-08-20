//
//  DetailView.swift
//  HabitTracker
//
//  Created by Martí Espinosa Farran on 2/7/24.
//

import SwiftUI

struct DetailView: View {
    var habit: Habit
    @Binding var dailyHabitList: DailyHabitList
    
    @State private var count = 0
    
    var body: some View {
        VStack(alignment: .leading){
            Text(habit.description)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text("\(count)")
                .fontDesign(.rounded)
                .font(.system(size: 100)).bold()
                .frame(maxWidth: .infinity)
                .contentTransition(.numericText(value: Double(count)))
            
            Spacer()
            
            Button(action: {
//                if let index = habitList.habits.firstIndex(of: habit) {
//                    var updatedHabit = habitList.habits[index]
//                    updatedHabit.count += 1
//                    habitList.habits[index] = updatedHabit
//                }
                
                withAnimation {
                    count += 1
                }
            }, label: {
                Text("Increment One")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .foregroundStyle(.green)
                    )
                    .padding()
                    .padding(.horizontal)
            })
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle(habit.name)
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
