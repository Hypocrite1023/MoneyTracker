//
//  ContentView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/3/21.
//

import SwiftUI
import PhotosUI
import Charts

struct ContentView: View {
    
    var body: some View {
        TabView {
            //記帳頁面
            MoneyAccountingView()
            
            //詳細資料頁面
            CheckCostView()
            
            //設定
            SettingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, DataController.shared.container.viewContext)
    }
}
