//
//  monthlycost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/8.
//

import SwiftUI
import Charts

class operateMonth: ObservableObject {
    @Published var showCostInDayDate : Date = Date.now
    @Published var selectDeleteID : UUID = UUID()
    @Published var monthCostUpperBound: Int = 2000
    @Published var percent : Double = 0
    @Published var showData: [Bool] = Array(repeating: false, count: 7)
    @Published var yearMonthSelected = Calendar.current.dateComponents(in: .current, from: .now).year!*100 + Calendar.current.dateComponents(in: .current, from: .now).month!
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM"
        return dateFormatter.string(from: date)
    }
    
}

struct monthlycost: View {
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @StateObject var operateManager = operateMonth()
    
    var body: some View {
        TabView {
            //detail
            ScrollView() {
                VStack {
                    HStack {
                        Text("趨勢圖")
                            .font(.system(size: 30))
                            .padding(.leading)

                        Spacer()
//                        DatePicker(selection: $operateManager.showCostInDayDate, displayedComponents: .date) {
//
//                        }
//                        .padding(.trailing, 5)
//                        .labelsHidden()
                        monthYearPicker(monthYearSelected: $operateManager.yearMonthSelected)
                            .padding(.trailing, 5)
                    }
                    .padding(.top, 10)
                    Chart {
                        ForEach(0..<eachAccountingList.costByMonth.count, id: \.self) {
                            month in
                            let combineStr = operateManager.returnDateStr(date: Calendar.current.date(from: eachAccountingList.costByMonth[month].monthYear)!)
                            if operateManager.showData[month] {
                                LineMark(
                                    x: .value("month,year", combineStr),
                                    y: .value("cost", eachAccountingList.costByMonth[month].cost)
                                )
                            }
                        }
                    }
                    
                    Divider()
                    HStack {
                        Text("目標")
                            .font(.system(size: 30))
                            .padding(.leading)
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            progressLoopWithAnimate(size: CGFloat(100), percent: $operateManager.percent)
                        }
                        .padding(.horizontal, 15)
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                Text("花費上限:")
                                Spacer()
                                Image(systemName: "gear")
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        let _ = "nnn"
                                    }
                            }
                            HStack {
                                Spacer()
                                Text(operateManager.monthCostUpperBound, format: .currency(code: "TWD").precision(.fractionLength(0)))
                                
                            }
                            Divider()
                            HStack {
                                Text("\(operateManager.returnDateStr(date: operateManager.showCostInDayDate))已使用:")
                                
                            }
                            HStack {
                                Spacer()
                                Text(eachAccountingList.costThisMonth, format: .currency(code: "TWD").precision(.fractionLength(0)))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    Divider()
                        .padding(5)
                    
                }
            }
            .onAppear {
                
                operateManager.percent = 0.0
                eachAccountingList.getRecord()
                eachAccountingList.filterCostByMonth(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisMonth)/Double(operateManager.monthCostUpperBound)

                }

                eachAccountingList.computeCostByMonth(dateNow: operateManager.showCostInDayDate)
                for counter in 0...eachAccountingList.costByMonth.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
                        operateManager.showData[counter] = true
                        }
                }
                
            }
            .onChange(of: operateManager.showCostInDayDate, perform: { newValue in
                operateManager.percent = 0.0
                eachAccountingList.filterCostByMonth(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisMonth)/Double(operateManager.monthCostUpperBound)

                }

                eachAccountingList.computeCostByMonth(dateNow: operateManager.showCostInDayDate)
                operateManager.showData = Array(repeating: false, count: 7)
                for counter in 0...eachAccountingList.costByMonth.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
                        operateManager.showData[counter] = true
                        }
                }
            })
            .onChange(of: operateManager.yearMonthSelected, perform: { newValue in
                operateManager.showCostInDayDate = Calendar.current.date(from: DateComponents(calendar: .current, timeZone: .current, year: newValue/100, month: newValue%100))!
            })
            .tabItem {
                Text("detail")
            }
            //data
            NavigationStack {
                HStack {
                    Text("詳細資料")
                        .font(.system(size: 30))
                        .padding(.leading)
//                        .foregroundColor(.white)
                    Spacer()
                    monthYearPicker(monthYearSelected: $operateManager.yearMonthSelected)
                        .padding(.trailing, 5)
                }
                .padding(.top, 10)

                List {
                    ForEach(eachAccountingList.eachAccountingList, id: \.self) { accounting in
                        let accountingDateComponent = Calendar.current.dateComponents(in: .current, from: accounting.time)
                        let selectedDateComponent = Calendar.current.dateComponents(in: .current, from: operateManager.showCostInDayDate)
                        if accountingDateComponent.year == selectedDateComponent.year && accountingDateComponent.month == selectedDateComponent.month {
                            NavigationLink {
                                eachRecordNavigate(accounting: accounting, deleteID: $operateManager.selectDeleteID)
                            } label: {
                                HStack {
                                    accounting.costCategory.label
                                    Text(accounting.costName)
                                    Text(String(accounting.cost))
                                }
                            }

                        }
                        
                    }
                }
                .listStyle(.inset)
            }
            .tabItem({
                Text("data")
            })
            .onChange(of: operateManager.showCostInDayDate) { newValue in
                eachCategoryCost.caculateEachCategoryCost(eachAccountingList: eachAccountingList.eachAccountingList, showCostInDayDate: newValue)
            }
            .onChange(of: operateManager.yearMonthSelected, perform: { newValue in
                operateManager.showCostInDayDate = Calendar.current.date(from: DateComponents(calendar: .current, timeZone: .current, year: newValue/100, month: newValue%100))!
            })
            .onAppear {
                eachAccountingList.getRecord()
                eachCategoryCost.caculateEachCategoryCost(eachAccountingList: eachAccountingList.eachAccountingList, showCostInDayDate: operateManager.showCostInDayDate)
                
                
            }
            //graph
            
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        
        
                

        
        
    }
    func getMonthFromDate(date: Date) -> Int {
        let dateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        return dateComponent.month!
    }
    func getWeekOfYearFromDate(date: Date) -> Int {
        let dateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        return dateComponent.weekOfYear!
    }
    func getYearFromDate(date: Date) -> Int {
        let dateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        return dateComponent.year!
    }
}

struct monthlycost_Previews: PreviewProvider {
    static var previews: some View {
        monthlycost()
    }
}
