//
//  SpendUpperBoundManager.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/23.
//

import Foundation

class SpendUpperBoundManager: ObservableObject {
    var monthUpperBound: Int = 0
    var weekUpperBound: Int = 0
    var dayUpperBound: Int = 0
    private let dayStr = "DayUpperBound"
    private let weekStr = "WeekUpperBound"
    private let monthStr = "MonthUpperBound"
    init() {
        _ = getMonthUpperBound()
        _ = getWeekUpperBound()
        _ = getDayUpperBound()
    }
    
    func getDayUpperBound() -> Int {
        if let upperBound = UserDefaults.standard.object(forKey: dayStr) as? Int {
            self.dayUpperBound = upperBound
        } else {
            UserDefaults.standard.setValue(200, forKey: dayStr)
            self.dayUpperBound = 200
        }
        return self.dayUpperBound
    }
    func getWeekUpperBound() -> Int {
        if let upperBound = UserDefaults.standard.object(forKey: weekStr) as? Int {
            self.weekUpperBound = upperBound
        } else {
            UserDefaults.standard.setValue(2000, forKey: weekStr)
            self.weekUpperBound = 2000
        }
        return self.weekUpperBound
    }
    func getMonthUpperBound() -> Int {
        if let upperBound = UserDefaults.standard.object(forKey: monthStr) as? Int {
            self.monthUpperBound = upperBound
        } else {
            UserDefaults.standard.setValue(8000, forKey: monthStr)
            self.monthUpperBound = 8000
        }
        return self.monthUpperBound
    }
    func setUpperBound(mode: settingGoatMode, value: Int) {
        if mode == .day {
            UserDefaults.standard.setValue(value, forKey: dayStr)
        }
        if mode == .week {
            UserDefaults.standard.setValue(value, forKey: weekStr)
        }
        if mode == .month {
            UserDefaults.standard.setValue(value, forKey: monthStr)
        }
    }
    static func checkIsInteger(strInput: String) -> Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: strInput).isSubset(of: digitsCharacters)
    }
}
