//
//  monthYearPicker.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/8.
//

import SwiftUI

struct yearMonthStruct {
    let year: Int
    let month: Int
    let id: Int
}

struct monthYearPicker: View {
    let yearMonth = (2001...2050).map({
        year in
        (1...12).map {
            month in
            yearMonthStruct(year: year, month: month, id: year*100+month)
        }
    }).flatMap({$0})
    @Binding var monthYearSelected : Int
    var body: some View {
        Picker("", selection: $monthYearSelected) {
            ForEach(yearMonth, id: \yearMonthStruct.id) {
                item in
                let yearStr = String(format: "%4d", item.year) + "年"
                let monthStr = String(format: "%2d", item.month) + "月"
                Text(yearStr + monthStr).tag(item.year*100 + item.month)
            }
        }
//        Menu {
//            Picker("", selection: $monthYearSelected) {
//                ForEach(yearMonth, id: \yearMonthStruct.id) {
//                    item in
//                    let yearStr = String(format: "%4d", item.year) + "年"
//                    let monthStr = String(format: "%2d", item.month) + "月"
//                    Text(yearStr + monthStr).tag(item.id)
//                }
//            }
//        } label: {
//            let yStr = String(format: "%4d", monthYearSelected/100) + "年"
//            let mStr = String(format: "%2d", monthYearSelected%100) + "月"
//            Text(yStr + mStr)
//                .foregroundColor(.white)
//                .bold()
//                .padding(10)
//                .background(.blue)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
//        }
    }
}

//struct monthYearPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        monthYearPicker()
//    }
//}
