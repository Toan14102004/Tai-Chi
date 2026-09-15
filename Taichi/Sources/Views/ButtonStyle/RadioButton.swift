//
//  RadioButton.swift
//  Taichi
//
//  Created by Minh Hieu on 22/9/25.
//

import SwiftUI

struct RadioButton: View {
    @Binding var isSelected: Bool
    var size: CGFloat = Layout.Icon.medium
    var action: () -> Void

    var body: some View {
        Button {
            isSelected.toggle()
            action()
        } label: {
            ZStack {
                Circle()
                    .stroke(isSelected ? Asset.Color.mainColor.color : Asset.Color.white.color.opacity(0.3), lineWidth: 1.2)
                    .frame(width: 21.iPad(23), height: 21.iPad(23))
                                
                if isSelected {
                    Circle()
                        .fill(Asset.Color.mainColor.color)
                        .frame(width: 17.iPad(19), height: 17.iPad(19))
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
            RadioButton(isSelected: $isSelected) {
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
}

#Preview {
    PreviewView()
}
