//
//  weeklycost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/7.
//

import SwiftUI
import Charts

class operateWeek: ObservableObject {
    @Published var showCostInDayDate : Date = Date.now
    @Published var selectDeleteID : UUID = UUID()
    @Published var weekCostUpperBound: Int = 2000
    @Published var percent : Double = 0
    @Published var showData: [Bool] = Array(repeating: false, count: 7)
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter.string(from: date)
    }
}

struct weeklycost: View {
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @StateObject var operateManager = operateWeek()
    
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
                        DatePicker(selection: $operateManager.showCostInDayDate, displayedComponents: .date) {
                            
                        }
                        .padding(.trailing, 5)
//                        .background(.white)
                        .labelsHidden()
                    }
                    .padding(.top, 10)
                    Chart {
                        ForEach(0..<eachAccountingList.costByWeek.count, id: \.self) {
                            week in
                            let combineStr = operateManager.returnDateStr(date: Calendar.current.date(from: eachAccountingList.costByWeek[week].weekLowerBoundYear)!) + "-\n" + operateManager.returnDateStr(date: Calendar.current.date(from: eachAccountingList.costByWeek[week].weekUpperBoundYear)!)
                            if operateManager.showData[week] {
                                LineMark(
                                    x: .value("day,month,year", combineStr),
                                    y: .value("cost", eachAccountingList.costByWeek[week].cost)
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
                                Text(operateManager.weekCostUpperBound, format: .currency(code: "TWD").precision(.fractionLength(0)))
                                
                            }
                            Divider()
                            HStack {
                                Text(String(getYearFromDate(date: operateManager.showCostInDayDate))+"第\(getWeekOfYearFromDate(date: operateManager.showCostInDayDate))週已使用:")
                                
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
            .onAppear {
                
                operateManager.percent = 0.0
                eachAccountingList.getRecord()
                eachAccountingList.filterCostByWeek(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisWeek)/Double(operateManager.weekCostUpperBound)

                }

                eachAccountingList.computeCostByWeekYear(dateNow: operateManager.showCostInDayDate)
                for counter in 0...eachAccountingList.costByWeek.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
                        operateManager.showData[counter] = true
                        }
                }
                
            }
            .onChange(of: operateManager.showCostInDayDate, perform: { newValue in
                operateManager.percent = 0.0
                eachAccountingList.filterCostByWeek(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisWeek)/Double(operateManager.weekCostUpperBound)

                }

                eachAccountingList.computeCostByWeekYear(dateNow: operateManager.showCostInDayDate)
                operateManager.showData = Array(repeating: false, count: 7)
                for counter in 0...eachAccountingList.costByWeek.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
                        operateManager.showData[counter] = true
                        }
                }
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
                    ForEach(eachAccountingList.eachAccountingList, id: \.self) { accounting in
                        if accounting.time.formatted(date: .numeric, time: .omitted) == operateManager.showCostInDayDate.formatted(date: .numeric, time: .omitted) {
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

struct weeklycost_Previews: PreviewProvider {
    static var previews: some View {
        weeklycost()
    }
}
