//
//  weekPicker.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/9.
//

import SwiftUI

struct weekStruct: Identifiable {
    let lowerDate: Date
    let upperDate: Date
    let id: Int
}

class WeekLoader: ObservableObject {
    @Published var weekArray: [weekStruct] = []
    private var currentArrayLowerDate = Date.now
    init() {
        self.loadMoreWeek(c: Calendar(identifier: .gregorian))
    }
    func loadMoreWeek(c: Calendar) {
        let stopDate = Calendar.current.date(byAdding: .month, value: -3, to: currentArrayLowerDate)!
        let startDate = currentArrayLowerDate
        currentArrayLowerDate = stopDate
        var tmpArr = [weekStruct]()
        c.enumerateDates(startingAfter: startDate, matching: DateComponents(hour: 8, weekday: 2), matchingPolicy: .strict, direction: .backward) { result, exactMatch, stop in
            if result! < stopDate {
                print("stop")
                stop = true
            }
            else {
                let resultComponent = Calendar.current.dateComponents(in: .current, from: result!)
                tmpArr.insert(weekStruct(lowerDate: result!, upperDate: Calendar.current.date(byAdding: .day, value: 6, to: result!)!, id: resultComponent.year!*100 + resultComponent.weekOfYear!), at: 0)
            }
        }
        tmpArr = tmpArr + weekArray
        self.weekArray = tmpArr
//        print(weekArray.description)
    }
    func dateFormat(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        return dateFormatter.string(from: date)
    }
}
struct weekPickerButton: View {
    @StateObject var weekLoader = WeekLoader()
    @Binding var weekSelectedID: Date
    let calendar = Calendar(identifier: .gregorian)
    var body: some View {
        
        NavigationStack {
            NavigationLink {
                weekPicker(weekSelectedID: $weekSelectedID)
                    .environmentObject(weekLoader)
            } label: {
                Text(weekLoader.dateFormat(weekLoader.weekArray.first(where: { $0.lowerDate <= weekSelectedID && $0.upperDate >= weekSelectedID })!.lowerDate) + "-" + weekLoader.dateFormat(weekLoader.weekArray.first(where: { $0.lowerDate <= weekSelectedID && $0.upperDate >= weekSelectedID })!.upperDate))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        
            
        

    }
}
struct weekPicker: View {
    @EnvironmentObject var weekLoader: WeekLoader
    @Environment(\.presentationMode) var presentationMode
    @Binding var weekSelectedID: Date
    let calendar = Calendar(identifier: .gregorian)

    var body: some View {
        VStack {
            List {
                ForEach(weekLoader.weekArray) { week in
                    let combineStr = weekLoader.dateFormat(week.lowerDate) + "-" + weekLoader.dateFormat(week.upperDate)
                    Text(combineStr)
                        .onTapGesture {
                            print("select")
                            weekSelectedID = week.lowerDate
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }
            .refreshable {
                weekLoader.loadMoreWeek(c: calendar)
            }
        }
    }
}

//struct weekPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        weekPickerButton(weekSelectedID: .constant(.now))
//    }
//}
