//
//  PourOverFormSection.swift
//  BrewLog
//

import SwiftUI

/// 手冲咖啡参数表单区块
struct PourOverFormSection: View {
    @Binding var dose: Double?
    @Binding var water: Double?
    @Binding var temp: Double?
    @Binding var bloomTime: Int?
    @Binding var time: Int?
    @Binding var pours: Int?

    var body: some View {
        Section {
            ParameterField(title: "粉量", unit: "g", value: $dose, range: 10...30, step: 0.5)
            ParameterField(title: "注水量", unit: "ml", value: $water, range: 100...500, step: 10)
            ParameterField(title: "水温", unit: "°C", value: $temp, range: 85...100, step: 0.5)
            IntParameterField(title: "闷蒸时间", unit: "秒", value: $bloomTime, range: 15...60)
            IntParameterField(title: "总时间", unit: "秒", value: $time, range: 60...300)
            IntParameterField(title: "注水次数", unit: "次", value: $pours, range: 1...6)
        } header: {
            Label("手冲参数", systemImage: "drop")
        } footer: {
            Text("建议粉水比 1:15-1:17，闷蒸 30 秒")
        }
    }
}

#Preview {
    Form {
        PourOverFormSection(
            dose: .constant(15),
            water: .constant(225),
            temp: .constant(92),
            bloomTime: .constant(30),
            time: .constant(180),
            pours: .constant(3)
        )
    }
}
