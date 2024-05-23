//
//  OperateWeekViewModel.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import Foundation

class OperateWeek: ObservableObject {
    @Published var showCostInDayDate : Date = Date.now
    @Published var selectDeleteID : UUID = UUID()
    @Published var weekCostUpperBound: Int = 2000
    @Published var percent : Double = 0
    @Published var showData: [Bool] = Array(repeating: false, count: 7)
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter.string(from: date)
    }
}
