//
//  ParameterField.swift
//  BrewLog
//

import SwiftUI

/// 参数输入字段（带单位）
struct ParameterField: View {
    let title: String
    let unit: String
    @Binding var value: Double?
    var range: ClosedRange<Double> = 0...999
    var step: Double = 1.0
    var format: String = "%.0f"

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            HStack(spacing: 4) {
                TextField("", value: $value, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .frame(minWidth: 60)
                    .accessibilityLabel(title)

                Text(unit)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// 整数参数输入字段
struct IntParameterField: View {
    let title: String
    let unit: String
    @Binding var value: Int?
    var range: ClosedRange<Int> = 0...999

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            HStack(spacing: 4) {
                TextField("", value: $value, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .frame(minWidth: 60)
                    .accessibilityLabel(title)

                Text(unit)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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

#Preview {
    Form {
        ParameterField(title: "粉量", unit: "g", value: .constant(18.0))
        IntParameterField(title: "时间", unit: "秒", value: .constant(25))
        ParameterDisplay(title: "水温", value: "93", unit: "°C")
    }
}
