//
//  weeklycost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/7.
//

import SwiftUI
import Charts

struct WeeklyCost: View {
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @StateObject var operateManager = OperateWeek()
    @State var weekSelectedID: Date = .now
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
                        weekPickerButton(weekSelectedID: $weekSelectedID)
                            
                        .padding(.trailing, 5)
//                        .background(.white)
//                        .labelsHidden()
                    }
                    .padding(.top, 10)
                    LineChart(accountingListBaseDay: $eachAccountingList.costByDay, accountingListBaseWeek: $eachAccountingList.costByWeek, accountingListBaseMonth: $eachAccountingList.costByMonth, mode: .week)
                        
                        .onChange(of: weekSelectedID, perform: { newValue in
                            eachAccountingList.filterCostByWeek(dateInput: newValue)
                            
                            eachAccountingList.computeCostByWeekYear(dateNow: operateManager.showCostInDayDate)
                            
                        })
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
                                
                                .onChange(of: weekSelectedID, perform: { newValue in
                                    operateManager.percent = 0.0
                                    withAnimation(.linear(duration: 1)) {
                                        operateManager.percent += Double(eachAccountingList.costThisWeek)/Double(operateManager.weekCostUpperBound)
                                        
                                    }
                                })
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
                                Text(upperBoundManager.getWeekUpperBound(), format: .currency(code: "TWD").precision(.fractionLength(0)))
                                
                            }
                            Divider()
                            HStack {
                                Text(String(getYearFromDate(date: weekSelectedID))+"第\(getWeekOfYearFromDate(date: weekSelectedID))週已使用:")
                                
                            }
                            HStack {
                                Spacer()
                                Text(eachAccountingList.costThisWeek, format: .currency(code: "TWD").precision(.fractionLength(0)))
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
            
            .onChange(of: weekSelectedID, perform: { newValue in
                
                eachAccountingList.filterCostByWeek(dateInput: newValue)
                eachAccountingList.computeCostByWeekYear(dateNow: weekSelectedID)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisWeek)/Double(upperBoundManager.getWeekUpperBound())

                }
            })
            .onAppear {
                eachAccountingList.filterCostByWeek(dateInput: weekSelectedID)
                eachAccountingList.computeCostByWeekYear(dateNow: weekSelectedID)
                operateManager.percent = 0.0
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisWeek)/Double(upperBoundManager.getWeekUpperBound())

                }
            }
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
                    weekPickerButton(weekSelectedID: $weekSelectedID)
                    .padding(.trailing, 5)
//                    .background(.white)
                    .labelsHidden()
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
            .onChange(of: operateManager.selectDeleteID, perform: { newValue in
                eachAccountingList.deleteRecord(deleteID: newValue)
                eachAccountingList.filterCostByWeek(dateInput: operateManager.showCostInDayDate)
            })
            .tabItem({
                Text("data")
            })
            .onChange(of: operateManager.showCostInDayDate) { newValue in
                eachAccountingList.filterCostByWeek(dateInput: operateManager.showCostInDayDate)
            }
            .onAppear {
                eachAccountingList.filterCostByWeek(dateInput: operateManager.showCostInDayDate)
//                eachCategoryCost.caculateEachCategoryCost(eachAccountingList: eachAccountingList.eachAccountingList, showCostInDayDate: operateManager.showCostInDayDate)
                
                
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

struct weeklycost_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyCost()
    }
}
