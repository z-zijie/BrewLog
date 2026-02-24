//
//  StarRating.swift
//  BrewLog
//

import SwiftUI

/// 星级评分组件（1-5星）
struct StarRating: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 28
    var editable: Bool = true

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                starView(for: star)
                    .frame(width: 44, height: 44) // Apple HIG: 最小触控区域 44pt
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard editable else { return }
                        withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                            rating = star
                        }
                    }
                    .accessibilityLabel("评分：\(star) 星")
                    .accessibilityHint(editable ? "双击设置评分" : "当前评分：\(rating) 星")
            }
        }
    }

    @ViewBuilder
    private func starView(for star: Int) -> some View {
        Image(systemName: star <= rating ? "star.fill" : "star")
            .font(.system(size: size))
            .foregroundStyle(star <= rating ? .yellow : .gray.opacity(0.3))
            .symbolEffect(.bounce, value: rating)
    }
}

/// 只读星级评分显示
struct StarRatingDisplay: View {
    let rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 16

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(star <= rating ? .yellow : .gray.opacity(0.3))
            }
        }
        .accessibilityLabel("评分：\(rating) 星")
    }
}

#Preview {
    VStack(spacing: 20) {
        StarRating(rating: .constant(3))
        StarRating(rating: .constant(0), editable: false)
        StarRatingDisplay(rating: 4)
    }
    .padding()
}
