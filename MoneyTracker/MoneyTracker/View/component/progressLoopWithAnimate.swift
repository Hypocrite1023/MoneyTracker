//
//  progressLoopWithAnimate.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/4.
//

import SwiftUI

extension UIColor {
    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}


struct progressLoopWithAnimate: View {
    let size: CGFloat
    @Binding var percent: Double
    var body: some View {
        ZStack {
            Text("\(percent*100, specifier: "%.2f")%")
//            Text(CGFloat(percent), format: .percent)
                .bold()
                .font(.system(size: 20))
            Circle()
                .stroke( // 1
                    Color(CGFloat(percent)>=0.5 ? (CGFloat(percent)>=0.7 ? (CGFloat(percent)>=0.9 ? .red : .orange) : .yellow) : .green).opacity(0.3),
                    lineWidth: 10
                )
                .frame(width: size, height: size)
            Circle() // 2
                .trim(from: 0, to: CGFloat(percent))
                .stroke(
//                    Color(UIColor.blend(color1: .red, intensity1: now/total, color2: .orange, intensity2: (total-now)/total)),
                    Color(CGFloat(percent)>=0.5 ? (CGFloat(percent)>=0.7 ? (CGFloat(percent)>=0.9 ? .red : .orange) : .yellow) : .green),
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
        }
    }
}

//struct progressLoopWithAnimate_Previews: PreviewProvider {
//    static var previews: some View {
//        progressLoopWithAnimate(size: CGFloat(200), total: 100, cost: 10)
//    }
//}
