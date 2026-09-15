//
//  RadioButton.swift
//  Taichi
//
//  Created by Minh Hieu on 22/9/25.
//

import SwiftUI

struct CheckmarkButton: View {
    @Binding var isSelected: Bool
    var size: CGFloat = Layout.Icon.medium
    var action: () -> Void

    var body: some View {
        Button {
            isSelected.toggle()
            action()
        } label: {
            ZStack {
                if isSelected {
                    Asset.Icon.Commo.checkmarkCircle.image
                        .toIcon(size)
                } else {
                    Asset.Icon.Commo.circle.image
                        .toIcon(size)
                }
            }
            .animation(.easeInOut, value: isSelected)
            .transition(.asymmetric(insertion: .opacity, removal: .opacity))
        }

    }
}

fileprivate struct PreviewView: View {
    
    @State var isSelected: Bool = false
    
    var body: some View {
        VStack {
            CheckmarkButton(isSelected: $isSelected) {
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

#Preview {
    Text("avbc")
}
