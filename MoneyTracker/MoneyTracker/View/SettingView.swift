//
//  SettingView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/20.
//

import SwiftUI

struct SettingView: View {
    @State var settingGoatMode: settingGoatMode = .day
    @State var showSettingAlert = false
    @State var showSettingError = false
    @State var input = ""
    @StateObject var upperBoundManager = SpendUpperBoundManager()
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Divider()
                Button {
                    showSettingAlert.toggle()
                    settingGoatMode = .day
                } label: {
                    
                    Group {
                        Text("設定每日目標")
                        Image(systemName: "arrowshape.turn.up.right.fill")
                        Color.clear
                            .frame(height: 40)
                    }
                    .font(.system(size: 25))
                }
                .padding(.leading)
                Divider()
                Button {
                    showSettingAlert.toggle()
                    settingGoatMode = .week
                } label: {
                    
                    Group {
                        Text("設定每週目標")
                        Image(systemName: "arrowshape.turn.up.right.fill")
                        Color.clear
                            .frame(height: 40)
                    }
                    .font(.system(size: 25))
                }
                .padding(.leading)
                Divider()
                Button {
                    showSettingAlert.toggle()
                    settingGoatMode = .month
                } label: {
                    
                    Group {
                        Text("設定每月目標")
                        Image(systemName: "arrowshape.turn.up.right.fill")
                        Color.clear
                            .frame(height: 40)
                    }
                    .font(.system(size: 25))
                }
                .padding(.leading)
                Divider()
                NavigationLink( destination: {
                    Text("問題回報:")
                    Link("rex901023wot@gmail.com", destination: URL(string: "mailto:rex901023wot@gmail.com")!)
                }, label: {
                    
                    Group {
                        Text("關於")
                        Image(systemName: "info.circle")
                        Color.clear
                            .frame(height: 40)
                    }
                    .font(.system(size: 25))
                })
                .padding(.leading)
                Spacer()
                
            }
            .alert(settingGoatMode.text, isPresented: $showSettingAlert) {
                TextField("", text: $input, prompt: Text(settingGoatMode.text))
                Button("確定", role: .cancel) {
                    if SpendUpperBoundManager.checkIsInteger(strInput: input) {
                        upperBoundManager.setUpperBound(mode: settingGoatMode, value: Int(input)!)
                        input = ""
                    }
                    else {
                        showSettingError.toggle()
                    }
                }
                Button("取消", role: .destructive) {
                    // do nothing
                    input = ""
                }
            }
            .alert("請輸入十進位數字", isPresented: $showSettingError) {
                Button("OK", role: .cancel) {
                    
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .navigationTitle("設定")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.orange, for: .navigationBar)
        }
            .tabItem {
                Label("設定", systemImage: "gear")
            }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
