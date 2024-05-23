//
//  DataController.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/15.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container = NSPersistentContainer(name: "accounting")
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func getData(nsPredicate: NSPredicate) -> [Accounting] {
        let request = NSFetchRequest<Accounting>(entityName: "Accounting")
        request.predicate = nsPredicate
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("cannot load data")
            return []
        }
    }
    func addData(categorySelectedIndex: costCategory, costNameInput: String, cost: String, dateSelected: Date, costMemo: String, selectPhotoData: Data?, year: Int, month: Int, day: Int, weekOfYear: Int) {
        let newData = Accounting(context: container.viewContext)
        newData.id = UUID()
        newData.costCategory = categorySelectedIndex.returnText
        newData.costName = costNameInput
        newData.cost = Int32(cost)!
        newData.time = dateSelected
        newData.note = costMemo
        newData.itemPicture = selectPhotoData
        newData.year = Int16(year)
        newData.month = Int16(month)
        newData.day = Int16(day)
        newData.weekOfYear = Int16(weekOfYear)
        saveData()
    }
    func saveData() {
        
        do {
            try container.viewContext.save()
        } catch {
            print(error.localizedDescription)
            container.viewContext.rollback()
        }
    }
    func deleteData(selectedID: UUID) {
        do {
            let data = try container.viewContext.fetch(Accounting.fetchRequest())
            let targetData = data.first(where: {$0.id == selectedID})
            if let targetData {
                container.viewContext.delete(targetData)
            }
            saveData()
        } catch {
            print(error.localizedDescription)
            container.viewContext.rollback()
        }
    }
}
