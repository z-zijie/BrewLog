//
//  MethodBadge.swift
//  BrewLog
//

import SwiftUI

/// 冲煮方式徽章组件
struct MethodBadge: View {
    let method: BrewMethod
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }

        var textFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 10)
            case .large: return EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 12)
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: method.iconName)
                .font(.system(size: size.iconSize, weight: .medium))
            Text(method.displayName)
                .font(size.textFont)
                .fontWeight(.medium)
        }
        .foregroundStyle(method.color)
        .padding(size.padding)
        .background(method.color.opacity(0.12))
        .clipShape(Capsule())
        .accessibilityLabel("冲煮方式：\(method.displayName)")
    }
}

/// 方式图标（简化版）
struct MethodIcon: View {
    let method: BrewMethod
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: method.iconName)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(method.color)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .accessibilityLabel(method.displayName)
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack {
            MethodBadge(method: .espresso)
            MethodBadge(method: .pourOver)
            MethodBadge(method: .mokaPot)
        }

        HStack {
            MethodBadge(method: .espresso, size: .small)
            MethodBadge(method: .pourOver, size: .large)
        }

        HStack(spacing: 8) {
            MethodIcon(method: .espresso)
            MethodIcon(method: .pourOver)
            MethodIcon(method: .mokaPot)
        }
    }
    .padding()
}
