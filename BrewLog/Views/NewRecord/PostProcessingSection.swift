//
//  PostProcessingSection.swift
// BrewLog
//

import SwiftUI

/// 后处理表单区块 - 可折叠
struct PostProcessingSection: View {
    @Binding var drinkType: DrinkType?
    @Binding var milkType: MilkType?
    @Binding var milkAmount: Int?
    @Binding var isIced: Bool

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                postProcessingContent
            },
            label: {
                Label("后处理 / 添加物", systemImage: "drop.circle")
                    .foregroundStyle(.secondary)
            }
        )
        .onChange(of: drinkType) { _, newType in
            // 选择饮品类型后自动展开
            if newType != nil && !isExpanded {
                isExpanded = true
            }
        }
    }

    // MARK: - 后处理内容
    @ViewBuilder
    private var postProcessingContent: some View {
        Picker("饮品类型", selection: $drinkType) {
            Text("无").tag(nil as DrinkType?)
            ForEach(DrinkType.allCases) { type in
                Text(type.rawValue).tag(type as DrinkType?)
            }
        }
        .pickerStyle(.menu)

        // 奶咖选项
        if drinkType?.isMilkDrink == true {
            milkOptions
        }

        // 冰饮选项
        Toggle("冰饮", isOn: $isIced)
    }

    // MARK: - 牛奶选项
    @ViewBuilder
    private var milkOptions: some View {
        Picker("牛奶类型", selection: $milkType) {
            Text("请选择").tag(nil as MilkType?)
            ForEach(MilkType.allCases) { type in
                Text(type.rawValue).tag(type as MilkType?)
            }
        }
        .pickerStyle(.menu)

        IntParameterField(
            title: "牛奶量",
            unit: "ml",
            value: $milkAmount,
            range: 30...300,
            defaultValue: 150
        )
    }
}

#Preview {
    Form {
        PostProcessingSection(
            drinkType: .constant(.latte),
            milkType: .constant(.oat),
            milkAmount: .constant(150),
            isIced: .constant(false)
        )
    }
}
