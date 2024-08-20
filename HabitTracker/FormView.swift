//
//  AddingForm.swift
//  HabitTracker
//
//  Created by Martí Espinosa Farran on 2/7/24.
//

import SwiftUI

struct FormView: View {
    @Binding var dailyHabitList: DailyHabitList
    
    @State private var habitName = ""
    @State private var habitDescription = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                TextField("Habit Name", text: $habitName)
                TextField("Habit Description", text: $habitDescription)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal)
   
            VStack(spacing: 8) {
                HStack {
                    Text("Repeat")
                    
                    Spacer()
                    
                    Button("All days") {
                        
                    }
                }
                
                HStack {
                    ForEach(1..<8, id: \.self) { day in
                        Button(action: {
                            
                        }, label: {
                            Text("\(day)")
                                .padding(12)
                                .font(.title3)
                                .background(
                                    Circle()
                                        .foregroundStyle(.secondary)
                                )
                        })
                        .foregroundStyle(.primary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                if !habitName.isEmpty {
                    let currentDateKey = Date().formattedDateKey()
                    let newHabit = Habit(name: habitName, description: habitDescription, isCompleted: false)
                    
                    if var habitsForCurrentDate = dailyHabitList.habitsByDay[currentDateKey] {
                        habitsForCurrentDate.append(newHabit)
                        dailyHabitList.habitsByDay[currentDateKey] = habitsForCurrentDate
                    } else {
                        dailyHabitList.habitsByDay[currentDateKey] = [newHabit]
                    }
                    
                    if let habitsCount = dailyHabitList.habitsByDay[currentDateKey]?.count {
                        print("Número de hábitos para el día \(currentDateKey): \(habitsCount)")
                    } else {
                        print("No se encontraron hábitos para el día \(currentDateKey)")
                    }
                }
                
                dismiss()
            }, label: {
                Text("OK")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule()
                            .foregroundStyle(.green)
                    )
                    .padding(.horizontal)
            })
        }
        .padding()
        .padding(.top)
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
