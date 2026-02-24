//
//  RecordRowView.swift
//  BrewLog
//

import SwiftUI

/// 记录列表行视图
struct RecordRowView: View {
    let record: BrewRecord

    var body: some View {
        HStack(spacing: 12) {
            // 方式图标
            MethodIcon(method: record.method)

            // 内容区域
            VStack(alignment: .leading, spacing: 4) {
                // 标题行：方式 + 时间
                HStack {
                    Text(record.method.displayName)
                        .font(.headline)
                    Spacer()
                    Text(record.date.displayDateTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // 咖啡豆名称
                if !record.coffeeBean.isEmpty {
                    Text(record.coffeeBean)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // 参数摘要 + 评分
                HStack {
                    Text(record.parameterSummary)
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Spacer()

                    if record.rating > 0 {
                        StarRatingDisplay(rating: record.rating, size: 12)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = [
            record.method.displayName,
            record.date.displayDateTime
        ]
        if !record.coffeeBean.isEmpty {
            parts.append(record.coffeeBean)
        }
        if record.rating > 0 {
            parts.append("评分\(record.rating)星")
        }
        return parts.joined(separator: "，")
    }
}

// MARK: - Preview
#Preview {
    List {
        RecordRowView(record: {
            let record = BrewRecord(method: .espresso, coffeeBean: "埃塞俄比亚 耶加雪菲")
            record.rating = 4
            record.espressoDose = 18
            record.espressoYield = 36
            record.espressoTime = 25
            return record
        }())

        RecordRowView(record: {
            let record = BrewRecord(method: .pourOver, coffeeBean: "哥伦比亚 慧兰")
            record.rating = 5
            record.pourOverDose = 15
            record.pourOverWater = 250
            record.pourOverTime = 180
            return record
        }())

        RecordRowView(record: {
            let record = BrewRecord(method: .mokaPot, coffeeBean: "巴西 喜拉多")
            record.rating = 3
            record.mokaDose = 20
            record.mokaWater = 120
            record.mokaHeat = .medium
            return record
        }())
    }
    .listStyle(.insetGrouped)
}
