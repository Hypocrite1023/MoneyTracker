//
//  ContentView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/3/21.
//

import SwiftUI
import PhotosUI
import Charts

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
enum recordSort {
    case ascending
    case descending
    case none
}
enum sortBySelection {
    case category
    case name
    case cost
}

struct eachAccounting: Codable, Hashable,Identifiable {
    let costCategory: costCategory
    let costName: String
    let cost: Int
    let time: Date
    let note: String
    let itemPicture: Data?
    let weekOfYear: Int?
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

struct costBaseMonth {
    let monthYear: DateComponents
    var cost: Int
}
struct costBaseDay: Hashable {
    let dayMonthYear: DateComponents
    var cost: Int
}
struct costBaseWeek {
    let weekLowerBoundYear: DateComponents
    let weekUpperBoundYear: DateComponents
    var cost: Int
}
//view model
class EachAccountingViewModel: ObservableObject {
    @Published var eachAccountingList : [eachAccounting] = [eachAccounting]()
    @Published var costThisDay: Int = 0
    @Published var costThisWeek: Int = 0
    @Published var costThisMonth: Int = 0
    @Published var costByMonth: [costBaseMonth] = [costBaseMonth]()
    @Published var costByDay: [costBaseDay] = [costBaseDay]()
    @Published var costByWeek: [costBaseWeek] = [costBaseWeek]()
    
    func generateWeekYear(dateNow: Date) {
        self.costByWeek = [costBaseWeek]()
        // list past seven weeks
        let dateInWeek = dateNow
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: dateInWeek)
//        print(dayOfWeek)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: dateInWeek)!
//        print(weekdays)
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: dateInWeek) }
        let lowerComponent = Calendar.current.dateComponents(in: .current, from: days[0])
        let upperComponent = Calendar.current.dateComponents(in: .current, from: days[6])
        costByWeek.insert(costBaseWeek(weekLowerBoundYear: lowerComponent, weekUpperBoundYear: upperComponent, cost: 0), at: 0)
        for _ in 0..<6 {
            let lowerDate = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: costByWeek[0].weekLowerBoundYear)!)!
            let upperDate = Calendar.current.date(byAdding: .day, value: -7, to: Calendar.current.date(from: costByWeek[0].weekUpperBoundYear)!)!
            let lowerDateComponent = Calendar.current.dateComponents(in: .current, from: lowerDate)
            let upperDateComponent = Calendar.current.dateComponents(in: .current, from: upperDate)
            costByWeek.insert(costBaseWeek(weekLowerBoundYear: lowerDateComponent, weekUpperBoundYear: upperDateComponent, cost: 0), at: 0)
        }
//        print(costByWeek)
    }
    
    func computeCostByWeekYear(dateNow: Date) {
        generateWeekYear(dateNow: dateNow)
        for week in 0..<costByWeek.count {
            for list in eachAccountingList {
                if Calendar.current.dateComponents(in: .current, from: list.time).weekOfYear == costByWeek[week].weekLowerBoundYear.weekOfYear {
                    costByWeek[week].cost += list.cost
                }
            }
        }
//        print(costByWeek.description)
    }
    
    func generateDayMonthYear(dateNow: Date) {
        self.costByDay = [costBaseDay]()
        for i in (0..<7).reversed() {
            let tmpDate = dateNow.addingTimeInterval(TimeInterval(-86400*i))
            let tmpDateComponent = Calendar.current.dateComponents(in: .current, from: tmpDate)
            self.costByDay.append(costBaseDay(dayMonthYear: tmpDateComponent, cost: 0))
        }
    }
    func computeCostByDayMonthYear(dateNow: Date) {
        self.generateDayMonthYear(dateNow: dateNow)
        for day in 0..<costByDay.count {
            for list in eachAccountingList {
                let dateComponent = Calendar.current.dateComponents(in: .current, from: list.time)
                if dateComponent.year == costByDay[day].dayMonthYear.year && dateComponent.month == costByDay[day].dayMonthYear.month && dateComponent.day == costByDay[day].dayMonthYear.day {
                    costByDay[day].cost += list.cost
                }
            }
        }
//        print(costByDay.description)
    }
    
    func generateMonthYear(dateNow: Date) {
        self.costByMonth = [costBaseMonth]()
        let component = Calendar.current.dateComponents(in: .current, from: dateNow)
        let middleMonth = component.month!
//        print(middleMonth)
        let middleYear = component.year!
        for month in middleMonth-6...middleMonth {
//            print(month)
            var tmpComponent = DateComponents(calendar: .current, timeZone: .current)
            if month > 12 {
                tmpComponent.month = month - 12
                tmpComponent.year = middleYear + 1
            } else if month < 1 {
                tmpComponent.month = 12 + month
                tmpComponent.year = middleYear - 1
            } else {
                tmpComponent.month = month
                tmpComponent.year = middleYear
            }
            self.costByMonth.append(costBaseMonth(monthYear: tmpComponent, cost: 0))
        }
//        print(costByMonth)
    }
    
    func computeCostByMonth(dateNow: Date) {
//        print(dateNow.description)
        self.generateMonthYear(dateNow: dateNow)
//        print(self.costByMonth)
        //前後3個月
        for month in 0..<costByMonth.count {
//            print(month)
            for list in eachAccountingList {
                let component = Calendar.current.dateComponents(in: .current, from: list.time)
                if component.month == costByMonth[month].monthYear.month && component.year == costByMonth[month].monthYear.year {
                    costByMonth[month].cost += list.cost
                }
            }
        }
//        print(costByMonth.description)
    }
    
    func sortByCategory(sortBy: sortBySelection, sortType: recordSort) {
        if sortBy == .category {
            if sortType == .ascending {
                self.eachAccountingList.sort(by: { $0.costCategory < $1.costCategory })
            } else if sortType == .descending {
                self.eachAccountingList.sort(by: { $0.costCategory > $1.costCategory })
            }
        } else if sortBy == .name {
            if sortType == .ascending {
                self.eachAccountingList.sort(by: { $0.costName < $1.costName })
            } else if sortType == .descending {
                self.eachAccountingList.sort(by: { $0.costName > $1.costName })
            }
        } else if sortBy == .cost {
            if sortType == .ascending {
                self.eachAccountingList.sort(by: { $0.cost < $1.cost })
            } else if sortType == .descending {
                self.eachAccountingList.sort(by: { $0.cost > $1.cost })
            }
        }
    }
    func addRecord(categorySelectedIndex: costCategory, costNameInput: String, cost: String, dateSelected: Date, costMemo: String, selectPhotoData: Data?, weekOfYear: Int) {
        if UserDefaults.standard.object(forKey: "records") == nil {
            var records = [eachAccounting]()
            let record : eachAccounting = eachAccounting(costCategory: categorySelectedIndex, costName: costNameInput, cost: Int(cost) ?? 0, time: dateSelected, note: costMemo, itemPicture: selectPhotoData, weekOfYear: weekOfYear)
            records.append(record)
            self.eachAccountingList = records
        }else {
            if let data = UserDefaults.standard.object(forKey: "records") as? Data {
                let raw = try? JSONDecoder().decode([eachAccounting].self, from: data)
                var records : [eachAccounting] = raw!
                let record : eachAccounting = eachAccounting(costCategory: categorySelectedIndex, costName: costNameInput, cost: Int(cost) ?? 0, time: dateSelected, note: costMemo, itemPicture: selectPhotoData,weekOfYear: weekOfYear)
                records.append(record)
                self.eachAccountingList = records
            }
        }
        saveRecord()
    }
    func getRecord() {
        if let data = UserDefaults.standard.object(forKey: "records") as? Data {
            let raw = try? JSONDecoder().decode([eachAccounting].self, from: data)
            self.eachAccountingList = raw!
//            print(self.eachAccountingList.description)
        }
    }
    func deleteRecord(deleteID: UUID) {
        self.eachAccountingList = self.eachAccountingList.filter({$0.id != deleteID})
        saveRecord()
    }
    func saveRecord() {
        if let encoded = try? JSONEncoder().encode(eachAccountingList) {
            UserDefaults.standard.setValue(encoded, forKey: "records")
        }
    }
    func filterCostByMonth(dateInput: Date) {
        var totalCostThisMonth = 0
        var _ = eachAccountingList.map({
            let date = $0.time
            let dateNow = dateInput
            let component = Calendar.current.dateComponents(in: TimeZone.current, from: date)
            let componentNow = Calendar.current.dateComponents(in: TimeZone.current, from: dateNow)
            if component.month == componentNow.month && component.year == componentNow.year {
                totalCostThisMonth += $0.cost
            }
            
        })
        self.costThisMonth = totalCostThisMonth
//        return totalCostThisMonth
    }
    func filterCostSpecifyMonth(dateInput: Date) {
        var totalCostThisMonth = 0
        var _ = eachAccountingList.filter({
            let date = $0.time
            let dateNow = dateInput
            let component = Calendar.current.dateComponents(in: TimeZone.current, from: date)
            let componentNow = Calendar.current.dateComponents(in: TimeZone.current, from: dateNow)
            if component.month == componentNow.month {
                totalCostThisMonth += $0.cost
            }
            return component.month == componentNow.month
            
        })
        self.costThisMonth = totalCostThisMonth
//        return totalCostThisMonth
    }
    func filterCostByWeek(dateInput: Date) {
        var totalCostThisWeek = 0
        var _ = eachAccountingList.filter({
            let date = $0.time
            let component = Calendar.current.dateComponents(in: TimeZone.current, from: date)
            let componentSelected = Calendar.current.dateComponents(in: TimeZone.current, from: dateInput)
            if component.weekOfYear == componentSelected.weekOfYear {
                totalCostThisWeek += $0.cost
            }
            return component.weekOfYear == componentSelected.weekOfYear
            
        })
        self.costThisWeek = totalCostThisWeek
//        return totalCostThisWeek
    }
    func filterCostByDay(dateInput: Date) {
        var totalCostThisDay = 0
        var _ = eachAccountingList.map({
            let date = $0.time
            let dateNow = dateInput
            if date.formatted(date: .numeric, time: .omitted) == dateNow.formatted(date: .numeric, time: .omitted) {
                totalCostThisDay += $0.cost
            }
        })
        self.costThisDay = totalCostThisDay
//        return totalCostThisDay
    }
}

class EachCategoryCost: ObservableObject {
    @Published var costClassifyByCategory: [eachCategoryCost] = [eachCategoryCost]()
    
    func buildCostCategoryArr() -> [eachCategoryCost] {
        var list = [eachCategoryCost]()
        for cate in costCategory.allCases {
            list.append(eachCategoryCost(category: cate, cost: 0))
        }
        return list
    }
    func caculateEachCategoryCost(eachAccountingList: [eachAccounting], showCostInDayDate: Date) {
        let costDayData = eachAccountingList.filter({
            $0.time.formatted(date: .numeric, time: .omitted) == showCostInDayDate.formatted(date: .numeric, time: .omitted)
        })
        self.costClassifyByCategory = buildCostCategoryArr()
        for data in costDayData {
            let index = self.costClassifyByCategory.firstIndex(where: {$0.category == data.costCategory})
            self.costClassifyByCategory[index!].cost += data.cost
        }
    }
    func caculateEachCategoryCostMonth(eachAccountingList: [eachAccounting], showCostInDayDate: Date) {
        let costDayData = eachAccountingList.filter({
            $0.time.formatted(date: .numeric, time: .omitted) == showCostInDayDate.formatted(date: .numeric, time: .omitted)
        })
        self.costClassifyByCategory = buildCostCategoryArr()
        for data in costDayData {
            let index = self.costClassifyByCategory.firstIndex(where: {$0.category == data.costCategory})
            self.costClassifyByCategory[index!].cost += data.cost
        }
    }
}

struct ContentView: View {
    @State var dateSelected = Date.now
    @State var showAccountingSheet = false
    @State var categorySelectedIndex : costCategory = .food
    @State var costNameInput : String = ""
    @State var cost : String = ""
    @State var costMemo : String = ""
    @State private var selectedItem : PhotosPickerItem?
    @State var selectPhotoData : Data?
    
    @StateObject var eachAccountingList = EachAccountingViewModel()
    
    let gridItem : [GridItem] = [GridItem(.fixed(80)), GridItem(.flexible()), GridItem(.fixed(150))]
    @State var categorySort : recordSort = .ascending
    @State var nameSort : recordSort = .none
    @State var costSort : recordSort = .none
    @State var selectDeleteID : UUID = UUID()
    @State var showCostInDayDate : Date = Date.now
    @State var costDayData : [eachAccounting] = [eachAccounting]()
    
    @StateObject var eachCategoryCost = EachCategoryCost()
    @State var monthSelect : Int = Calendar.current.component(.month, from: Date())
    @State var yearSelect : Int = Calendar.current.component(.year, from: Date())
    let months = returnMonthItems()
    let years = returnYearItems()
    
    @State var costViewSelectMode = costViewMode.day
    @State var costViewDataShowMode = costViewDataMode.data
    
    @State var addRecord: Bool = false
    @State var qrCodeResult: String = ""
    
    
    var body: some View {
        TabView {
            moneyAccountingView
            checkCostView
            settingView
        }
    }
    
    @ViewBuilder
    private var moneyAccountingView : some View {
        NavigationStack {
            
            
            DatePicker("記帳日期", selection: $dateSelected, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .background(.yellow)

            HStack {
                Text("月總支出:")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.orange)
                    )
                Divider()
                    .frame(height: 20)
                Text("\(eachAccountingList.costThisMonth)")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.orange)
                    )
            }
            .onAppear() {
                
            }
            HStack {
                Text("週總支出:")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.orange)
                    )
                Divider()
                    .frame(height: 20)
                Text("\(eachAccountingList.costThisWeek)")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.orange)
                    )
            }
            HStack {
                Text("日總支出:")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.orange)
                    )
                Divider()
                    .frame(height: 20)
                Text("\(eachAccountingList.costThisDay)")
                    .foregroundColor(.white)
                    .font(.system(size: 25))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.orange)
                    )
            }
            Spacer()
                .toolbar {
                    ToolbarItem {
                        HStack {
                            Button {
                                print("plus")
//                                addRecord.toggle()
                                showAccountingSheet.toggle()
                            } label: {
                                Label("新增紀錄", systemImage: "plus.app")
                                    .labelStyle(.titleAndIcon)
                            }
                            Divider()
                            Button {
                                print("plus")
                                addRecord.toggle()
//                                showAccountingSheet.toggle()
                            } label: {
                                Label("透過電子發票新增紀錄", systemImage: "plus.app")
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                    }
                }
                .sheet(isPresented: $addRecord) {
                    if qrCodeResult == "" {
                        QRScanner(result: $qrCodeResult)
                    }
                    if qrCodeResult != "" {
                        let result = strToDetail(str: qrCodeResult)
                        
                        let dateStr = result.date
                        let year = (Int(dateStr[dateStr.index(dateStr.startIndex, offsetBy: 0)..<dateStr.index(dateStr.startIndex, offsetBy: 3)]) ?? 0)
                        let yearInt = year + 1911
                        
                        let month = (Int(dateStr[dateStr.index(dateStr.startIndex, offsetBy: 3)..<dateStr.index(dateStr.startIndex, offsetBy: 5)]) ?? 0)
                        let day = (Int(dateStr[dateStr.index(dateStr.startIndex, offsetBy: 5)..<dateStr.index(dateStr.startIndex, offsetBy: 7)]) ?? 0)
                        let calendar = Calendar.init(identifier: .gregorian)
                        let dateComponent = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: yearInt, month: month, day: day, hour: 8)
                        let date = calendar.date(from: dateComponent)
                        let weekOfYear = dateComponent.weekOfYear ?? 0
                        TabView {
                            
                            Form {
                                
                                HStack {
                                    Label("類別", systemImage: "folder.fill.badge.gearshape")
                                    Spacer()
                                    Image(systemName: "arrow.up.doc.fill")
                                }
                                HStack {
                                    Label("項目名稱", systemImage: "rectangle.and.pencil.and.ellipsis")
                                    Spacer()
                                    TextField("項目名稱", text: $costNameInput)
                                        .multilineTextAlignment(.trailing)
                                }
                                HStack {
                                    Label("花費", systemImage: "creditcard")
                                    Spacer()
                                    Text(result.total.description)
                                }
                                HStack {
                                    Label("日期", systemImage: "calendar.badge.clock")
                                    
                                    Spacer()
                                    Text(date!.formatted(date: .numeric, time: .omitted))
                                }
                                HStack {
                                    Label("備註", systemImage: "scribble.variable")
                                    Spacer()
                                    Text(result.detail.description)
                                }
                                
                                
                            }
                            
                            
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .onAppear {
                            
                            costNameInput = "電子發票導入"
                        }
                        
                        HStack {
                            Button {
                                eachAccountingList.addRecord(categorySelectedIndex: .invoice, costNameInput: costNameInput, cost: String(result.total), dateSelected: date!, costMemo: result.detail.description, selectPhotoData: nil, weekOfYear: weekOfYear)
                                    
                                    
                                
                                addRecord = false
                                qrCodeResult = ""
                                clearInputField()
                            } label: {
                                Label("記錄", systemImage: "square.and.pencil")
                            }.buttonStyle(.borderedProminent)
                        }
                        
                        
                        
                    }
                }
                .sheet(isPresented: $showAccountingSheet) {
                    let dateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: dateSelected)
                    let weekOfYear = dateComponent.weekOfYear ?? 0
                    Form {
                        Picker(selection: $categorySelectedIndex) {
                            ForEach(costCategory.allCases, id: \.self) {
                                catagory in
                                catagory.label.tag(catagory)
                            }
                        } label: {
                            Label("類別", systemImage: "folder.fill.badge.gearshape")
                        }
                        HStack {
                            Label("項目名稱", systemImage: "rectangle.and.pencil.and.ellipsis")
                            TextField("項目名稱", text: $costNameInput)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Label("花費", systemImage: "creditcard")
                            TextField("花費", text: $cost)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Label("日期", systemImage: "calendar.badge.clock")
                            Spacer()
                            Text(dateSelected.formatted(date: .numeric, time: .omitted))
                        }
                        HStack {
                            Label("備註", systemImage: "scribble.variable")
                            TextField("", text: $costMemo, axis: .vertical)
//                                .multilineTextAlignment(.leading)
                                .lineLimit(3...5)
                        }
                        HStack {
                            Label("照片", systemImage: "camera")
                            VStack(alignment: .trailing) {
                                if let selectPhotoData {
                                    let image = UIImage(data: selectPhotoData)
                                    Image(uiImage: image!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(.leading, 20)
                                        
                                } else {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Spacer()
                                }
                                HStack{
                                    Spacer()
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        HStack {
                                            Image(systemName: "square.and.arrow.up")
                                            Text("相簿輸入")
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    Button {
                                        print("share")
                                    } label: {
                                        HStack {
                                            Image(systemName: "camera.shutter.button")
                                            Text("拍照")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Button {
                        eachAccountingList.addRecord(categorySelectedIndex: categorySelectedIndex, costNameInput: costNameInput, cost: cost, dateSelected: dateSelected, costMemo: costMemo, selectPhotoData: selectPhotoData, weekOfYear: weekOfYear)
                        showAccountingSheet = false
                        clearInputField()
                    } label: {
                        Label("記錄", systemImage: "square.and.pencil")
                    }.buttonStyle(.borderedProminent)

                }
                .onChange(of: selectedItem) { newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            selectPhotoData = data
                        }
                    }
                }
                .onChange(of: selectDeleteID) { newValue in
                    eachAccountingList.deleteRecord(deleteID: newValue)
                }
                
            
                
        }
        .onAppear {
            eachAccountingList.getRecord()
            print(eachAccountingList.eachAccountingList.description)
            eachAccountingList.filterCostByDay(dateInput: .now)
            eachAccountingList.filterCostByWeek(dateInput: .now)
            eachAccountingList.filterCostByMonth(dateInput: .now)
        }
        .tabItem {
            Label("記帳", systemImage: "dollarsign.circle")
        }
    }
    
    func checkReturnRecord(costName: String, cost: Int) -> recordError {
        if costName == "" {
            return recordError.costNameError
        }
        return recordError.pass
    }
    func clearInputField() {
        self.categorySelectedIndex = .food
        self.costNameInput = ""
        self.cost = ""
        self.costMemo = ""
        self.selectPhotoData = nil
    }
    
    @ViewBuilder
    var checkCostView : some View {
        NavigationStack {
            VStack {
                if costViewSelectMode == .day {
                    dailycost()
                }
                if costViewSelectMode == .week {
                    weeklycost()
                }
                if costViewSelectMode == .month {
                    monthlycost()
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
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.orange)
                                )
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
//        NavigationStack {
//            ZStack {
//                Color.black.ignoresSafeArea()
//                VStack {
//                    HStack {
//
//                        Button {
//                            costViewDataShowMode = .data
//                        } label: {
//                            Text("資料")
//                                .foregroundColor(.white)
//                                .padding(5)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .fill(costViewDataShowMode == .data ? .red : .gray)
//                                )
//                        }
//                        Button {
//                            costViewDataShowMode = .graph
//                        } label: {
//                            Text("圖表")
//                                .foregroundColor(.white)
//                                .padding(5)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .fill(costViewDataShowMode == .graph ? .red : .gray)
//                                )
//                        }
//                    }
//                    if costViewSelectMode == .day {
//                        dailycost(dataShowMode: $costViewDataShowMode)
//                    }
//                }
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        HStack {
//                            Button {
//                                costViewSelectMode = .day
//                            } label: {
//                                Text("以日檢視")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(costViewSelectMode == .day ? .white : .blue)
//
//                                    .padding(5)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .fill(.blue)
//                                            .opacity(costViewSelectMode == .day ? 1 : 0.4)
//                                    )
//                            }
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(.white)
//                                .frame(width: 5)
//                            Button {
//                                costViewSelectMode = .month
//                            } label: {
//
//                                Text("以月檢視")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(costViewSelectMode == .month ? .white : .blue)
//
//                                    .padding(5)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .fill(.blue)
//                                            .opacity(costViewSelectMode == .month ? 1.0 : 0.4)
//                                    )
//                            }
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(.white)
//                                .frame(width: 5)
//                            Button {
//                                costViewSelectMode = .custom
//                            } label: {
//
//                                Text("自定日期")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(costViewSelectMode == .custom ? .white : .blue)
//
//                                    .padding(5)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .fill(.blue)
//                                            .opacity(costViewSelectMode == .custom ? 1.0 : 0.4)
//                                    )
//                            }
//                        }
//                    }
//                }
//            }
//        }
////        .scrollContentBackground(.hidden)
//        .tabItem {
//            Label("花費狀況", systemImage: "chart.bar")
//        }
    }
    
    @ViewBuilder
    private var settingView : some View {
        VStack {
            Text("setting")
            Button {
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
            } label: {
                Label("清除紀錄", systemImage: "xmark.circle")
                    .labelStyle(.titleAndIcon)
            }
        }
            .tabItem {
                Label("設定", systemImage: "gear")
            }
    }
    
    @ViewBuilder
    private var dailyCostView : some View {
        HStack {
            Text("日期")
                .font(.system(size: 20))
                .foregroundColor(.blue)
            DatePicker(selection: $showCostInDayDate, displayedComponents: .date) {
                
            }
            .labelsHidden()
        }
        .padding(5)
        Chart(eachCategoryCost.costClassifyByCategory) { item in
            BarMark(x: .value("類別", item.category.returnText), y: .value("花費", item.cost))
                .annotation(position: .automatic, alignment: .center, spacing: nil) {
                    Text(item.cost, format: .number)
                }
        }
        .onChange(of: showCostInDayDate) { newValue in
            eachCategoryCost.caculateEachCategoryCost(eachAccountingList: eachAccountingList.eachAccountingList, showCostInDayDate: showCostInDayDate)
        }
        .onAppear {
            eachCategoryCost.caculateEachCategoryCost(eachAccountingList: eachAccountingList.eachAccountingList, showCostInDayDate: showCostInDayDate)
        }
        
        Spacer()
    }
    @ViewBuilder
    private var monthCostView : some View {
        VStack {
            HStack {
                monthYearPickerView(monthSelect: $monthSelect, yearSelect: $yearSelect, months: months, years: years)
            }
            
            
            Spacer()
        }
    }
    
}
struct monthYearPickerView : View {
    @Binding var monthSelect : Int
    @Binding var yearSelect : Int
    let months : [monthItem]
    let years : [yearItem]
    var body: some View {
        
        Picker(selection: $yearSelect) {
            
            ForEach(years) { year in
                Text(year.yearStr).tag(year.id)
            }
        } label: {
            Text("year")
        }
        .pickerStyle(.menu)
        Picker(selection: $monthSelect) {
            
            ForEach(months) { month in
                Text(month.monthStr).tag(month.id)
            }
        } label: {
            Text("month")
        }
        .pickerStyle(.menu)
    }
}

func returnMonthItems() -> [monthItem] {
    return (1...12).map({ monthItem(month: $0) })
}
func returnYearItems() -> [yearItem] {
    return (2000...2100).map({ yearItem(year: $0)} )
}

struct monthItem : Identifiable {
    let id: Int
    let monthStr: String
    let dateComp : DateComponents
    init(month: Int) {
        self.id = month
        var dateComponent = DateComponents()
        dateComponent.month = month
        if let date = Calendar(identifier: .gregorian).date(from: dateComponent) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            self.monthStr = formatter.string(from: date)
            
        }
        else {
            self.monthStr = ""
        }
        self.dateComp = dateComponent
    }
}
struct yearItem : Identifiable {
    let id: Int
    let yearStr: String
    let dateComp : DateComponents
    init(year: Int) {
        self.id = year
        var dateComponent = DateComponents()
        dateComponent.year = year
        if let date = Calendar(identifier: .gregorian).date(from: dateComponent) {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            self.yearStr = formatter.string(from: date)
        }
        else {
            self.yearStr = ""
        }
        self.dateComp = dateComponent
    }
}

struct eachRecordNavigate : View {
    let accounting : eachAccounting
    @Binding var deleteID : UUID
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        Form {
            HStack {
                Label("類別", systemImage: "folder.fill.badge.gearshape")
                Spacer()
                Text(accounting.costCategory.returnText)
            }
            HStack {
                Label("項目名稱", systemImage: "rectangle.and.pencil.and.ellipsis")
                Spacer()
                Text("\(accounting.costName)" as String)
            }
            HStack {
                Label("花費", systemImage: "creditcard")
                Spacer()
                Text("\(accounting.cost)" as String)
            }
            HStack {
                Label("日期", systemImage: "calendar.badge.clock")
                Spacer()
                Text("\(accounting.time.formatted(date: .numeric, time: .omitted))" as String)
            }
            HStack {
                Label("備註", systemImage: "scribble.variable")
                Spacer()
                Text("\(accounting.note)" as String)
                    .multilineTextAlignment(.trailing)
                
            }
            HStack {
                Label("照片", systemImage: "camera")
                if let picture = accounting.itemPicture {
                    let image = UIImage(data: picture)!
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    print("delete")
                    deleteID = accounting.id
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "trash")
                }

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
