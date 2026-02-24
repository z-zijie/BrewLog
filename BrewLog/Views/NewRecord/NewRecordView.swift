//
//  NewRecordView.swift
//  BrewLog
//

import SwiftUI
import SwiftData

/// 新建记录视图
struct NewRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var method: BrewMethod = .espresso
    @State private var date = Date()
    @State private var rating: Int = 0
    @State private var notes: String = ""
    @State private var coffeeBean: String = ""
    @State private var roastLevel: RoastLevel = .medium
    @State private var roastDate: Date?
    @State private var grindSize: String = ""

    // Espresso 参数
    @State private var espressoDose: Double?
    @State private var espressoYield: Double?
    @State private var espressoTime: Int?
    @State private var espressoTemp: Double?
    @State private var espressoPressure: Double?

    // Pour Over 参数
    @State private var pourOverDose: Double?
    @State private var pourOverWater: Double?
    @State private var pourOverTemp: Double?
    @State private var pourOverBloomTime: Int?
    @State private var pourOverTime: Int?
    @State private var pourOverPours: Int?

    // Moka Pot 参数
    @State private var mokaDose: Double?
    @State private var mokaWater: Double?
    @State private var mokaHeat: HeatLevel?
    @State private var mokaTime: Int?

    var body: some View {
        NavigationStack {
            Form {
                // 冲煮方式选择
                Section {
                    Picker("冲煮方式", selection: $method) {
                        ForEach(BrewMethod.allCases) { method in
                            Label(method.displayName, systemImage: method.iconName)
                                .tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                } header: {
                    Text("冲煮方式")
                }

                // 日期时间
                Section {
                    DatePicker("日期", selection: $date)
                        .datePickerStyle(.compact)
                }

                // 方式特定参数
                switch method {
                case .espresso:
                    EspressoFormSection(
                        dose: $espressoDose,
                        yield: $espressoYield,
                        time: $espressoTime,
                        temp: $espressoTemp,
                        pressure: $espressoPressure
                    )
                case .pourOver:
                    PourOverFormSection(
                        dose: $pourOverDose,
                        water: $pourOverWater,
                        temp: $pourOverTemp,
                        bloomTime: $pourOverBloomTime,
                        time: $pourOverTime,
                        pours: $pourOverPours
                    )
                case .mokaPot:
                    MokaPotFormSection(
                        dose: $mokaDose,
                        water: $mokaWater,
                        heat: $mokaHeat,
                        time: $mokaTime
                    )
                }

                // 通用参数
                CoffeeBeanSection(
                    coffeeBean: $coffeeBean,
                    roastLevel: $roastLevel,
                    roastDate: $roastDate,
                    grindSize: $grindSize
                )

                RatingSection(rating: $rating)
                NotesSection(notes: $notes)
            }
            .navigationTitle("新建记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!isValid)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - 验证
    private var isValid: Bool {
        !coffeeBean.isEmpty
    }

    // MARK: - 保存记录
    private func saveRecord() {
        let record = BrewRecord(
            method: method,
            date: date,
            rating: rating,
            notes: notes,
            coffeeBean: coffeeBean,
            roastLevel: roastLevel,
            roastDate: roastDate,
            grindSize: grindSize
        )

        // 设置方式特定参数
        switch method {
        case .espresso:
            record.espressoDose = espressoDose
            record.espressoYield = espressoYield
            record.espressoTime = espressoTime
            record.espressoTemp = espressoTemp
            record.espressoPressure = espressoPressure
        case .pourOver:
            record.pourOverDose = pourOverDose
            record.pourOverWater = pourOverWater
            record.pourOverTemp = pourOverTemp
            record.pourOverBloomTime = pourOverBloomTime
            record.pourOverTime = pourOverTime
            record.pourOverPours = pourOverPours
        case .mokaPot:
            record.mokaDose = mokaDose
            record.mokaWater = mokaWater
            record.mokaHeat = mokaHeat
            record.mokaTime = mokaTime
        }

        modelContext.insert(record)
        dismiss()
    }
}

#Preview {
    NewRecordView()
        .modelContainer(for: BrewRecord.self, inMemory: true)
}
