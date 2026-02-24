//
//  RecordDetailView.swift
//  BrewLog
//

import SwiftUI
import SwiftData

/// 记录详情视图
struct RecordDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var record: BrewRecord
    @State private var showingDeleteConfirmation = false

    var body: some View {
        Form {
            // 基础信息
            Section {
                HStack {
                    Text("冲煮方式")
                    Spacer()
                    MethodBadge(method: record.method, size: .small)
                }

                HStack {
                    Text("日期")
                    Spacer()
                    Text(record.date.fullDate)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("评分")
                    Spacer()
                    if record.rating > 0 {
                        StarRatingDisplay(rating: record.rating)
                    } else {
                        Text("未评分")
                            .foregroundStyle(.tertiary)
                    }
                }
            } header: {
                Text("基础信息")
            }

            // 冲煮参数
            parameterSection

            // 咖啡豆信息
            Section {
                LabeledContent("咖啡豆", value: record.coffeeBean.isEmpty ? "未记录" : record.coffeeBean)
                LabeledContent("烘焙程度", value: record.roastLevel.displayName)

                if let roastDate = record.roastDate {
                    HStack {
                        Text("烘焙日期")
                        Spacer()
                        Text(roastDate.fullDate)
                            .foregroundStyle(.secondary)
                    }
                }

                LabeledContent("研磨度", value: record.grindSize.isEmpty ? "未记录" : record.grindSize)
            } header: {
                Text("咖啡豆信息")
            }

            // 笔记
            if !record.notes.isEmpty {
                Section {
                    Text(record.notes)
                        .font(.body)
                } header: {
                    Text("笔记")
                }
            }
        }
        .navigationTitle("记录详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("删除记录", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "确定要删除这条记录吗？",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("删除", role: .destructive) {
                deleteRecord()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销")
        }
    }

    // MARK: - 参数区块
    @ViewBuilder
    private var parameterSection: some View {
        Section {
            switch record.method {
            case .espresso:
                espressoParameters
            case .pourOver:
                pourOverParameters
            case .mokaPot:
                mokaPotParameters
            }
        } header: {
            Text("冲煮参数")
        }
    }

    @ViewBuilder
    private var espressoParameters: some View {
        if let dose = record.espressoDose {
            ParameterDisplay(title: "粉量", value: String(format: "%.1f", dose), unit: "g")
        }
        if let yield = record.espressoYield {
            ParameterDisplay(title: "液重", value: String(format: "%.1f", yield), unit: "g")
        }
        if let time = record.espressoTime {
            ParameterDisplay(title: "萃取时间", value: "\(time)", unit: "秒")
        }
        if let temp = record.espressoTemp {
            ParameterDisplay(title: "水温", value: String(format: "%.1f", temp), unit: "°C")
        }
        if let pressure = record.espressoPressure {
            ParameterDisplay(title: "压力", value: String(format: "%.1f", pressure), unit: "bar")
        }

        if record.espressoDose == nil && record.espressoYield == nil {
            Text("未记录参数")
                .foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private var pourOverParameters: some View {
        if let dose = record.pourOverDose {
            ParameterDisplay(title: "粉量", value: String(format: "%.1f", dose), unit: "g")
        }
        if let water = record.pourOverWater {
            ParameterDisplay(title: "注水量", value: String(format: "%.0f", water), unit: "ml")
        }
        if let temp = record.pourOverTemp {
            ParameterDisplay(title: "水温", value: String(format: "%.1f", temp), unit: "°C")
        }
        if let bloomTime = record.pourOverBloomTime {
            ParameterDisplay(title: "闷蒸时间", value: "\(bloomTime)", unit: "秒")
        }
        if let time = record.pourOverTime {
            ParameterDisplay(title: "总时间", value: "\(time)", unit: "秒")
        }
        if let pours = record.pourOverPours {
            ParameterDisplay(title: "注水次数", value: "\(pours)", unit: "次")
        }

        if record.pourOverDose == nil && record.pourOverWater == nil {
            Text("未记录参数")
                .foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private var mokaPotParameters: some View {
        if let dose = record.mokaDose {
            ParameterDisplay(title: "粉量", value: String(format: "%.1f", dose), unit: "g")
        }
        if let water = record.mokaWater {
            ParameterDisplay(title: "水量", value: String(format: "%.0f", water), unit: "ml")
        }
        if let heat = record.mokaHeat {
            HStack {
                Text("火力")
                Spacer()
                Label(heat.displayName, systemImage: heat.iconName)
                    .foregroundStyle(heat.color)
            }
        }
        if let time = record.mokaTime {
            ParameterDisplay(title: "萃取时间", value: "\(time)", unit: "秒")
        }

        if record.mokaDose == nil && record.mokaWater == nil {
            Text("未记录参数")
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - 删除记录
    private func deleteRecord() {
        modelContext.delete(record)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        RecordDetailView(record: {
            let record = BrewRecord(method: .espresso, coffeeBean: "埃塞俄比亚 耶加雪菲")
            record.rating = 4
            record.notes = "风味明亮，果酸适中"
            record.espressoDose = 18
            record.espressoYield = 36
            record.espressoTime = 25
            record.espressoTemp = 93
            record.espressoPressure = 9
            return record
        }())
    }
    .modelContainer(for: BrewRecord.self, inMemory: true)
}
