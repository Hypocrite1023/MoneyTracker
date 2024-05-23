# MoneyTracker 
<img width="200" height="450" src="https://github.com/Hypocrite1023/MoneyTracker/blob/useCoreData/demo/IMG_0879.PNG">
<img width="200" height="450" src="https://github.com/Hypocrite1023/MoneyTracker/blob/useCoreData/demo/IMG_0881.PNG">
<img width="200" height="450" src="https://github.com/Hypocrite1023/MoneyTracker/blob/useCoreData/demo/IMG_0882.PNG">

## 2024/05/23
### 基本的功能都寫好了，相機拍照部分等UIKit比較熟後再處理
> NSPredicate->從core data抓資料會用到，類似資料庫語法
```
let request = NSFetchRequest<Accounting>(entityName: "Accounting")
request.predicate = NSPredicate(format: "year == %d AND month == %d AND day == %d", dateComponent.year!, dateComponent.month!, dateComponent.day!)
do {
    return try container.viewContext.fetch(request)
} catch {
    print("cannot load data")
    return []
}
```
> 使用ios 16.0在使用DatePicker上使用graphical style會有問題
>> <https://stackoverflow.com/questions/73475000/datepicker-with-graphical-style-breaks-layout-constraints-on-ios-16-0>
>> 想使用UICalendarView自己建picker或使用第三方套件

## 2024/05/15
> 資料有修改可使用didset接儲存函數
```
@Published var eachAccountingList : [eachAccounting] = [eachAccounting]() {
    didSet {
        saveRecord()
    }
}
```
> 預計使用Core Data儲存資料
---
## 功能  
> 紀錄每日花費  
> 花費可以週、月、年產生圖表  
> 可拍照紀錄花費物品  
> ...  
