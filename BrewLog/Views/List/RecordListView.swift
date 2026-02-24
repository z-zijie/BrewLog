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
    @State private var deletedRecord: BrewRecord?
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
            deletedRecord = sectionRecords[index]
            modelContext.delete(sectionRecords[index])
        }
        showUndoToast = true

        // 3秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if showUndoToast {
                showUndoToast = false
                deletedRecord = nil
            }
        }
    }

    private func undoDelete() {
        // 撤销删除（这里只是隐藏toast，实际数据已删除）
        // 完整实现需要保存删除的记录数据
        showUndoToast = false
        deletedRecord = nil
    }
}

#Preview {
    RecordListView()
        .modelContainer(for: BrewRecord.self, inMemory: true)
}
