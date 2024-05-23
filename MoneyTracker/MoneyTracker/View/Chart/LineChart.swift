//
//  CostToChart.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import SwiftUI
import Charts

struct LineChart: View {
    @Binding var accountingListBaseDay: [costBaseDay]
    @Binding var accountingListBaseWeek: [costBaseWeek]
    @Binding var accountingListBaseMonth: [costBaseMonth]
    @State var mode: costViewMode
    @State var showData: [Bool] = Array(repeating: true, count: 7)
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter.string(from: date)
    }
    var body: some View {
        if mode == .day {
            
            Chart {
                ForEach(0..<accountingListBaseDay.count, id: \.self) {
                    day in
                    
                    
                    LineMark(
                        x: .value("day,month,year", returnDateStr(date: Calendar.current.date(from: accountingListBaseDay[day].dayMonthYear)!)),
                        y: .value("cost", accountingListBaseDay[day].cost)
                    )
                    
                }
            }
            
            
//            .onAppear {
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        showData[counter] = true
//                        }
//                }
//            }
//            .onChange(of: accountingListBaseDay) { _ in
//                showData = Array(repeating: false, count: 7)
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        showData[counter] = true
//                        }
//                }
//            }
        }
        if mode == .week {
            Chart {
                ForEach(0..<accountingListBaseWeek.count, id: \.self) {
                    week in
                    let combineStr = returnDateStr(date: Calendar.current.date(from: accountingListBaseWeek[week].weekLowerBoundYear)!) + "-\n" + returnDateStr(date: Calendar.current.date(from: accountingListBaseWeek[week].weekUpperBoundYear)!)
                    if showData[week] {
                        LineMark(
                            x: .value("day,month,year", combineStr),
                            y: .value("cost", accountingListBaseWeek[week].cost)
                        )
                    }
                }
            }
//            .onChange(of: accountingListBaseWeek) { _ in
//                showData = Array(repeating: false, count: 7)
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        showData[counter] = true
//                        }
//                }
//            }
//            .onAppear {
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        showData[counter] = true
//                        }
//                }
//            }
        }
        if mode == .month {
            Chart {
                ForEach(0..<accountingListBaseMonth.count, id: \.self) {
                    month in
                    let combineStr = returnDateStr(date: Calendar.current.date(from: accountingListBaseMonth[month].monthYear)!)
                    if showData[month] {
                        LineMark(
                            x: .value("month,year", combineStr),
                            y: .value("cost", accountingListBaseMonth[month].cost)
                        )
                    }
                }
            }
//            .onChange(of: accountingListBaseMonth) { _ in
//                showData = Array(repeating: false, count: 7)
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        showData[counter] = true
//                        }
//                }
//            }
//            .onAppear {
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        showData[counter] = true
//                        }
//                }
//            }
        }
        
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(accountingListBaseDay: .constant([]), accountingListBaseWeek: .constant([]), accountingListBaseMonth: .constant([]), mode: .day)
    }
}


