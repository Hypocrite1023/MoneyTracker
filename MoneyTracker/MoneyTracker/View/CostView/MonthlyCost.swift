//
//  monthlycost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/8.
//

import SwiftUI
import Charts

struct MonthlyCost: View {
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @StateObject var operateManager = OperateMonth()
    @State var upperBoundManager = SpendUpperBoundManager()
    var body: some View {
        TabView {
            //detail
            NavigationStack {
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
                    LineChart(accountingListBaseDay: $eachAccountingList.costByDay, accountingListBaseWeek: $eachAccountingList.costByWeek, accountingListBaseMonth: $eachAccountingList.costByMonth, mode: .month)
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
                                Text(upperBoundManager.getMonthUpperBound(), format: .currency(code: "TWD").precision(.fractionLength(0)))
                                
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
//                eachAccountingList.getRecord()
                eachAccountingList.filterCostByMonth(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisMonth)/Double(upperBoundManager.getMonthUpperBound())

                }

                eachAccountingList.computeCostByMonth(dateNow: operateManager.showCostInDayDate)
                
                
            }
            .onChange(of: operateManager.showCostInDayDate, perform: { newValue in
                operateManager.percent = 0.0
                eachAccountingList.filterCostByMonth(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisMonth)/Double(upperBoundManager.getMonthUpperBound())

                }

                eachAccountingList.computeCostByMonth(dateNow: operateManager.showCostInDayDate)
                operateManager.showData = Array(repeating: false, count: 7)
                
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
                    ForEach(0..<eachAccountingList.accounting.count, id: \.self) { index in
                        let account = eachAccountingList.accounting[index]
                        let eachAccount = eachAccounting(costCategory: stringToCategory(str: account.costCategory!), costName: account.costName!, cost: Int(account.cost), time: .now, note: account.note!, itemPicture: account.itemPicture, id: account.id!)
                        NavigationLink {
                            EachRecordNavigate(accounting: eachAccount, inputDeleteID: $operateManager.selectDeleteID, showDay: $operateManager.showCostInDayDate)
                        } label: {
                            HStack {
                                stringToCategory(str: account.costCategory!).label
                                Text(account.costName!)
                                Spacer()
                                Text(String(account.cost))
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
                eachAccountingList.filterCostByMonth(dateInput: newValue)
//                eachAccountingList.computeCostByMonth(dateNow: newValue)
            }
            .onChange(of: operateManager.yearMonthSelected, perform: { newValue in
                operateManager.showCostInDayDate = Calendar.current.date(from: DateComponents(calendar: .current, timeZone: .current, year: newValue/100, month: newValue%100))!
            })
            .onChange(of: operateManager.selectDeleteID, perform: { newValue in
                eachAccountingList.deleteRecord(deleteID: newValue)
                eachAccountingList.filterCostByMonth(dateInput: operateManager.showCostInDayDate)
            })
            .onAppear {
                eachAccountingList.filterCostByMonth(dateInput: operateManager.showCostInDayDate)
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
    func stringToCategory(str: String) -> costCategory {
        var setCategory: costCategory = .entertainment
        for category in costCategory.allCases {
            if str == category.returnText {
                setCategory = category
            }
        }
        return setCategory
    }
}

struct monthlycost_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyCost()
    }
}
