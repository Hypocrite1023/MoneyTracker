//
//  dailycost.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/4/27.
//

import SwiftUI
import Charts

class operateDay: ObservableObject {
    @Published var showCostInDayDate : Date = Date.now
    @Published var selectDeleteID : UUID = UUID()
    @Published var dayCostUpperBound: Int = 1000
    @Published var percent : Double = 0
    @Published var showData: [Bool] = Array(repeating: false, count: 7)
    
    func returnDateStr(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        return dateFormatter.string(from: date)
    }
}

struct dailycost: View {
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    @StateObject var operateManager = operateDay()
    
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
                        ForEach(0..<eachAccountingList.costByDay.count, id: \.self) {
                            day in
                            
                            if operateManager.showData[day] {
                                LineMark(
                                    x: .value("day,month,year", operateManager.returnDateStr(date: Calendar.current.date(from: eachAccountingList.costByDay[day].dayMonthYear)!)),
                                    y: .value("cost", eachAccountingList.costByDay[day].cost)
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
                                Text(operateManager.dayCostUpperBound, format: .currency(code: "TWD").precision(.fractionLength(0)))
                                
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
                eachAccountingList.getRecord()
                eachAccountingList.computeCostByDayMonthYear(dateNow: operateManager.showCostInDayDate)
                eachAccountingList.filterCostByDay(dateInput: operateManager.showCostInDayDate)
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisDay)/Double(operateManager.dayCostUpperBound)

                }
                
                
                for counter in 0...eachAccountingList.costByDay.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(counter)) { // adjust speed by changing 0.2
                        operateManager.showData[counter] = true
                        }
                }
                
            }
            .onChange(of: operateManager.showCostInDayDate, perform: { newValue in
                eachAccountingList.filterCostByDay(dateInput: newValue)
                eachAccountingList.computeCostByDayMonthYear(dateNow: newValue)
                operateManager.percent = 0.0
                withAnimation(.linear(duration: 1)) {
                    operateManager.percent += Double(eachAccountingList.costThisDay)/Double(operateManager.dayCostUpperBound)

                }
                operateManager.showData = Array(repeating: false, count: 7)
                for counter in 0...eachAccountingList.costByDay.count - 1 {
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
    
}

struct dailycost_Previews: PreviewProvider {
    static var previews: some View {
        dailycost()
    }
}
