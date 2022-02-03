//
//  PrimaryButton.swift
//  FullCast
//
//  Created by Vishwa  R on 03/02/22.
//

import SwiftUI

struct PrimaryButton : View {
    
    var action : () -> ()
    var label : String
    
    var body : some View {
        Button(action: action) {
            Text(label)
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth : .infinity)
                .background(.yellow)
                .cornerRadius(12)
                .padding()
        }
    }
}
