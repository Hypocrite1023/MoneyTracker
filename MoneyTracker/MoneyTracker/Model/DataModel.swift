//
//  DataModel.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import Foundation
import SwiftUI

enum costCategory : CaseIterable, Codable, Comparable {
    case food
    case entertainment
    case invoice
    var label : some View {
        switch(self) {
        case .food: return Label("飲食", systemImage: "fork.knife.circle")
        case .entertainment: return Label("娛樂", systemImage: "party.popper")
        case .invoice: return Label("電子發票導入", systemImage: "arrow.up.doc.fill")
        }
    }
    var returnText : String {
        switch(self) {
            case .food: return "飲食"
            case .entertainment: return "娛樂"
            case .invoice: return "電子發票導入"
        }
    }
}

enum recordError {
    case costNameError
    case costError
    case pass
}

struct eachAccounting: Codable, Hashable,Identifiable {
    let costCategory: costCategory
    let costName: String
    let cost: Int
    let time: Date
    let note: String
    let itemPicture: Data?
    var id : UUID = UUID()
}

struct eachCategoryCost: Identifiable, Hashable {
    let category: costCategory
    let id = UUID()
    var cost: Int
}

enum costViewMode: CaseIterable {
    case day
    case week
    case month
//    case custom
    var text: String {
        switch(self) {
        case .day: return "日"
        case .week: return "週"
        case .month: return "月"
//        case .custom: return "自訂"
        }
    }
}
enum costViewDataMode {
    case detail
    case data
    case graph
}

struct costBaseMonth: Hashable {
    let monthYear: DateComponents
    var cost: Int
}

struct costBaseDay: Hashable {
    let dayMonthYear: DateComponents
    var cost: Int
}

struct costBaseWeek: Hashable {
    let weekLowerBoundYear: DateComponents
    let weekUpperBoundYear: DateComponents
    var cost: Int
}
enum settingGoatMode {
    case day
    case week
    case month
    var text: String {
        switch(self) {
        case .day: return "輸入每日上限目標"
        case .week: return "輸入每週上限目標"
        case .month: return "輸入每月上限目標"
        }
    }
    
}
