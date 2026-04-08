import SwiftUI

extension Font {
    /// Large countdown numbers, "FIGHT", "REST"
    static let bbDisplay: Font = {
        Font.system(size: 80, weight: .black)
            .width(.condensed)
    }()

    /// Round number, section headers — all caps
    static let bbHeadline: Font = {
        Font.system(size: 22, weight: .black)
            .width(.condensed)
    }()

    /// Combo move chips (strikes)
    static let bbComboStrike: Font = {
        Font.system(size: 40, weight: .black)
            .width(.condensed)
    }()

    /// Combo move chips (defense labels)
    static let bbComboDefense: Font = {
        Font.system(size: 22, weight: .bold)
            .width(.condensed)
    }()

    /// Round timer digits
    static let bbTimer: Font = {
        Font.system(size: 52, weight: .heavy, design: .monospaced)
    }()

    /// Small all-caps labels
    static let bbLabel: Font = {
        Font.system(size: 12, weight: .semibold)
            .width(.condensed)
    }()

    /// Settings body
    static let bbBody: Font = {
        Font.system(size: 17, weight: .medium)
            .width(.condensed)
    }()
}
