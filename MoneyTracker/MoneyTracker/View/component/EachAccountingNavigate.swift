//
//  EachAccountingNavigate.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import SwiftUI

struct EachRecordNavigate : View {
    let accounting : eachAccounting
    @Binding var inputDeleteID: UUID
    @Binding var showDay: Date
    @Environment(\.presentationMode) var presentationMode
    @State var showAlert = false
    @State var deleteID = UUID()
    var body: some View {
        VStack {
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
                Button {
                    deleteID = accounting.id
                    showAlert = true
                    
                } label: {
                    Text("刪除紀錄")
                        .tint(.red)
                }
                .frame(width: UIScreen.main.bounds.width, alignment: .center)
            }
            .padding(.top)
            
        }
        .alert("確定要刪除這筆記帳資料嗎", isPresented: $showAlert) {
            Button("確定", role: .destructive) {
//                EachAccountingViewModel.accountingManager.deleteRecord(deleteID: deleteID)
//                let component = Calendar.current.dateComponents(in: .current, from: showDay)
//                let nsPredicate = NSPredicate(format: "year == %d && month == %d && day == %d", component.year!, component.month!, component.day!)
//                EachAccountingViewModel.accountingManager.getRecord(nsPredicate: nsPredicate)
//                print("changeData")
                inputDeleteID = deleteID
                showAlert.toggle()
                presentationMode.wrappedValue.dismiss()
            }
            Button("取消", role: .cancel) {
                showAlert.toggle()
            }
        }
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    print("delete")
//                    deleteID = accounting.id
//                    presentationMode.wrappedValue.dismiss()
//                } label: {
//                    Image(systemName: "trash")
//                }
//
//            }
//        }
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
