# MoneyTracker 
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
