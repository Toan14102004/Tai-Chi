//
//  TabbarShape.swift
//  Taichi
//
//  Created by Toan Nguyen on 21/1/26.
//

import Foundation
import SwiftUI

struct TabbarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        let curveHeight: CGFloat = 38
        let curveWidth: CGFloat = 85
        let topY = curveHeight
        let midX = w / 2

        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: w, y: topY))
        
        path.addLine(to: CGPoint(x: midX + curveWidth, y: topY))
        
        path.addCurve(
            to: CGPoint(x: midX, y: 0),
            control1: CGPoint(x: midX + curveWidth / 1.8, y: topY),
            control2: CGPoint(x: midX + curveWidth / 2.5, y: 0)
        )
        
        path.addCurve(
            to: CGPoint(x: midX - curveWidth, y: topY),
            control1: CGPoint(x: midX - curveWidth / 2.5, y: 0),
            control2: CGPoint(x: midX - curveWidth / 1.8, y: topY)
        )
        
        path.addLine(to: CGPoint(x: 0, y: topY))
        path.closeSubpath()
        
        return path
    }
}

struct SmoothTopBumpShape: Shape {
    /// Chiều cao của phần nhô lên tính từ cạnh trên phẳng.
    var bumpHeight: CGFloat
    
    /// Độ rộng tổng thể của phần nhô lên tại chân của nó.
    /// Cần tham số này để tính toán độ cong hợp lý.
    var bumpWidth: CGFloat
    
    // Làm cho các tham số có thể tạo animation mượt mà
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(bumpHeight, bumpWidth) }
        set {
            bumpHeight = newValue.first
            bumpWidth = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Xác định các mốc tọa độ Y
        // Đỉnh cao nhất của phần nhô lên sẽ là minY (thường là 0)
        let peakY = rect.minY
        // Phần vai phẳng sẽ thấp hơn đỉnh một khoảng bằng bumpHeight
        let shoulderY = rect.minY + bumpHeight
        let bottomY = rect.maxY
        
        // Xác định các mốc tọa độ X
        let centerX = rect.midX
        let startBumpX = centerX - (bumpWidth / 2)
        let endBumpX = centerX + (bumpWidth / 2)
        
        // Bắt đầu vẽ
        
        // 1. Điểm bắt đầu: Góc trên bên trái (Sắc cạnh)
        path.move(to: CGPoint(x: rect.minX, y: shoulderY))
        
        // 2. Vẽ đường thẳng đến điểm bắt đầu của phần nhô lên
        path.addLine(to: CGPoint(x: startBumpX, y: shoulderY))
        
        // --- Bắt đầu vẽ phần nhô lên mượt mà ---
        // Sử dụng 2 đường cong Cubic Bezier để đảm bảo độ mượt (C1 continuity)
        // Offset cho điểm điều khiển để tạo độ cong tự nhiên.
        // Giá trị này càng lớn thì đường cong càng "béo" ra.
        let controlOffsetX = bumpWidth * 0.25
        
        // Đường cong 1: Từ chân trái lên đỉnh
        // Control Point 1: Có cùng Y với chân để tiếp tuyến nằm ngang (nối mượt với vai)
        // Control Point 2: Có cùng Y với đỉnh để đỉnh tròn trịa.
        path.addCurve(to: CGPoint(x: centerX, y: peakY),
                      control1: CGPoint(x: startBumpX + controlOffsetX, y: shoulderY),
                      control2: CGPoint(x: centerX - controlOffsetX, y: peakY))
        
        // Đường cong 2: Từ đỉnh xuống chân phải (đối xứng)
        path.addCurve(to: CGPoint(x: endBumpX, y: shoulderY),
                      control1: CGPoint(x: centerX + controlOffsetX, y: peakY),
                      control2: CGPoint(x: endBumpX - controlOffsetX, y: shoulderY))
        // --- Kết thúc phần nhô lên ---
        
        
        // 3. Vẽ đường thẳng đến góc trên bên phải (Sắc cạnh)
        path.addLine(to: CGPoint(x: rect.maxX, y: shoulderY))
        
        // 4. Vẽ cạnh bên phải xuống góc dưới phải (Sắc cạnh)
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY))
        
        // 5. Vẽ cạnh đáy sang góc dưới trái (Sắc cạnh)
        path.addLine(to: CGPoint(x: rect.minX, y: bottomY))
        
        // 6. Đóng path (tự động vẽ đường thẳng về điểm bắt đầu ở góc trên trái)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview để kiểm tra
struct SmoothBumpPreviewView: View {
    // Các tham số mặc định để tạo hình giống ảnh gốc
    @State private var height: CGFloat = 40
    @State private var width: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Nền sáng để dễ nhìn shape tối màu
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 50) {
                Text("Kết quả Shape")
                    .font(.headline)
                    .foregroundColor(.black)
                
                // Shape chính
                SmoothTopBumpShape(bumpHeight: height, bumpWidth: width)
                    // Màu xám đen đậm gần giống ảnh gốc
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                    .frame(height: 150) // Chiều cao tổng của view chứa shape
                    .padding(.horizontal, 20)
                    // Thêm shadow nhẹ để tạo chiều sâu giống ảnh gốc
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                
                // Shape dạng viền để kiểm tra kỹ các góc sắc
                SmoothTopBumpShape(bumpHeight: height, bumpWidth: width)
                    .stroke(Color.red, lineWidth: 2)
                    .frame(height: 150)
                    .padding(.horizontal, 20)
                    .overlay(Text("Chế độ viền (kiểm tra góc)").font(.caption).foregroundColor(.red).offset(y: 90))

                
                // Khu vực điều chỉnh tham số
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Chiều cao phần nhô (bumpHeight): \(Int(height))")
                            .foregroundColor(.black)
                        Slider(value: $height, in: 10...80)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Độ rộng phần nhô (bumpWidth): \(Int(width))")
                            .foregroundColor(.black)
                        Slider(value: $width, in: 50...250)
                        Text("(Điều chỉnh độ rộng để thay đổi độ dốc của đường cong)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    SmoothBumpPreviewView()
}
//
//#Preview {
//    HumpShape(humpHeight: 25)
//        .fill(Color(hex: "#1C1C1C"))
//        .frame(height: 60 + 25)
//        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: -5)
//}
