//
//  dailycost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/4/27.
//

import SwiftUI
import Charts

struct DailyCost: View {
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @StateObject var operateManager = OperateDay()
    @StateObject var upperBoundManager = SpendUpperBoundManager()
    func returnDateLower(date: Date) -> Date {
        var lowerBound = Date.now
        var lowerBoundDateComponent = Calendar.current.dateComponents(in: .current, from: lowerBound)
        lowerBoundDateComponent.hour = 8
        lowerBoundDateComponent.minute = 0
        lowerBoundDateComponent.second = 0
        
        lowerBound = Calendar.current.date(from: lowerBoundDateComponent)!
        return lowerBound
    }
    func returnDateUpper(date: Date) -> Date {
        
        var upperBound = Calendar.current.date(byAdding: .day, value: 1, to: operateManager.showCostInDayDate)
        var upperBoundDateComponent = Calendar.current.dateComponents(in: .current, from: upperBound!)
        upperBoundDateComponent.hour = 8
        upperBoundDateComponent.minute = 0
        upperBoundDateComponent.second = 0
        upperBound = Calendar.current.date(from: upperBoundDateComponent)
        return upperBound!
    }
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
                        DatePicker(selection: $operateManager.showCostInDayDate, displayedComponents: .date) {
                            
                        }
                        .padding(.trailing, 5)
//                        .background(.white)
                        .labelsHidden()
                    }
                    .padding(.top, 10)
                    ScrollView(.horizontal) {
                        LineChart(accountingListBaseDay: $eachAccountingList.costByDay, accountingListBaseWeek: $eachAccountingList.costByWeek, accountingListBaseMonth: $eachAccountingList.costByMonth, mode: .day)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width)
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
                                Text(upperBoundManager.getDayUpperBound(), format: .currency(code: "TWD").precision(.fractionLength(0)))
                                
                            }
                            Divider()
                            HStack {
                                Text("\(operateManager.returnDateStr(date: operateManager.showCostInDayDate))已使用:")
                                
                            }
                            HStack {
                                Spacer()
                                Text(eachAccountingList.costThisDay, format: .currency(code: "TWD").precision(.fractionLength(0)))
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
//                let component = Calendar.current.dateComponents(in: .current, from: operateManager.showCostInDayDate)
//                let nsPredicate = NSPredicate(format: "year == %d && month == %d && day == %d", component.year!, component.month!, component.day!)
//                eachAccountingList.getRecord(nsPredicate: nsPredicate)
                eachAccountingList.computeCostByDayMonthYear(dateNow: operateManager.showCostInDayDate)
                eachAccountingList.filterCostByDay(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisDay)/Double(upperBoundManager.getDayUpperBound())

                }
                
                
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        operateManager.showData[counter] = true
//                        }
//                }
                
            }
            .onChange(of: operateManager.showCostInDayDate, perform: { newValue in
                eachAccountingList.filterCostByDay(dateInput: newValue)
                eachAccountingList.computeCostByDayMonthYear(dateNow: newValue)
                operateManager.percent = 0.0
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisDay)/Double(upperBoundManager.getDayUpperBound())

                }
                operateManager.showData = Array(repeating: false, count: 7)
//                for counter in 0...6 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
//                        operateManager.showData[counter] = true
//                        }
//                }
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
                    DatePicker(selection: $operateManager.showCostInDayDate, displayedComponents: .date) {
                        
                    }
                    .padding(.trailing, 5)
//                    .background(.white)
                    .labelsHidden()
                }
                .padding(.top, 10)
                List {
                    ForEach(0..<eachAccountingList.accounting.count, id: \.self) { index in
                        let account = eachAccountingList.accounting[index]
//                        let _ = print("foreach")
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
            .onChange(of: operateManager.selectDeleteID, perform: { newValue in
                eachAccountingList.deleteRecord(deleteID: newValue)
                let component = Calendar.current.dateComponents(in: .current, from: operateManager.showCostInDayDate)
                let nsPredicate = NSPredicate(format: "year == %d && month == %d && day == %d", component.year!, component.month!, component.day!)
                eachAccountingList.getRecord(nsPredicate: nsPredicate)
                print("changedata")
            })
            .tabItem({
                Text("data")
            })
            .onChange(of: operateManager.showCostInDayDate) { newValue in
                let component = Calendar.current.dateComponents(in: .current, from: newValue)
                let nsPredicate = NSPredicate(format: "year == %d && month == %d && day == %d", component.year!, component.month!, component.day!)
                eachAccountingList.getRecord(nsPredicate: nsPredicate)
            }
            .onAppear {
                let component = Calendar.current.dateComponents(in: .current, from: operateManager.showCostInDayDate)
                let nsPredicate = NSPredicate(format: "year == %d && month == %d && day == %d", component.year!, component.month!, component.day!)
                eachAccountingList.getRecord(nsPredicate: nsPredicate)
                print("onappear")
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
    /// 將 core data 內存的 costCategory String 轉成 costCategory
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

struct dailycost_Previews: PreviewProvider {
    
    static var previews: some View {
        DailyCost()
            .environment(\.managedObjectContext, DataController.shared.container.viewContext)
    }
}
