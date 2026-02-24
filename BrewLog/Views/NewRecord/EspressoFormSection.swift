//
//  EspressoFormSection.swift
//  BrewLog
//

import SwiftUI

/// 意式浓缩参数表单区块
struct EspressoFormSection: View {
    @Binding var dose: Double?
    @Binding var yield: Double?
    @Binding var time: Int?
    @Binding var temp: Double?
    @Binding var pressure: Double?

    var body: some View {
        Section {
            ParameterField(title: "粉量", unit: "g", value: $dose, range: 5...30, step: 0.5)
            ParameterField(title: "液重", unit: "g", value: $yield, range: 10...80, step: 0.5)
            IntParameterField(title: "萃取时间", unit: "秒", value: $time, range: 10...60)
            ParameterField(title: "水温", unit: "°C", value: $temp, range: 85...100, step: 0.5)
            ParameterField(title: "压力", unit: "bar", value: $pressure, range: 6...12, step: 0.5)
        } header: {
            Label("意式浓缩参数", systemImage: "espresso")
        } footer: {
            Text("建议粉液比 1:2，萃取时间 25-30 秒")
        }
    }
}

#Preview {
    Form {
        EspressoFormSection(
            dose: .constant(18),
            yield: .constant(36),
            time: .constant(25),
            temp: .constant(93),
            pressure: .constant(9)
        )
    }
}
