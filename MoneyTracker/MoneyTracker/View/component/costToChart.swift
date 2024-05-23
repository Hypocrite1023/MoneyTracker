//
//  costToChart.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/5.
//

import SwiftUI
import Charts

struct costToChart: View {
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @State var showCostInDayDate : Date = Date.now
    
    var body: some View {
        Chart {
            ForEach(eachCategoryCost.costClassifyByCategory, id: \.self) {
                category in
                BarMark(
                    x: .value("分類", category.category.returnText),
                    y: .value("花費", category.cost)
                )
                .foregroundStyle(.green)
            }
            
        }
//        .frame(width: 200, height: 200)
        .onAppear {
//            eachAccountingList.getRecord()
            eachCategoryCost.caculateEachCategoryCost(eachAccountingList: eachAccountingList.eachAccountingList, showCostInDayDate: showCostInDayDate)
        }
    }
    
}

struct costToChart_Previews: PreviewProvider {
    static var previews: some View {
        costToChart()
    }
}
