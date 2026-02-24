//
//  CommonFormSection.swift
//  BrewLog
//

import SwiftUI

/// 通用参数表单区块 - 咖啡豆信息
struct CoffeeBeanSection: View {
    @Binding var coffeeBean: String
    @Binding var roastLevel: RoastLevel
    @Binding var roastDate: Date?
    @Binding var grindSize: String

    var body: some View {
        Section {
            TextField("咖啡豆名称", text: $coffeeBean)
                .accessibilityLabel("咖啡豆名称")

            Picker("烘焙程度", selection: $roastLevel) {
                ForEach(RoastLevel.allCases) { level in
                    Text(level.displayName).tag(level)
                }
            }

            DatePicker(
                "烘焙日期",
                selection: Binding(
                    get: { roastDate ?? Date() },
                    set: { roastDate = $0 }
                ),
                displayedComponents: .date
            )

            TextField("研磨度", text: $grindSize)
                .accessibilityLabel("研磨度")
        } header: {
            Label("咖啡豆信息", systemImage: "leaf")
        }
    }
}

/// 通用参数表单区块 - 评分
struct RatingSection: View {
    @Binding var rating: Int

    var body: some View {
        Section {
            HStack {
                Text("评分")
                Spacer()
                StarRating(rating: $rating)
            }
        } header: {
            Label("评分", systemImage: "star")
        }
    }
}

/// 通用参数表单区块 - 笔记
struct NotesSection: View {
    @Binding var notes: String

    var body: some View {
        Section {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .accessibilityLabel("笔记")
        } header: {
            Label("笔记", systemImage: "note.text")
        }
    }
}

#Preview {
    Form {
        CoffeeBeanSection(
            coffeeBean: .constant("埃塞俄比亚 耶加雪菲"),
            roastLevel: .constant(.medium),
            roastDate: .constant(Date()),
            grindSize: .constant("中细")
        )
        RatingSection(rating: .constant(4))
        NotesSection(notes: .constant("风味明亮，果酸适中"))
    }
}
