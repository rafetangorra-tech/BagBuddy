import SwiftUI

extension Font {
    // MARK: - Oswald (brand / combo display)

    /// Giant combo code or brand display — Oswald SemiBold 72
    static let bbDisplay: Font = .custom("Oswald-SemiBold", size: 72)

    /// Large combo combination text — Oswald SemiBold 40
    static let bbCombo: Font = .custom("Oswald-SemiBold", size: 40)

    /// Drill combo text (slightly larger) — Oswald SemiBold 44
    static let bbComboDrill: Font = .custom("Oswald-SemiBold", size: 44)

    /// Section headings, mode names — Oswald Medium 22
    static let bbHeadline: Font = .custom("Oswald-Medium", size: 22)

    /// Combo code badge ("BN-04") — Oswald Medium 14
    static let bbCode: Font = .custom("Oswald-Medium", size: 14)

    // MARK: - SF Pro (UI / labels)

    /// Round timer digits
    static let bbTimer: Font = .system(size: 52, weight: .heavy, design: .monospaced)

    /// Drill countdown timer
    static let bbDrillTimer: Font = .system(size: 72, weight: .black, design: .monospaced)

    /// Small all-caps labels (section headers, tags)
    static let bbLabel: Font = .system(size: 12, weight: .semibold)

    /// Settings body text
    static let bbBody: Font = .system(size: 17, weight: .regular)

    /// Mode description subtitle
    static let bbCaption: Font = .system(size: 13, weight: .regular)
}
