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

    // MARK: - 咖啡豆信息
    @State private var coffeeBean: String = ""
    @State private var roastLevel: RoastLevel = .medium
    @State private var roastDate: Date?

    // MARK: - 冲煮方式
    @State private var method: BrewMethod = .espresso

    // MARK: - 研磨度（通用）
    @State private var espressoGrindSize: Double?
    @State private var pourOverGrindSize: Double?
    @State private var mokaPotGrindSize: Double?

    // MARK: - Espresso 参数
    @State private var espressoDose: Double?
    @State private var espressoYield: Double?
    @State private var espressoTime: Int?
    @State private var espressoTemp: Double?
    @State private var espressoPressure: Double?

    // MARK: - Pour Over 参数
    @State private var pourOverDose: Double?
    @State private var pourOverWater: Double?
    @State private var pourOverTemp: Double?
    @State private var pourOverBloomTime: Int?
    @State private var pourOverTime: Int?
    @State private var pourOverPours: Int?

    // MARK: - Moka Pot 参数
    @State private var mokaDose: Double?
    @State private var mokaWater: Double?
    @State private var mokaHeat: HeatLevel?
    @State private var mokaTime: Int?

    // MARK: - 后处理参数
    @State private var drinkType: DrinkType?
    @State private var milkType: MilkType?
    @State private var milkAmount: Int?
    @State private var isIced: Bool = false

    // MARK: - 评价
    @State private var rating: Int = 0
    @State private var notes: String = ""
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            Form {
                // 第一步：咖啡豆信息
                CoffeeBeanSection(
                    coffeeBean: $coffeeBean,
                    roastLevel: $roastLevel,
                    roastDate: $roastDate
                )

                // 第二步：冲煮方式
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

                // 冲煮参数（根据方式变化）
                switch method {
                case .espresso:
                    EspressoFormSection(
                        grindSize: $espressoGrindSize,
                        dose: $espressoDose,
                        yield: $espressoYield,
                        time: $espressoTime,
                        temp: $espressoTemp,
                        pressure: $espressoPressure
                    )
                case .pourOver:
                    PourOverFormSection(
                        grindSize: $pourOverGrindSize,
                        dose: $pourOverDose,
                        water: $pourOverWater,
                        temp: $pourOverTemp,
                        bloomTime: $pourOverBloomTime,
                        time: $pourOverTime,
                        pours: $pourOverPours
                    )
                case .mokaPot:
                    MokaPotFormSection(
                        grindSize: $mokaPotGrindSize,
                        dose: $mokaDose,
                        water: $mokaWater,
                        heat: $mokaHeat,
                        time: $mokaTime
                    )
                }

                // 第三步：后处理（可折叠）
                PostProcessingSection(
                    drinkType: $drinkType,
                    milkType: $milkType,
                    milkAmount: $milkAmount,
                    isIced: $isIced
                )

                // 第四步：评价
                RatingSection(rating: $rating)
                NotesSection(notes: $notes)

                // 日期（移到底部）
                Section {
                    DatePicker("日期", selection: $date)
                        .datePickerStyle(.compact)
                }
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
            grindSize: currentGrindSize
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

        // 设置后处理参数
        record.drinkType = drinkType
        record.milkType = milkType
        record.milkAmount = milkAmount
        record.isIced = isIced

        modelContext.insert(record)
        dismiss()
    }

    // MARK: - 当前研磨度
    private var currentGrindSize: Double? {
        switch method {
        case .espresso:
            return espressoGrindSize
        case .pourOver:
            return pourOverGrindSize
        case .mokaPot:
            return mokaPotGrindSize
        }
    }
}

#Preview {
    NewRecordView()
        .modelContainer(for: BrewRecord.self, inMemory: true)
}
