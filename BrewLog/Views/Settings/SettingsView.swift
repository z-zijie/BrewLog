//
//  SettingsView.swift
//  BrewLog
//

import SwiftUI
import SwiftData

/// 设置视图
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [BrewRecord]

    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // 关于
                Section {
                    LabeledContent("版本", value: appVersion)
                    LabeledContent("作者", value: "Zijie Zhang")
                } header: {
                    Text("关于")
                }

                // 数据统计
                Section {
                    LabeledContent("总记录数", value: "\(records.count)")

                    let methodCounts = countByMethod()
                    if methodCounts[.espresso] ?? 0 > 0 {
                        LabeledContent("意式浓缩", value: "\(methodCounts[.espresso] ?? 0)")
                    }
                    if methodCounts[.pourOver] ?? 0 > 0 {
                        LabeledContent("手冲", value: "\(methodCounts[.pourOver] ?? 0)")
                    }
                    if methodCounts[.mokaPot] ?? 0 > 0 {
                        LabeledContent("摩卡壶", value: "\(methodCounts[.mokaPot] ?? 0)")
                    }
                } header: {
                    Text("数据统计")
                }

                // 数据管理
                Section {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("清除所有数据", systemImage: "trash")
                    }
                    .disabled(records.isEmpty)
                } header: {
                    Text("数据管理")
                } footer: {
                    Text("此操作将删除所有冲煮记录，且无法撤销")
                }
            }
            .navigationTitle("设置")
            .confirmationDialog(
                "确定要清除所有数据吗？",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("清除所有数据", role: .destructive) {
                    clearAllData()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作将删除 \(records.count) 条记录，且无法撤销")
            }
        }
    }

    // MARK: - 辅助方法
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func countByMethod() -> [BrewMethod: Int] {
        var counts: [BrewMethod: Int] = [:]
        for record in records {
            counts[record.method, default: 0] += 1
        }
        return counts
    }

    private func clearAllData() {
        for record in records {
            modelContext.delete(record)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: BrewRecord.self, inMemory: true)
}
