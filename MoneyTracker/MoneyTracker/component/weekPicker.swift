//
//  weekPicker.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/9.
//

import SwiftUI

struct weekStruct {
    let lowerDate: Date
    let upperDate: Date
    let id: Int
}

struct weekPicker: View {
    @State var date = Date.now
    var weekArr = [weekStruct]()
    var calendar = Calendar(identifier: .gregorian)
    
    let tmpDateComponent = Calendar.current.dateComponents(in: .current, from: Calendar.current.date(byAdding: .day, value: -5, to: .now)!)
    var body: some View {
        VStack {
            Text(tmpDateComponent.weekOfYear?.description ?? "")
            Text(tmpDateComponent.weekOfMonth?.description ?? "")
            
        }
        .onAppear() {
            Task {
                await tmp(c: calendar)
            }
        }
    }
    func tmp(c: Calendar) async {
        let stopDate = Calendar.current.date(byAdding: .month, value: -3, to: .now)!
        var tmpArr = [weekStruct]()
        c.enumerateDates(startingAfter: .now, matching: DateComponents(hour: 8, weekday: 2), matchingPolicy: .strict, direction: .backward) { result, exactMatch, stop in
            if result! < stopDate {
                print("stop")
                stop = true
            }
            else {
                tmpArr.insert(weekStruct(lowerDate: result!, upperDate: Calendar.current.date(byAdding: .day, value: 6, to: result!)!, id: weekArr.count), at: 0)
            }
        }
        print(tmpArr.description)
    }
}

struct weekPicker_Previews: PreviewProvider {
    static var previews: some View {
        weekPicker()
    }
}
