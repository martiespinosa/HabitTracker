//
//  ContentView.swift
//  HabitTracker
//
//  Created by Martí Espinosa Farran on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var dailyHabitList = DailyHabitList()
    @State private var isShowingForm = false
    @State private var isShowingCalendar = false
    
    var body: some View {
        NavigationView {
            Group {
                if dailyHabitList.habits(for: dailyHabitList.dayKey(for: Date.now)).isEmpty {
                    ContentUnavailableView("No habits yet", systemImage: "gearshape.2.fill", description: Text("Tap the plus icon to add your first habit."))
                } else {
                    HabitListView(dailyHabitList: $dailyHabitList)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isShowingCalendar.toggle()
                    }, label: {
                        Image(systemName: "calendar")
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingForm.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.headline)
                    })
                }
            }
            .sheet(isPresented: $isShowingForm, content: {
                FormView(dailyHabitList: $dailyHabitList)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            })
            .sheet(isPresented: $isShowingCalendar, content: {
                CalendarView(dailyHabitList: $dailyHabitList)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            })
        }
        .onAppear {
            printHabitsKeys()
        }
    }
    
    func printHabitsKeys() {
        print("Habits by day keys: \(dailyHabitList.habitsByDay.keys)")
    }
}

struct HabitListView: View {
    @Binding var dailyHabitList: DailyHabitList
    
    private var todayHabits: [Habit] {
        let currentDateKey = Date().formattedDateKey()
        return dailyHabitList.habits(for: currentDateKey)
    }
    
    var body: some View {
        List {
            ForEach(todayHabits) { habit in
                HStack {
                    Button {
                        if let index = todayHabits.firstIndex(where: { $0.id == habit.id }) {
                            dailyHabitList.habitsByDay[dailyHabitList.dayKey(for: Date.now)]?[index].isCompleted.toggle()
                        }
                    } label: {
                        Image(systemName: habit.isCompleted ? "circle.inset.filled" : "circle")
                    }
                    .padding(.leading, -8)
                    
                    Text(habit.name)
                }
                .listRowBackground(habit.isCompleted ? Color.accentColor.opacity(0.3) : Color.secondary.opacity(0.3))
            }
            .onDelete { indices in
                dailyHabitList.habitsByDay[dailyHabitList.dayKey(for: Date.now)]?.remove(atOffsets: indices)
            }
        }
    }
}

#Preview {
    ContentView()
}
