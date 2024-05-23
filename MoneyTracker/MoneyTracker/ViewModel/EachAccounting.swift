//
//  EachAccounting.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import Foundation
import SwiftUI

class EachAccountingViewModel: ObservableObject {
    @Published var eachAccountingList : [eachAccounting] = [eachAccounting]() {
        didSet {
            saveRecord()
        }
    }
    @Published var costThisDay: Int = 0
    @Published var costThisWeek: Int = 0
    @Published var costThisMonth: Int = 0
    @Published var costByMonth: [costBaseMonth] = [costBaseMonth]()
    @Published var costByDay: [costBaseDay] = [costBaseDay]()
    @Published var costByWeek: [costBaseWeek] = [costBaseWeek]()
    
    @Published var accounting: [Accounting] = [] {
        didSet {
            print(accounting)
        }
    }
    static let accountingManager = EachAccountingViewModel()
    func generateWeekYear(dateNow: Date) {
        self.costByWeek = [costBaseWeek]()
        // list past seven weeks
        let dateInWeek = dateNow
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: dateInWeek)
//        print(dayOfWeek)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: dateInWeek)!
//        print(weekdays)
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: dateInWeek) }
        let lowerComponent = Calendar.current.dateComponents(in: .current, from: days[0])
        let upperComponent = Calendar.current.dateComponents(in: .current, from: days[6])
        costByWeek.insert(costBaseWeek(weekLowerBoundYear: lowerComponent, weekUpperBoundYear: upperComponent, cost: 0), at: 0)
        for _ in 0..<6 {
            let lowerDate = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: costByWeek[0].weekLowerBoundYear)!)!
            let upperDate = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: costByWeek[0].weekUpperBoundYear)!)!
            let lowerDateComponent = Calendar.current.dateComponents(in: .current, from: lowerDate)
            let upperDateComponent = Calendar.current.dateComponents(in: .current, from: upperDate)
            costByWeek.insert(costBaseWeek(weekLowerBoundYear: lowerDateComponent, weekUpperBoundYear: upperDateComponent, cost: 0), at: 0)
        }
//        print(costByWeek)
    }
    
    func computeCostByWeekYear(dateNow: Date) {
        generateWeekYear(dateNow: dateNow)
        
        for week in 0..<costByWeek.count {
            let component = costByWeek[week].weekLowerBoundYear
            let nsPredicate = NSPredicate(format: "year == %d && weekOfYear == %d", component.year!, component.weekOfYear!)
            accounting = DataController.shared.getData(nsPredicate: nsPredicate)
            for list in accounting {
                
                costByWeek[week].cost += Int(list.cost)
                
            }
        }
//        print(costByWeek.description)
    }
    
    func generateDayMonthYear(dateNow: Date) {
        self.costByDay = [costBaseDay]()
        for i in (0..<7).reversed() {
            let tmpDate = dateNow.addingTimeInterval(TimeInterval(-86400*i))
            let tmpDateComponent = Calendar.current.dateComponents(in: .current, from: tmpDate)
            self.costByDay.append(costBaseDay(dayMonthYear: tmpDateComponent, cost: 0))
        }
    }
    func computeCostByDayMonthYear(dateNow: Date) {
        self.generateDayMonthYear(dateNow: dateNow)
        for day in 0..<costByDay.count {
            
            let nsPredicate = NSPredicate(format: "year == %d && month == %d && day == %d", costByDay[day].dayMonthYear.year!, costByDay[day].dayMonthYear.month!, costByDay[day].dayMonthYear.day!)
            accounting = DataController.shared.getData(nsPredicate: nsPredicate)
            for list in accounting {
                
                costByDay[day].cost += Int(list.cost)
                
            }
        }
//        print(costByDay.description)
    }
    
    func generateMonthYear(dateNow: Date) {
        self.costByMonth = [costBaseMonth]()
        let component = Calendar.current.dateComponents(in: .current, from: dateNow)
        let middleMonth = component.month!
//        print(middleMonth)
        let middleYear = component.year!
        for month in middleMonth-6...middleMonth {
//            print(month)
            var tmpComponent = DateComponents(calendar: .current, timeZone: .current)
            if month > 12 {
                tmpComponent.month = month - 12
                tmpComponent.year = middleYear + 1
            } else if month < 1 {
                tmpComponent.month = 12 + month
                tmpComponent.year = middleYear - 1
            } else {
                tmpComponent.month = month
                tmpComponent.year = middleYear
            }
            self.costByMonth.append(costBaseMonth(monthYear: tmpComponent, cost: 0))
        }
//        print(costByMonth)
    }
    
    func computeCostByMonth(dateNow: Date) {
//        print(dateNow.description)
        self.generateMonthYear(dateNow: dateNow)
//        print(self.costByMonth)
        for month in 0..<costByMonth.count {
            let component = costByMonth[month].monthYear
            let nsPredicate = NSPredicate(format: "year == %d && month == %d", component.year!, component.month!)
            accounting = DataController.shared.getData(nsPredicate: nsPredicate)
            for list in accounting {
                costByMonth[month].cost += Int(list.cost)
            }
        }
//        print(costByMonth.description)
    }
    
    
    func addRecord(categorySelectedIndex: costCategory, costNameInput: String, cost: String, dateSelected: Date, costMemo: String, selectPhotoData: Data?, year: Int, month: Int, day: Int, weekOfYear: Int) {
        DataController.shared.addData(categorySelectedIndex: categorySelectedIndex, costNameInput: costNameInput, cost: cost, dateSelected: dateSelected, costMemo: costMemo, selectPhotoData: selectPhotoData, year: year, month: month, day: day, weekOfYear: weekOfYear)
//        if UserDefaults.standard.object(forKey: "records") == nil {
//            var records = [eachAccounting]()
//            let record : eachAccounting = eachAccounting(costCategory: categorySelectedIndex, costName: costNameInput, cost: Int(cost) ?? 0, time: dateSelected, note: costMemo, itemPicture: selectPhotoData)
//            records.append(record)
//            self.eachAccountingList = records
//        }else {
//            if let data = UserDefaults.standard.object(forKey: "records") as? Data {
//                let raw = try? JSONDecoder().decode([eachAccounting].self, from: data)
//                var records : [eachAccounting] = raw!
//                let record : eachAccounting = eachAccounting(costCategory: categorySelectedIndex, costName: costNameInput, cost: Int(cost) ?? 0, time: dateSelected, note: costMemo, itemPicture: selectPhotoData)
//                records.append(record)
//                self.eachAccountingList = records
//            }
//        }
//        saveRecord()
    }
    func getRecord(nsPredicate: NSPredicate) {
//        if let data = UserDefaults.standard.object(forKey: "records") as? Data {
//            let raw = try? JSONDecoder().decode([eachAccounting].self, from: data)
//            self.eachAccountingList = raw!
//            print(self.eachAccountingList.description)
//        }
        accounting = DataController.shared.getData(nsPredicate: nsPredicate)
    }
    func deleteRecord(deleteID: UUID) {
        DataController.shared.deleteData(selectedID: deleteID)
//        self.eachAccountingList = self.eachAccountingList.filter({$0.id != deleteID})
//        saveRecord()
    }
    func saveRecord() {
        if let encoded = try? JSONEncoder().encode(eachAccountingList) {
            UserDefaults.standard.setValue(encoded, forKey: "records")
        }
    }
    
    func filterCostByMonth(dateInput: Date) {
        var totalCostThisMonth = 0
        let NsPredicate = NSPredicate(format: "month == %d", Calendar.current.dateComponents(in: .current, from: dateInput).month!)
        accounting = DataController.shared.getData(nsPredicate: NsPredicate)
        accounting.forEach { account in
            totalCostThisMonth += Int(account.cost)
        }
//        accountings.nsPredicate = NSPredicate(format: "month == %d", Calendar.current.dateComponents(in: .current, from: dateInput).month!)
//        print(accountings)
//        accountings.forEach { accounting in
//            totalCostThisMonth += Int(accounting.cost)
//        }
//        var _ = eachAccountingList.filter({
//            let date = $0.time
//            let dateNow = dateInput
//            let component = Calendar.current.dateComponents(in: TimeZone.current, from: date)
//            let componentNow = Calendar.current.dateComponents(in: TimeZone.current, from: dateNow)
//            if component.month == componentNow.month {
//                totalCostThisMonth += $0.cost
//            }
//            return component.month == componentNow.month
//
//        })
        self.costThisMonth = totalCostThisMonth
//        return totalCostThisMonth
    }
    func filterCostByWeek(dateInput: Date) {
        var totalCostThisWeek = 0
        let NsPredicate = NSPredicate(format: "year == %d && weekOfYear == %d", Calendar.current.dateComponents(in: .current, from: dateInput).year!, Calendar.current.dateComponents(in: .current, from: dateInput).weekOfYear!)
        accounting = DataController.shared.getData(nsPredicate: NsPredicate)
        accounting.forEach { account in
            totalCostThisWeek += Int(account.cost)
        }
//        var _ = eachAccountingList.filter({
//            let date = $0.time
//            let component = Calendar.current.dateComponents(in: TimeZone.current, from: date)
//            let componentSelected = Calendar.current.dateComponents(in: TimeZone.current, from: dateInput)
//            if component.weekOfYear == componentSelected.weekOfYear {
//                totalCostThisWeek += $0.cost
//            }
//            return component.weekOfYear == componentSelected.weekOfYear
//
//        })
        self.costThisWeek = totalCostThisWeek
//        return totalCostThisWeek
    }
    func filterCostByDay(dateInput: Date) {
        var totalCostThisDay = 0
        let dateComponent = Calendar.current.dateComponents(in: .current, from: dateInput)
        print([dateComponent.year, dateComponent.month, dateComponent.day])
        let NsPredicate = NSPredicate(format: "year == %d AND month == %d AND day == %d", dateComponent.year!, dateComponent.month!, dateComponent.day!)
        accounting = DataController.shared.getData(nsPredicate: NsPredicate)
//        print(accounting)
        accounting.forEach { account in
            totalCostThisDay += Int(account.cost)
        }
//        var _ = eachAccountingList.map({
//            let date = $0.time
//            let dateNow = dateInput
//            if date.formatted(date: .numeric, time: .omitted) == dateNow.formatted(date: .numeric, time: .omitted) {
//                totalCostThisDay += $0.cost
//            }
//        })
        self.costThisDay = totalCostThisDay
//        return totalCostThisDay
    }
}
