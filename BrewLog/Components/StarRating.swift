//
//  StarRating.swift
//  BrewLog
//

import SwiftUI
import UIKit

/// 星级评分组件（1-5星）
struct StarRating: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 28
    var editable: Bool = true

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// 触感反馈生成器
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                starView(for: star)
                    .frame(width: 44, height: 44) // Apple HIG: 最小触控区域 44pt
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard editable else { return }
                        // 触感反馈
                        selectionFeedback.selectionChanged()
                        withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                            rating = star
                        }
                    }
            }
        }
        // 无障碍支持
        .accessibilityElement(children: .combine)
        .accessibilityLabel("评分：\(rating) 星")
        .accessibilityHint(editable ? "上下滑动调整评分" : "当前评分")
        .accessibilityAdjustableAction { direction in
            guard editable else { return }
            switch direction {
            case .increment:
                if rating < maxRating {
                    selectionFeedback.selectionChanged()
                    rating += 1
                }
            case .decrement:
                if rating > 1 {
                    selectionFeedback.selectionChanged()
                    rating -= 1
                }
            @unknown default:
                break
            }
        }
    }

    @ViewBuilder
    private func starView(for star: Int) -> some View {
        Image(systemName: star <= rating ? "star.fill" : "star")
            .font(.system(size: size))
            .foregroundStyle(star <= rating ? Color.starFill : Color.gray.opacity(0.3))
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
                    .foregroundStyle(star <= rating ? Color.starFill : Color.gray.opacity(0.3))
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
