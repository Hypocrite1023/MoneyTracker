//
//  EachCategoryCost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import Foundation

class EachCategoryCost: ObservableObject {
    @Published var costClassifyByCategory: [eachCategoryCost] = [eachCategoryCost]()
    
    func buildCostCategoryArr() -> [eachCategoryCost] {
        var list = [eachCategoryCost]()
        for cate in costCategory.allCases {
            list.append(eachCategoryCost(category: cate, cost: 0))
        }
        return list
    }
    func caculateEachCategoryCost(eachAccountingList: [eachAccounting], showCostInDayDate: Date) {
        let costDayData = eachAccountingList.filter({
            $0.time.formatted(date: .numeric, time: .omitted) == showCostInDayDate.formatted(date: .numeric, time: .omitted)
        })
        self.costClassifyByCategory = buildCostCategoryArr()
        for data in costDayData {
            let index = self.costClassifyByCategory.firstIndex(where: {$0.category == data.costCategory})
            self.costClassifyByCategory[index!].cost += data.cost
        }
    }
    func caculateEachCategoryCostMonth(eachAccountingList: [eachAccounting], showCostInDayDate: Date) {
        let costDayData = eachAccountingList.filter({
            $0.time.formatted(date: .numeric, time: .omitted) == showCostInDayDate.formatted(date: .numeric, time: .omitted)
        })
        self.costClassifyByCategory = buildCostCategoryArr()
        for data in costDayData {
            let index = self.costClassifyByCategory.firstIndex(where: {$0.category == data.costCategory})
            self.costClassifyByCategory[index!].cost += data.cost
        }
    }
}
