//
//  ContentView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/3/21.
//

import SwiftUI
import PhotosUI

enum costCategory : CaseIterable, Codable {
    case food
    case entertainment
    var label : some View {
        switch(self) {
        case .food: return Label("飲食", systemImage: "fork.knife.circle")
        case .entertainment: return Label("娛樂", systemImage: "party.popper")
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

struct eachAccounting : Codable, Hashable {
    let costCategory : costCategory
    let costName : String
    let cost: Int
    let time : Date
    let note : String
    let itemPicture : Data?
    var id : UUID = UUID()
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
    @State var categorySort : recordSort = .none
    @State var nameSort : recordSort = .none
    @State var costSort : recordSort = .none
    var body: some View {
        TabView {
            moneyAccountingView
            checkCostView
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
                        print(1)
                    } else if categorySort == .ascending {
                        categorySort = .descending
                        print(2)
                    } else {
                        categorySort = .none
                        print(3)
                    }
                } label: {
                    Image(systemName: "tray.full")
                        .imageScale(.large)
                    if categorySort == .none {
                        
                    } else if categorySort == .ascending {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.large)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.large)
                    }
                }
                Button {
                    print("sort")
                    if nameSort == .none {
                        nameSort = .ascending
                        print(1)
                    } else if nameSort == .ascending {
                        nameSort = .descending
                        print(2)
                    } else {
                        nameSort = .none
                        print(3)
                    }
                } label: {
                    Image(systemName: "textformat.abc")
                        .imageScale(.large)
                    if nameSort == .none {
                        
                    } else if nameSort == .ascending {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.large)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.large)
                    }
                }
                Button {
                    print("sort")
                    if costSort == .none {
                        costSort = .ascending
                        print(1)
                    } else if costSort == .ascending {
                        costSort = .descending
                        print(2)
                    } else {
                        costSort = .none
                        print(3)
                    }
                } label: {
                    Image(systemName: "dollarsign.circle.fill")
                        .imageScale(.large)
                    if costSort == .none {
                        
                    } else if costSort == .ascending {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.large)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.large)
                    }
                }
            }
            ScrollView {
                LazyVGrid(columns: gridItem) {
                    ForEach(eachAccountingList, id: \.self) {
                        accounting in
                        if accounting.time.formatted(date: .numeric, time: .omitted) == dateSelected.formatted(date: .numeric, time: .omitted) {
                            let _ = print(accounting)
                            eachRecordNavigate(accounting: accounting, labelStr: "\(accounting.costCategory)" as String)
                            eachRecordNavigate(accounting: accounting, labelStr: "\(accounting.costName)" as String)
                            eachRecordNavigate(accounting: accounting, labelStr: "\(accounting.cost)" as String)
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            let domain = Bundle.main.bundleIdentifier!
                            UserDefaults.standard.removePersistentDomain(forName: domain)
                            UserDefaults.standard.synchronize()
                        } label: {
                            Label("清除紀錄", systemImage: "xmark.circle")
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
        Text("檢視花費狀況")
            .tabItem {
                Label("花費狀況", systemImage: "chart.bar")
            }
    }
}

struct eachRecordNavigate : View {
    let accounting : eachAccounting
    let labelStr : String
    var body: some View {
        NavigationLink {
            Form {
                HStack {
                    Label("類別", systemImage: "folder.fill.badge.gearshape")
                    Spacer()
                    Text("\(accounting.costCategory)" as String)
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
        } label: {
            Text(labelStr)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
