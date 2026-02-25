//
//  ParameterField.swift
//  BrewLog
//

import SwiftUI
import UIKit

/// 参数滑块组件（带单位）
/// 将键盘输入改为滑块操作，提升参数调整体验
struct ParameterField: View {
    let title: String
    let unit: String
    @Binding var value: Double?
    var range: ClosedRange<Double> = 0...999
    var step: Double = 1.0
    var defaultValue: Double

    /// 触感反馈生成器
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    /// 初始化器
    /// - Parameters:
    ///   - title: 参数名称
    ///   - unit: 单位
    ///   - value: 绑定值
    ///   - range: 滑块范围
    ///   - step: 步进值
    ///   - defaultValue: 默认值（用于滑块初始位置）
    init(
        title: String,
        unit: String,
        value: Binding<Double?>,
        range: ClosedRange<Double> = 0...999,
        step: Double = 1.0,
        defaultValue: Double? = nil
    ) {
        self.title = title
        self.unit = unit
        self._value = value
        self.range = range
        self.step = step
        self.defaultValue = defaultValue ?? range.lowerBound
    }

    /// 格式化显示的值
    private var displayValue: Double {
        value ?? defaultValue
    }

    /// 根据 step 决定格式化字符串
    private var formatString: String {
        step >= 1 ? "%.0f" : "%.1f"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题 + 当前值
            HStack {
                Text(title)
                    .font(.body)
                Spacer()
                Text("\(String(format: formatString, displayValue))\(unit)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)

            // 滑块
            Slider(
                value: Binding(
                    get: { displayValue },
                    set: { newValue in
                        // 值变化时触发触感反馈
                        if value != newValue {
                            impactFeedback.impactOccurred()
                        }
                        value = newValue
                    }
                ),
                in: range,
                step: step
            ) {
                Text(title)
            } minimumValueLabel: {
                Text("\(Int(range.lowerBound))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            } maximumValueLabel: {
                Text(step >= 1 ? "\(Int(range.upperBound))" : String(format: "%.0f", range.upperBound))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("\(title)滑块，当前值\(String(format: formatString, displayValue))\(unit)，范围\(Int(range.lowerBound))到\(Int(range.upperBound))")
            .accessibilityHint("拖动调整\(title)")
        }
        .padding(.vertical, 4)
        // 确保触控区域 ≥ 44pt
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

/// 整数参数滑块组件
struct IntParameterField: View {
    let title: String
    let unit: String
    @Binding var value: Int?
    var range: ClosedRange<Int> = 0...999
    var defaultValue: Int

    /// 触感反馈生成器
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    /// 初始化器
    init(
        title: String,
        unit: String,
        value: Binding<Int?>,
        range: ClosedRange<Int> = 0...999,
        defaultValue: Int? = nil
    ) {
        self.title = title
        self.unit = unit
        self._value = value
        self.range = range
        self.defaultValue = defaultValue ?? range.lowerBound
    }

    /// 显示的值
    private var displayValue: Int {
        value ?? defaultValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题 + 当前值
            HStack {
                Text(title)
                    .font(.body)
                Spacer()
                Text("\(displayValue)\(unit)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)

            // 滑块
            Slider(
                value: Binding(
                    get: { Double(displayValue) },
                    set: { newValue in
                        let newIntValue = Int(newValue)
                        // 值变化时触发触感反馈
                        if value != newIntValue {
                            impactFeedback.impactOccurred()
                        }
                        value = newIntValue
                    }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            ) {
                Text(title)
            } minimumValueLabel: {
                Text("\(range.lowerBound)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            } maximumValueLabel: {
                Text("\(range.upperBound)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("\(title)滑块，当前值\(displayValue)\(unit)，范围\(range.lowerBound)到\(range.upperBound)")
            .accessibilityHint("拖动调整\(title)")
        }
        .padding(.vertical, 4)
        // 确保触控区域 ≥ 44pt
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

/// 只读参数显示
struct ParameterDisplay: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body)
            Text(unit)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("滑块参数") {
    Form {
        Section("意式浓缩") {
            ParameterField(
                title: "粉量",
                unit: "g",
                value: .constant(18.0),
                range: 5...30,
                step: 0.5,
                defaultValue: 18
            )
            ParameterField(
                title: "水温",
                unit: "°C",
                value: .constant(93),
                range: 85...100,
                step: 0.5,
                defaultValue: 93
            )
        }

        Section("手冲") {
            ParameterField(
                title: "注水量",
                unit: "ml",
                value: .constant(225),
                range: 100...500,
                step: 10,
                defaultValue: 225
            )
            IntParameterField(
                title: "萃取时间",
                unit: "秒",
                value: .constant(25),
                range: 10...60,
                defaultValue: 25
            )
        }

        Section("只读显示") {
            ParameterDisplay(title: "水温", value: "93", unit: "°C")
        }
    }
}
