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
    var label : some View {
        switch(self) {
        case .food: return Label("飲食", systemImage: "fork.knife.circle")
        case .entertainment: return Label("娛樂", systemImage: "party.popper")
        }
    }
    var returnText : String {
        switch(self) {
            case .food: return "飲食"
            case .entertainment: return "娛樂"
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

struct eachAccounting : Codable, Hashable,Identifiable {
    let costCategory : costCategory
    let costName : String
    let cost: Int
    let time : Date
    let note : String
    let itemPicture : Data?
    var id : UUID = UUID()
}

struct eachCategoryCost : Identifiable {
    let category : costCategory
    let id = UUID()
    var cost : Int
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
    @State var eachAccountingList : [eachAccounting] = []
    let gridItem : [GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State var categorySort : recordSort = .ascending
    @State var nameSort : recordSort = .none
    @State var costSort : recordSort = .none
    @State var selectDeleteID : UUID = UUID()
    @State var showCostInDayDate : Date = Date.now
    @State var costDayData : [eachAccounting] = [eachAccounting]()
    @State var costDayDataCategoryTotal : [eachCategoryCost] = [eachCategoryCost]()
    
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
            LazyVGrid(columns: gridItem) {
                Button {
                    print("sort")
                    if categorySort == .none {
                        categorySort = .ascending
                        nameSort = .none
                        costSort = .none
                        print(1)
                    } else if categorySort == .ascending {
                        categorySort = .descending
                        nameSort = .none
                        costSort = .none
                        print(2)
                    } else {
                        categorySort = .ascending
                        nameSort = .none
                        costSort = .none
                        print(2)
                    }
                } label: {
                    Image(systemName: "tray.full")
                        .imageScale(.large)
                    if categorySort == .none {
                        
                    } else if categorySort == .ascending {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    }
                }
                Button {
                    print("sort")
                    if nameSort == .none {
                        nameSort = .ascending
                        categorySort = .none
                        costSort = .none
                        print(1)
                    } else if nameSort == .ascending {
                        nameSort = .descending
                        categorySort = .none
                        costSort = .none
                        print(2)
                    } else {
                        categorySort = .none
                        nameSort = .ascending
                        costSort = .none
                        print(2)
                    }
                } label: {
                    Image(systemName: "textformat.abc")
                        .imageScale(.large)
                    if nameSort == .none {
                        
                    } else if nameSort == .ascending {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    }
                }
                Button {
                    print("sort")
                    if costSort == .none {
                        costSort = .ascending
                        categorySort = .none
                        nameSort = .none
                        print(1)
                    } else if costSort == .ascending {
                        costSort = .descending
                        categorySort = .none
                        nameSort = .none
                        print(2)
                    } else {
                        categorySort = .none
                        nameSort = .none
                        costSort = .ascending
                        print(2)
                    }
                } label: {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large)
                    if costSort == .none {
                        
                    } else if costSort == .ascending {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.large)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    }
                }
            }
            ScrollView {
                ForEach(eachAccountingList, id: \.self) { accounting in
                    if accounting.time.formatted(date: .numeric, time: .omitted) == dateSelected.formatted(date: .numeric, time: .omitted) {
                        let _ = print(accounting)
                        NavigationLink {
                            eachRecordNavigate(accounting: accounting, deleteID: $selectDeleteID)
                        } label: {
                            HStack {
                                Text(accounting.costCategory.returnText)
                                    .font(.system(size: 20))
                                    .padding(15)
                                    .frame(width: UIScreen.main.bounds.width/4)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .padding(.horizontal)
                                Spacer()
                                Text("\(accounting.costName)" as String)
                                    .font(.system(size: 20))
                                    .padding(15)
                                    .frame(width: UIScreen.main.bounds.width/4)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Spacer()
                                Text("\(accounting.cost)" as String)
                                    .font(.system(size: 20))
                                    .padding(15)
                                    .frame(width: UIScreen.main.bounds.width/4)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    
                            }
                            .padding(.bottom, 1)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.orange)
                            )
                        }

                    }
                    
                }
            }
            
            Spacer()
                .toolbar {
                    ToolbarItem {
                        Button {
                            print("plus")
                            showAccountingSheet.toggle()
                        } label: {
                            Label("新增紀錄", systemImage: "plus.app")
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
                .sheet(isPresented: $showAccountingSheet) {
                    
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
                        if UserDefaults.standard.object(forKey: "records") == nil {
                            var records = [eachAccounting]()
                            let record : eachAccounting = eachAccounting(costCategory: categorySelectedIndex, costName: costNameInput, cost: Int(cost) ?? 0, time: dateSelected, note: costMemo, itemPicture: selectPhotoData)
                            records.append(record)
                            if let encoded = try? JSONEncoder().encode(records) {
                                UserDefaults.standard.setValue(encoded, forKey: "records")
                            }
                            eachAccountingList = records
                            print(records)
                        }else {
                            if let data = UserDefaults.standard.object(forKey: "records") as? Data {
                                let raw = try? JSONDecoder().decode([eachAccounting].self, from: data)
                                var records : [eachAccounting] = raw!
                                let record : eachAccounting = eachAccounting(costCategory: categorySelectedIndex, costName: costNameInput, cost: Int(cost) ?? 0, time: dateSelected, note: costMemo, itemPicture: selectPhotoData)
                                records.append(record)
                                if let encoded = try? JSONEncoder().encode(records) {
                                    UserDefaults.standard.setValue(encoded, forKey: "records")
                                }
                                print(records)
                                eachAccountingList = records
                            }
                            
                        }
                        print("record")
                        showAccountingSheet = false
                        categorySelectedIndex = .food
                        costNameInput = ""
                        cost = ""
                        costMemo = ""
                        selectPhotoData = nil
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
                    eachAccountingList = eachAccountingList.filter({$0.id != newValue})
                    if let encoded = try? JSONEncoder().encode(eachAccountingList) {
                        UserDefaults.standard.setValue(encoded, forKey: "records")
                    }
                }
                .onChange(of: categorySort) { newValue in
                    if newValue == .ascending {
                        eachAccountingList.sort{$0.costCategory < $1.costCategory}
                    } else if newValue == .descending {
                        eachAccountingList.sort{$0.costCategory > $1.costCategory}
                    }
                }
                .onChange(of: nameSort) { newValue in
                    if newValue == .ascending {
                        eachAccountingList.sort{$0.costName < $1.costName}
                    } else if newValue == .descending {
                        eachAccountingList.sort{$0.costName > $1.costName}
                    }
                }
                .onChange(of: costSort) { newValue in
                    if newValue == .ascending {
                        eachAccountingList.sort{$0.cost < $1.cost}
                    } else if newValue == .descending {
                        eachAccountingList.sort{$0.cost > $1.cost}
                    }
                }
                
        }
        .onAppear {
            if let data = UserDefaults.standard.object(forKey: "records") as? Data {
                let raw = try? JSONDecoder().decode([eachAccounting].self, from: data)
                eachAccountingList = raw!
            }
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
    
    
    @ViewBuilder
    private var checkCostView : some View {
        NavigationStack {
            NavigationLink {
                dailyCostView
            } label: {
                HStack {
                    Spacer()
                    Text("以日檢視花費狀況")
                        .font(.system(size: 20))
                    Image(systemName: "arrowshape.right.fill")
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .opacity(0.4)
                )
                .padding(5)
            }
            NavigationLink {
                Text("1")
            } label: {
                HStack {
                    Spacer()
                    Text("以週檢視花費狀況")
                        .font(.system(size: 20))
                    Image(systemName: "arrowshape.right.fill")
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .opacity(0.4)
                )
                .padding(5)
            }
            NavigationLink {
                Text("1")
            } label: {
                HStack {
                    Spacer()
                    Text("以月檢視花費狀況")
                        .font(.system(size: 20))
                    Image(systemName: "arrowshape.right.fill")
                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .opacity(0.4)
                )
                .padding(5)
            }
            
        }
            .tabItem {
                Label("花費狀況", systemImage: "chart.bar")
            }
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
        Chart(costDayDataCategoryTotal) { item in
            BarMark(x: .value("類別", item.category.returnText), y: .value("花費", item.cost))
                .annotation(position: .automatic, alignment: .center, spacing: nil) {
                    Text(item.cost, format: .number)
                }
        }
        .onChange(of: showCostInDayDate) { newValue in
            costDayData = eachAccountingList.filter({
                $0.time.formatted(date: .numeric, time: .omitted) == newValue.formatted(date: .numeric, time: .omitted)
            })
            costDayDataCategoryTotal = buildCostCategoryArr()
            for data in costDayData {
                let index = costDayDataCategoryTotal.firstIndex(where: {$0.category == data.costCategory})
                costDayDataCategoryTotal[index!].cost += data.cost
            }
        }
        .onAppear {
            costDayData = eachAccountingList.filter({
                $0.time.formatted(date: .numeric, time: .omitted) == showCostInDayDate.formatted(date: .numeric, time: .omitted)
            })
            costDayDataCategoryTotal = buildCostCategoryArr()
            for data in costDayData {
                let index = costDayDataCategoryTotal.firstIndex(where: {$0.category == data.costCategory})
                costDayDataCategoryTotal[index!].cost += data.cost
            }
        }
        
        Spacer()
    }
    
}
func buildCostCategoryArr() -> [eachCategoryCost] {
    var list = [eachCategoryCost]()
    for cate in costCategory.allCases {
        list.append(eachCategoryCost(category: cate, cost: 0))
    }
    return list
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
