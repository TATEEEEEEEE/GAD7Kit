import Testing
@testable import GAD7Kit

@Test
func allZeroResponsesProduceMinimalResult() throws {
    let responses = Array(
        repeating: GAD7Response.notAtAll,
        count: GAD7Scorer.itemCount
    )

    let result = try GAD7Scorer.score(responses)

    #expect(result.totalScore == 0)
    #expect(result.severity == .minimal)
}

@Test
func maximumResponsesProduceSevereResult() throws {
    let responses = Array(
        repeating: GAD7Response.nearlyEveryDay,
        count: GAD7Scorer.itemCount
    )

    let result = try GAD7Scorer.score(responses)

    #expect(result.totalScore == 21)
    #expect(result.severity == .severe)
}

@Test(arguments: [
    (0, GAD7Severity.minimal),
    (4, GAD7Severity.minimal),
    (5, GAD7Severity.mild),
    (9, GAD7Severity.mild),
    (10, GAD7Severity.moderate),
    (14, GAD7Severity.moderate),
    (15, GAD7Severity.severe),
    (21, GAD7Severity.severe)
])
func severityBoundaries(score: Int, expected: GAD7Severity) {
    #expect(GAD7Scorer.severity(for: score) == expected)
}

@Test
func invalidResponseCountThrows() {
    let responses = Array(
        repeating: GAD7Response.notAtAll,
        count: GAD7Scorer.itemCount - 1
    )

    #expect(throws: GAD7Error.self) {
        try GAD7Scorer.score(responses)
    }
}

@Test
func questionnaireContainsSevenOrderedItems() {
    #expect(GAD7Questionnaire.items.count == GAD7Scorer.itemCount)
    #expect(GAD7Questionnaire.items.map(\.id) == Array(1...7))
}

@Test
func responseLabelsAreAvailableInBothLanguages() {
    #expect(
        GAD7Questionnaire.responseLabel(
            for: .notAtAll,
            language: .english
        ) == "Not at all"
    )

    #expect(
        GAD7Questionnaire.responseLabel(
            for: .notAtAll,
            language: .simplifiedChinese
        ) == "完全没有"
    )
}
