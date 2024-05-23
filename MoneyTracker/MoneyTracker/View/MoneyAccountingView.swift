//
//  MoneyAccountingView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import SwiftUI
import PhotosUI

struct MoneyAccountingView: View {
    //Form設定的資料
    @State var dateSelected = Date.now
    @State var categorySelectedIndex: costCategory = .food
    @State var costNameInput: String = ""
    @State var cost: String = ""
    @State var costMemo: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State var selectPhotoData: Data?
    //顯示記帳頁面Bool
    @State var showAccountingSheet = false
    //以電子發票記錄
    @State var addRecord: Bool = false
    @State var qrCodeResult: String = ""
    //每紀錄一筆 將TextField資料清空
    func clearInputField() {
        self.categorySelectedIndex = .food
        self.costNameInput = ""
        self.cost = ""
        self.costMemo = ""
        self.selectPhotoData = nil
        self.qrCodeResult = ""
    }
    
    //ViewModel實例
    @StateObject var eachAccountingList = EachAccountingViewModel()
    @StateObject var eachCategoryCost = EachCategoryCost()
    //刪除記錄用到的ID
    @State var selectDeleteID: UUID = UUID()
    @State var dayInfoXOffset = -UIScreen.main.bounds.width
    @State var weekInfoXOffset = -UIScreen.main.bounds.width
    @State var monthInfoXOffset = -UIScreen.main.bounds.width
    
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    
    
    var body: some View {
        NavigationStack {
            
            DatePicker(selection: $dateSelected, displayedComponents: .date) {
                HStack {
                    Spacer()
                    Text("記\n帳\n日\n期")
                        .font(.system(size: 30))
                        .padding(.leading)
                    Spacer()
                }
            }
                .labelStyle(.titleAndIcon)
                .datePickerStyle(.wheel)
                .background(.orange)
            
            CardView(lhsTitle: "日總支出", rhsTitle: String(eachAccountingList.costThisDay))
                .offset(x: dayInfoXOffset)
                .onAppear() {
                    dayInfoXOffset = -UIScreen.main.bounds.width
                    withAnimation(Animation.easeIn(duration: 0.5)) {
                        dayInfoXOffset += UIScreen.main.bounds.width
                        
                    }
                }
            CardView(lhsTitle: "週總支出", rhsTitle: String(eachAccountingList.costThisWeek))
                .padding(.horizontal)
                .offset(x: weekInfoXOffset)
                .onAppear() {
                    weekInfoXOffset = -UIScreen.main.bounds.width
                    withAnimation(Animation.easeIn(duration: 0.5).delay(0.5)) {
                        weekInfoXOffset += UIScreen.main.bounds.width
                        
                    }
                }
            CardView(lhsTitle: "月總支出", rhsTitle: String(eachAccountingList.costThisMonth))
                .padding(.horizontal)
                .offset(x: monthInfoXOffset)
                .onAppear() {
                    monthInfoXOffset = -UIScreen.main.bounds.width
                    withAnimation(Animation.easeIn(duration: 0.5).delay(1)) {
                        monthInfoXOffset += UIScreen.main.bounds.width
                        
                    }
                }
                        
            Spacer()
                .toolbar {
                    ToolbarItem {
                        HStack {
                            Button {
                                showAccountingSheet.toggle()
                            } label: {
                                Label("新增紀錄", systemImage: "plus.app")
                                    .labelStyle(.titleAndIcon)
                            }
                            Divider()
                            Button {
                                addRecord.toggle()
                            } label: {
                                Label("透過電子發票新增紀錄", systemImage: "plus.app")
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                    }
                }
                .sheet(isPresented: $addRecord) {
                    //QRCodeScanner沒掃出結果
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
                        let dateComponentRe = Calendar.current.dateComponents(in: .current, from: date!)
                        let memo = result.code + "\n" + result.detail.description
                        TabView {
                            
                            Form {
                                
                                HStack {
                                    Label("類別", systemImage: "folder.fill.badge.gearshape")
                                    Spacer()
                                    Image(systemName: "arrow.up.doc.fill")
                                    Text("電子發票導入")
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
                                    Text(memo)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .onAppear {
                            costNameInput = "電子發票導入"
                        }
                        HStack {
                            Button {
//                                eachAccountingList.addRecord(categorySelectedIndex: .invoice, costNameInput: costNameInput, cost: String(result.total), dateSelected: date!, costMemo: result.detail.description, selectPhotoData: nil)
                                eachAccountingList.addRecord(categorySelectedIndex: .invoice, costNameInput: costNameInput, cost: String(result.total), dateSelected: dateSelected, costMemo: memo, selectPhotoData: selectPhotoData, year: dateComponent.year!, month: dateComponent.month!, day: dateComponent.day!, weekOfYear: dateComponentRe.weekOfYear!)
                                eachAccountingList.filterCostByDay(dateInput: .now)
                                eachAccountingList.filterCostByWeek(dateInput: .now)
                                eachAccountingList.filterCostByMonth(dateInput: .now)
                                addRecord = false
                                clearInputField()
                            } label: {
                                Label("記錄", systemImage: "square.and.pencil")
                            }.buttonStyle(.borderedProminent)
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
//                                    Spacer()
//                                    Button {
//                                        print("share")
//                                        showCamera.toggle()
//                                        DispatchQueue.global().async {
//                                            CameraManager.current.session.startRunning()
//                                        }
//
//                                    } label: {
//                                        HStack {
//                                            Image(systemName: "camera.shutter.button")
//                                            Text("拍照")
//                                        }
//                                    }
                                }
                            }
                        }
                    }
//                    .fullScreenCover(isPresented: $showCamera) {
//                        CameraView(showCamera: $showCamera)
//                    }
                    
                    Button {
//                        eachAccountingList.addRecord(categorySelectedIndex: categorySelectedIndex, costNameInput: costNameInput, cost: cost, dateSelected: dateSelected, costMemo: costMemo, selectPhotoData: selectPhotoData)
                        showAccountingSheet = false
                        
                        let dateComponent = Calendar.current.dateComponents(in: .current, from: dateSelected)
                        eachAccountingList.addRecord(categorySelectedIndex: categorySelectedIndex, costNameInput: costNameInput, cost: cost, dateSelected: dateSelected, costMemo: costMemo, selectPhotoData: selectPhotoData, year: dateComponent.year!, month: dateComponent.month!, day: dateComponent.day!, weekOfYear: dateComponent.weekOfYear!)
                        eachAccountingList.filterCostByDay(dateInput: .now)
                        eachAccountingList.filterCostByWeek(dateInput: .now)
                        eachAccountingList.filterCostByMonth(dateInput: .now)
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
//            eachAccountingList.getRecord()
            eachAccountingList.filterCostByDay(dateInput: .now)
            eachAccountingList.filterCostByWeek(dateInput: .now)
            eachAccountingList.filterCostByMonth(dateInput: .now)
        }
        .tabItem {
            Label("記帳", systemImage: "dollarsign.circle")
        }
    }
}

struct MoneyAccountingView_Previews: PreviewProvider {
    static var previews: some View {
        MoneyAccountingView()
    }
}
