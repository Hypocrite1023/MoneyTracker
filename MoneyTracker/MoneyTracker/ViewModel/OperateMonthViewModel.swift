//
//  OperateMonthViewModel.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import Foundation

class OperateMonth: ObservableObject {
    @Published var showCostInDayDate : Date = Date.now
    @Published var selectDeleteID : UUID = UUID()
    @Published var monthCostUpperBound: Int = 8000
    @Published var percent : Double = 0
    @Published var showData: [Bool] = Array(repeating: false, count: 7)
    @Published var yearMonthSelected = Calendar.current.dateComponents(in: .current, from: .now).year!*100 + Calendar.current.dateComponents(in: .current, from: .now).month!
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM"
        return dateFormatter.string(from: date)
    }
    
}
