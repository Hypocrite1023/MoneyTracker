//
//  OperateDayViewModel.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import Foundation

class OperateDay: ObservableObject {
    @Published var showCostInDayDate : Date = Date.now
    @Published var selectDeleteID : UUID = UUID()
    @Published var dayCostUpperBound: Int = 200
    @Published var percent : Double = 0
    @Published var showData: [Bool] = Array(repeating: true, count: 7)
    
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        return dateFormatter.string(from: date)
    }
}
