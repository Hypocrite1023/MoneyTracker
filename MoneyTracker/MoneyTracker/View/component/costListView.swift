//
//  SwiftUIView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/4/26.
//

import SwiftUI



struct costListView: View {
    let category : costCategory
    let costName : String
    let cost : Int
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: .init(lineWidth: 3))
                .fill(.orange)
                .padding(.leading, 5)
                .frame(width: 80, height: 60)
                .overlay {
                    category.label
                        .labelStyle(.iconOnly)
                        .foregroundColor(.orange)
                        .font(.largeTitle)
                }
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: .init(lineWidth: 3))
                .fill(.green)
                .frame(width: .infinity, height: 60)
                .overlay {
                    Text(costName)
                        .font(.headline)
                }
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: .init(lineWidth: 3))
                .fill(.blue)
                .padding(.trailing, 5)
                .frame(width: 150, height: 60)
                .overlay {
                    Text("\(cost)")
                        .font(.headline)
                }
        }
            
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        costListView(category: .entertainment, costName: "白米糙米", cost: 110)
    }
}
