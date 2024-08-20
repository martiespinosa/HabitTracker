//
//  CalendarView.swift
//  HabitTracker
//
//  Created by Martí Espinosa Farran on 3/7/24.
//

import SwiftUI

struct CalendarView: View {
    @Binding var dailyHabitList: DailyHabitList
    
    @State private var date = Date.now
    @State var daySelected = Date.now
    @State private var sheetSize: SheetSize = .medium
    
    var body: some View {
        ScrollViewReader { value in
            VStack(spacing: 0) {
                HStack {
                    Button("Filter") {
                        
                    }
                    .tint(.primary)
                    
                    Spacer()
                    
                    Button("Today") {
                        withAnimation {
                            daySelected = Date.now
                            withAnimation {
                                let currentMonth = Calendar.current.component(.month, from: Date.now)
                                value.scrollTo(currentMonth)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(.regularMaterial)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(1...Calendar.current.component(.month, from: Date.now), id: \.self) { month in
                            let monthStart = Date(year: date.year, month: month)
                            MonthView(monthStart: monthStart, dailyHabitList: $dailyHabitList, daySelected: $daySelected)
                                .containerRelativeFrame(.vertical, alignment: .top)
                                .id(month)
                        }
                    }
                }
                .ignoresSafeArea()
                .scrollTargetLayout()
                .scrollTargetBehavior(.paging)
                .scrollBounceBehavior(.basedOnSize)
                .defaultScrollAnchor(.bottom)

                if sheetSize == .large {
                    DayView(daySelected: $daySelected, dailyHabitList: $dailyHabitList)
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            updateSheetSize(for: geometry.size.height)
                        }
                        .onChange(of: geometry.size.height) { oldSize, newSize in
                            updateSheetSize(for: newSize)
                        }
                }
            )
        }
    }
    
    private func updateSheetSize(for height: CGFloat) {
        if height > 500 {
            sheetSize = .large
        } else {
            sheetSize = .medium
        }
    }
    
    enum SheetSize {
        case medium
        case large
    }
}

struct MonthView: View {
    let monthStart: Date
    let calendar = Calendar.current
    
    @Binding var dailyHabitList: DailyHabitList
    @Binding var daySelected: Date
    
    @State private var daysInMonth: [Day] = []
    
    var body: some View {
        LazyVStack {
            Text(monthStart.formatted(.dateTime.month().year(.twoDigits)))
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach($daysInMonth) { $day in
                    if let date = day.date, calendar.isDate(date, equalTo: monthStart, toGranularity: .month) {
                        Button(action: {
                            daySelected = date
                        }, label: {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.headline)
                                .foregroundStyle(calendar.isDate(Date.now, inSameDayAs: date) ? .accent : .primary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    ZStack {
                                        if calendar.isDate(daySelected, inSameDayAs: date) {
                                            Circle()
                                                .foregroundColor(.secondary.opacity(0.5))
                                        }
                                        
                                        ChartView(habitsForDay: dailyHabitList.habits(for: formattedDate(for: date)))
                                    }
                                )
                        })
                        .tint(.primary)
                    } else {
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
            }
            .frame(height: CGFloat(weeksInMonth()) * 50)
        }
        .padding()
        .onAppear {
            daysInMonth = generateDaysInMonth()
        }
    }
    
    private func generateDaysInMonth() -> [Day] {
        var days = [Day]()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart))!
        
        let weekday = calendar.component(.weekday, from: startOfMonth)
        let emptyDaysCount = (weekday - calendar.firstWeekday + 7) % 7
        
        for _ in 0..<emptyDaysCount {
            days.append(Day(date: nil, dailyHabitList: dailyHabitList))
        }
        
        let numberOfDays = calendar.range(of: .day, in: .month, for: startOfMonth)!.count
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                days.append(Day(date: date, dailyHabitList: dailyHabitList))
            }
        }
        
        return days
    }
    
    private func weeksInMonth() -> Int {
        let range = calendar.range(of: .weekOfMonth, in: .month, for: monthStart)
        return range?.count ?? 5
    }
    
    private func formattedDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct DayView: View {
    @Binding var daySelected: Date
    @Binding var dailyHabitList: DailyHabitList
    
    private var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: daySelected)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading) {
                Text("\(daySelected.formatted(date: .abbreviated, time: .omitted))")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(daySelected.formatted(Date.FormatStyle().weekday(.wide)))")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading) {
                let habits = dailyHabitList.habits(for: dayKey)
                if !habits.isEmpty {
                    ForEach(habits) { habit in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(habit.isCompleted ? .accent.opacity(0.5) : .secondary.opacity(0.5))
                            
                            Text(habit.name)
                                
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                } else {
                    Text("No habits for this day.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.regularMaterial)
    }
}

struct Day: Identifiable {
    let id = UUID()
    let date: Date?
    let dailyHabitList: DailyHabitList
    
    init(date: Date?, dailyHabitList: DailyHabitList) {
        self.date = date
        self.dailyHabitList = dailyHabitList
    }
}

extension Date {
    init(year: Int, month: Int) {
        self = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    func formattedDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
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
