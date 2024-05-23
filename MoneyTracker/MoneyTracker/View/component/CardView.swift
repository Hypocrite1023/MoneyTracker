//
//  CardView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/23.
//

import SwiftUI

struct CardView: View {
    let lhsTitle: String
    let rhsTitle: String
    var body: some View {
        HStack {
            Text(lhsTitle)
                .frame(width: UIScreen.main.bounds.width/2-20)
                .foregroundColor(.white)
                .font(.system(size: 25))
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.orange)
                )
            Divider()
                .frame(height: 20)
            Text(rhsTitle)
                .frame(width: UIScreen.main.bounds.width/2-20)
                .foregroundColor(.white)
                .font(.system(size: 25))
                .padding(.vertical, 25)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.orange)
                )
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(lhsTitle: "週總支出:", rhsTitle: "125")
            .previewLayout(.sizeThatFits)
    }
}
