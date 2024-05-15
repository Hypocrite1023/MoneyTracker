//
//  fontflip.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/4/27.
//

import SwiftUI

struct fontflip: View {
    let character = "H"
    @State var flip = false
    var body: some View {
        VStack {
            Text(character)
                .rotation3DEffect(Angle(degrees: flip ? 360 : 0), axis: (x: 1.0, y: 1.0, z: 0.0))
                  
                
            Button("click") {
                withAnimation{
                    flip.toggle()
                }
            }
        }
    }
}

struct fontflip_Previews: PreviewProvider {
    static var previews: some View {
        fontflip()
    }
}
