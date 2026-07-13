# GAD7Kit

GAD-7 anxiety screening and scoring.

## Features

- Standard GAD-7 scoring
- Seven questions scored from 0 to 3
- Total score from 0 to 21
- Minimal, mild, moderate, and severe classifications
- English and Simplified Chinese support
- Reusable SwiftUI questionnaire view
- Swift Testing unit tests

## Requirements

- iOS 17 or later
- macOS 14 or later
- Swift 6.4 or later

## Installation

In Xcode:

1. Open your project.
2. Select **File → Add Package Dependencies…**
3. Enter this repository URL.
4. Select the version you want to use.
5. Add `GAD7Kit` to your app target.

## Scoring

```swift
import GAD7Kit

let responses: [GAD7Response] = [
    .notAtAll,
    .severalDays,
    .notAtAll,
    .moreThanHalfTheDays,
    .notAtAll,
    .severalDays,
    .notAtAll
]

let result = try GAD7Scorer.score(responses)

print(result.totalScore)
print(result.severity)
```

## SwiftUI

```swift
import SwiftUI
import GAD7Kit

struct ContentView: View {
    var body: some View {
        GAD7QuestionnaireView(
            language: .english,
            accentColor: .blue
        ) { result in
            print(result.totalScore)
            print(result.severity)
        }
    }
}
```

## Simplified Chinese

```swift
GAD7QuestionnaireView(
    language: .simplifiedChinese
) { result in
    print(result.totalScore)
    print(result.severity)
}
```

## Severity

| Score | Severity |
|------:|----------|
| 0–4 | Minimal |
| 5–9 | Mild |
| 10–14 | Moderate |
| 15–21 | Severe |

## Important Notice

GAD-7 is a screening instrument and does not by itself establish a clinical diagnosis.

## License

The source code in this repository is available under the MIT License.
