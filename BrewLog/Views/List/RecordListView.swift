//
//  RecordListView.swift
//  BrewLog
//

import SwiftUI
import SwiftData

/// 记录列表视图
struct RecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BrewRecord.date, order: .reverse) private var records: [BrewRecord]

    @State private var showingNewRecord = false
    @State private var deletedRecordCopy: BrewRecord?
    @State private var showUndoToast = false

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyStateView
                } else {
                    recordListView
                }
            }
            .navigationTitle("冲煮记录")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewRecord = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("新建记录")
                }
            }
            .sheet(isPresented: $showingNewRecord) {
                NewRecordView()
                    .modelContext(modelContext)
            }
            .overlay(alignment: .bottom) {
                undoToast
            }
        }
    }

    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 60))
                .foregroundStyle(.coffee.opacity(0.5))

            Text("还没有记录")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("点击右上角 + 开始记录你的第一杯咖啡")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button {
                showingNewRecord = true
            } label: {
                Label("新建记录", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.coffee)
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cream)
    }

    // MARK: - 列表视图
    private var recordListView: some View {
        List {
            ForEach(groupedRecords.keys.sorted().reversed(), id: \.self) { date in
                Section {
                    ForEach(groupedRecords[date] ?? []) { record in
                        NavigationLink(value: record) {
                            RecordRowView(record: record)
                        }
                    }
                    .onDelete { indexSet in
                        deleteRecords(at: indexSet, in: groupedRecords[date] ?? [])
                    }
                } header: {
                    Text(formatSectionHeader(date))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: BrewRecord.self) { record in
            RecordDetailView(record: record)
        }
        .animation(.default, value: records)
    }

    // MARK: - 撤销提示
    private var undoToast: some View {
        Group {
            if showUndoToast {
                HStack {
                    Text("已删除记录")
                        .font(.subheadline)
                    Spacer()
                    Button("撤销") {
                        undoDelete()
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: showUndoToast)
    }

    // MARK: - 数据处理
    private var groupedRecords: [Date: [BrewRecord]] {
        Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
    }

    private func formatSectionHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日 EEEE"
            return formatter.string(from: date)
        }
    }

    private func deleteRecords(at offsets: IndexSet, in sectionRecords: [BrewRecord]) {
        for index in offsets {
            let record = sectionRecords[index]
            // 保存删除记录的副本用于撤销
            deletedRecordCopy = copyRecord(record)
            modelContext.delete(record)
        }
        showUndoToast = true

        // 3秒后自动隐藏并清除副本
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if showUndoToast {
                showUndoToast = false
                deletedRecordCopy = nil
            }
        }
    }

    /// 复制记录数据（用于撤销删除）
    private func copyRecord(_ record: BrewRecord) -> BrewRecord {
        let copy = BrewRecord(
            method: record.method,
            date: record.date,
            rating: record.rating,
            notes: record.notes,
            coffeeBean: record.coffeeBean,
            roastLevel: record.roastLevel,
            roastDate: record.roastDate,
            grindSize: record.grindSize
        )

        // 复制方式特定参数
        switch record.method {
        case .espresso:
            copy.espressoDose = record.espressoDose
            copy.espressoYield = record.espressoYield
            copy.espressoTime = record.espressoTime
            copy.espressoTemp = record.espressoTemp
            copy.espressoPressure = record.espressoPressure
        case .pourOver:
            copy.pourOverDose = record.pourOverDose
            copy.pourOverWater = record.pourOverWater
            copy.pourOverTemp = record.pourOverTemp
            copy.pourOverBloomTime = record.pourOverBloomTime
            copy.pourOverTime = record.pourOverTime
            copy.pourOverPours = record.pourOverPours
        case .mokaPot:
            copy.mokaDose = record.mokaDose
            copy.mokaWater = record.mokaWater
            copy.mokaHeat = record.mokaHeat
            copy.mokaTime = record.mokaTime
        }

        // 复制分析数据
        copy.analysisJSON = record.analysisJSON
        copy.analyzedAt = record.analyzedAt

        return copy
    }

    private func undoDelete() {
        // 恢复被删除的记录
        if let copy = deletedRecordCopy {
            modelContext.insert(copy)
        }
        showUndoToast = false
        deletedRecordCopy = nil
    }
}

#Preview {
    RecordListView()
        .modelContainer(for: BrewRecord.self, inMemory: true)
}
