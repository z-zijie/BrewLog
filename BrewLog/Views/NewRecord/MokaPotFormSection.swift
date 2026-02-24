//
//  MokaPotFormSection.swift
//  BrewLog
//

import SwiftUI

/// 摩卡壶参数表单区块
struct MokaPotFormSection: View {
    @Binding var dose: Double?
    @Binding var water: Double?
    @Binding var heat: HeatLevel?
    @Binding var time: Int?

    var body: some View {
        Section {
            ParameterField(title: "粉量", unit: "g", value: $dose, range: 10...30, step: 0.5)
            ParameterField(title: "水量", unit: "ml", value: $water, range: 50...300, step: 10)

            Picker("火力", selection: $heat) {
                Text("请选择").tag(nil as HeatLevel?)
                ForEach(HeatLevel.allCases) { level in
                    HStack {
                        Image(systemName: level.iconName)
                        Text(level.displayName)
                    }
                    .tag(level as HeatLevel?)
                }
            }

            IntParameterField(title: "萃取时间", unit: "秒", value: $time, range: 60...300)
        } header: {
            Label("摩卡壶参数", systemImage: "flame")
        } footer: {
            Text("建议使用中低火，避免过萃")
        }
    }
}

#Preview {
    Form {
        MokaPotFormSection(
            dose: .constant(20),
            water: .constant(120),
            heat: .constant(.medium),
            time: .constant(120)
        )
    }
}
