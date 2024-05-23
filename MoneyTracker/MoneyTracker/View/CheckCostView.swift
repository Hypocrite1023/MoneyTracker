//
//  CheckCostView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import SwiftUI

struct CheckCostView: View {
    //以 day or week or month 模式展示資料
    @State var costViewSelectMode = costViewMode.day
    
    var body: some View {
        NavigationStack {
            VStack {
                if costViewSelectMode == .day {
                    DailyCost()
                }
                if costViewSelectMode == .week {
                    WeeklyCost()
                }
                if costViewSelectMode == .month {
                    MonthlyCost()
                }
            }
            .toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker(selection: $costViewSelectMode) {
                        ForEach(costViewMode.allCases, id: \.self) {
                            mode in
                            Text(mode.text).tag(mode)
                                .bold()
                                .padding(10)
                        }
                    } label: {
                        Label("mode", systemImage: "calendar")
                    }
                    .pickerStyle(.segmented)


                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.orange, for: .navigationBar)
            .navigationTitle(Text("花費狀況"))
        }
        .tabItem {
            Label("花費狀況", systemImage: "chart.bar")
        }
    }
}

struct CheckCostView_Previews: PreviewProvider {
    static var previews: some View {
        CheckCostView()
            .environment(\.managedObjectContext, DataController.shared.container.viewContext)
    }
}
