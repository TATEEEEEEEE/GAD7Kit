import Foundation
import SwiftUI

// MARK: - Core model

/// A response to one GAD-7 item.
public enum GAD7Response: Int, CaseIterable, Codable, Sendable, Identifiable {
    case notAtAll = 0
    case severalDays = 1
    case moreThanHalfTheDays = 2
    case nearlyEveryDay = 3

    public var id: Int { rawValue }
}

/// Standard GAD-7 symptom-severity bands.
public enum GAD7Severity: String, Codable, Sendable, CaseIterable {
    case minimal
    case mild
    case moderate
    case severe
}

/// The result of scoring seven GAD-7 responses.
public struct GAD7Result: Equatable, Codable, Sendable {
    public let totalScore: Int
    public let severity: GAD7Severity

    public init(totalScore: Int, severity: GAD7Severity) {
        self.totalScore = totalScore
        self.severity = severity
    }
}

public enum GAD7Error: Error, Equatable, Sendable {
    case invalidResponseCount(expected: Int, actual: Int)
}

/// Scores a complete set of seven GAD-7 responses.
public enum GAD7Scorer {
    public static let itemCount = 7
    public static let minimumScore = 0
    public static let maximumScore = 21

    public static func score(_ responses: [GAD7Response]) throws -> GAD7Result {
        guard responses.count == itemCount else {
            throw GAD7Error.invalidResponseCount(
                expected: itemCount,
                actual: responses.count
            )
        }

        let total = responses.reduce(0) { $0 + $1.rawValue }

        return GAD7Result(
            totalScore: total,
            severity: severity(for: total)
        )
    }

    public static func severity(for score: Int) -> GAD7Severity {
        switch score {
        case ...4:
            return .minimal
        case 5...9:
            return .mild
        case 10...14:
            return .moderate
        default:
            return .severe
        }
    }
}

// MARK: - Questionnaire content

public enum GAD7Language: String, Codable, Sendable, CaseIterable {
    case english
    case simplifiedChinese
}

public struct GAD7Item: Identifiable, Equatable, Codable, Sendable {
    public let id: Int
    public let englishText: String
    public let simplifiedChineseText: String

    public init(id: Int, englishText: String, simplifiedChineseText: String) {
        self.id = id
        self.englishText = englishText
        self.simplifiedChineseText = simplifiedChineseText
    }

    public func text(for language: GAD7Language) -> String {
        switch language {
        case .english:
            return englishText
        case .simplifiedChinese:
            return simplifiedChineseText
        }
    }
}

public enum GAD7Questionnaire {
    public static let items: [GAD7Item] = [
        GAD7Item(
            id: 1,
            englishText: "Feeling nervous, anxious, or on edge.",
            simplifiedChineseText: "感到紧张、焦虑或急切。"
        ),
        GAD7Item(
            id: 2,
            englishText: "Not being able to stop or control worrying.",
            simplifiedChineseText: "无法停止或控制担忧。"
        ),
        GAD7Item(
            id: 3,
            englishText: "Worrying too much about different things.",
            simplifiedChineseText: "对各种事情担忧过多。"
        ),
        GAD7Item(
            id: 4,
            englishText: "Having trouble relaxing.",
            simplifiedChineseText: "很难放松下来。"
        ),
        GAD7Item(
            id: 5,
            englishText: "Being so restless that it is hard to sit still.",
            simplifiedChineseText: "坐立不安，难以安静坐着。"
        ),
        GAD7Item(
            id: 6,
            englishText: "Becoming easily annoyed or irritable.",
            simplifiedChineseText: "容易烦恼或急躁。"
        ),
        GAD7Item(
            id: 7,
            englishText: "Feeling afraid as if something awful might happen.",
            simplifiedChineseText: "害怕仿佛会有可怕的事情发生。"
        )
    ]

    public static func responseLabel(
        for response: GAD7Response,
        language: GAD7Language
    ) -> String {
        switch (response, language) {
        case (.notAtAll, .english):
            return "Not at all"
        case (.severalDays, .english):
            return "Several days"
        case (.moreThanHalfTheDays, .english):
            return "More than half the days"
        case (.nearlyEveryDay, .english):
            return "Nearly every day"
        case (.notAtAll, .simplifiedChinese):
            return "完全没有"
        case (.severalDays, .simplifiedChinese):
            return "有几天"
        case (.moreThanHalfTheDays, .simplifiedChinese):
            return "一半以上时间"
        case (.nearlyEveryDay, .simplifiedChinese):
            return "几乎每天"
        }
    }
}

// MARK: - SwiftUI questionnaire

/// A reusable GAD-7 questionnaire view.
///
/// The view returns a `GAD7Result` through `onComplete`. GAD-7 is a screening
/// instrument and does not by itself establish a diagnosis.
public struct GAD7QuestionnaireView: View {
    private let language: GAD7Language
    private let accentColor: Color
    private let onComplete: (GAD7Result) -> Void

    @State private var currentIndex = 0
    @State private var responses: [GAD7Response?] = Array(
        repeating: nil,
        count: GAD7Scorer.itemCount
    )

    public init(
        language: GAD7Language = .english,
        accentColor: Color = .blue,
        onComplete: @escaping (GAD7Result) -> Void
    ) {
        self.language = language
        self.accentColor = accentColor
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 24) {
            header
            questionCard
            navigationButtons
            disclaimer
        }
        .padding()
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(language == .english ? "GAD-7" : "GAD-7 焦虑筛查")
                .font(.largeTitle.bold())

            Text(language == .english ? "Over the last two weeks" : "请根据过去两周的情况作答")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(
                value: Double(currentIndex + 1),
                total: Double(GAD7Scorer.itemCount)
            )
            .tint(accentColor)
        }
    }

    private var questionCard: some View {
        let item = GAD7Questionnaire.items[currentIndex]

        return VStack(alignment: .leading, spacing: 18) {
            Text("\(currentIndex + 1) / \(GAD7Scorer.itemCount)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            Text(item.text(for: language))
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(GAD7Response.allCases) { response in
                    Button {
                        responses[currentIndex] = response
                    } label: {
                        HStack {
                            Text(GAD7Questionnaire.responseLabel(for: response, language: language))
                            Spacer()
                            if responses[currentIndex] == response {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    responses[currentIndex] == response
                                    ? accentColor.opacity(0.16)
                                    : Color.secondary.opacity(0.08)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    responses[currentIndex] == response
                                    ? accentColor
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        )
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button(language == .english ? "Previous" : "上一题") {
                guard currentIndex > 0 else { return }
                currentIndex -= 1
            }
            .buttonStyle(.bordered)
            .disabled(currentIndex == 0)

            Spacer()

            Button(
                currentIndex == GAD7Scorer.itemCount - 1
                ? (language == .english ? "Complete" : "完成")
                : (language == .english ? "Next" : "下一题")
            ) {
                advanceOrComplete()
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
            .disabled(responses[currentIndex] == nil)
        }
    }

    private var disclaimer: some View {
        Text(
            language == .english
            ? "This questionnaire is a screening tool and is not a diagnosis."
            : "本问卷仅用于筛查，不构成诊断。"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }

    private func advanceOrComplete() {
        guard responses[currentIndex] != nil else { return }

        if currentIndex < GAD7Scorer.itemCount - 1 {
            currentIndex += 1
            return
        }

        let completedResponses = responses.compactMap { $0 }
        guard let result = try? GAD7Scorer.score(completedResponses) else { return }
        onComplete(result)
    }
}
