import SwiftUI
import AppKit

// MARK: - Theme Style

enum ThemeStyle: String, CaseIterable {
    case `default`, brutalist, soft, tight, ascii, cyber

    var displayName: String {
        switch self {
        case .default:   return "Default"
        case .brutalist: return "Brutalist"
        case .soft:      return "Soft"
        case .tight:     return "Tight"
        case .ascii:     return "ASCII"
        case .cyber:     return "Cyber"
        }
    }
}

// MARK: - Theme Font

enum ThemeFont: String, CaseIterable {
    case grotesk, mono, inter, system

    var displayName: String {
        switch self {
        case .grotesk: return "Grotesk"
        case .mono:    return "Mono"
        case .inter:   return "Inter"
        case .system:  return "SF"
        }
    }
}

// MARK: - Theme Color

enum ThemeColor: String, CaseIterable {
    case red, orange, amber, green, teal, cyan, blue, violet, rose, grey, bw
    case apple, claude, google, dracula

    var displayName: String {
        switch self {
        case .bw:      return "B&W"
        case .apple:   return "Apple"
        case .claude:  return "Claude"
        case .google:  return "Google"
        case .dracula: return "Dracula"
        default:       return rawValue.capitalized
        }
    }

    var hex: UInt32 {
        switch self {
        case .red:    return 0xE53935
        case .orange: return 0xE85002
        case .amber:  return 0xF59E0B
        case .green:  return 0x43A047
        case .teal:   return 0x0D9488
        case .cyan:   return 0x00BCD4
        case .blue:   return 0x2196F3
        case .violet: return 0x8B5CF6
        case .rose:   return 0xE91E63
        case .grey:    return 0x888888
        case .bw:      return 0x000000
        case .apple:   return 0x007AFF
        case .claude:  return 0xDA7756
        case .google:  return 0x4285F4
        case .dracula: return 0xBD93F9
        }
    }

    var hoverHex: UInt32 {
        switch self {
        case .red:    return 0xEF5350
        case .orange: return 0xFF6010
        case .amber:  return 0xFBBF24
        case .green:  return 0x56B85A
        case .teal:   return 0x14B8A6
        case .cyan:   return 0x22D0E8
        case .blue:   return 0x42A5F5
        case .violet: return 0xA078FF
        case .rose:   return 0xF06292
        case .grey:    return 0x999999
        case .bw:      return 0x000000
        case .apple:   return 0x2E96FF
        case .claude:  return 0xE5936F
        case .google:  return 0x5E9AFF
        case .dracula: return 0xD0ACFF
        }
    }

    var darkHex: UInt32 {
        switch self {
        case .red:    return 0xC62828
        case .orange: return 0xC13A00
        case .amber:  return 0xD97706
        case .green:  return 0x2E7D32
        case .teal:   return 0x0F766E
        case .cyan:   return 0x0097A7
        case .blue:   return 0x1565C0
        case .violet: return 0x6A3AC8
        case .rose:   return 0xC2185B
        case .grey:    return 0x666666
        case .bw:      return 0x000000
        case .apple:   return 0x005EC4
        case .claude:  return 0xB85C3D
        case .google:  return 0x2B6AD0
        case .dracula: return 0x9A6DD7
        }
    }

    static var mainColors: [ThemeColor] {
        [.red, .orange, .amber, .green, .teal, .cyan, .blue, .violet, .rose]
    }

    static var specialColors: [ThemeColor] {
        [.grey, .bw]
    }

    static var brandColors: [ThemeColor] {
        [.apple, .claude, .google, .dracula]
    }

    var isBrand: Bool {
        Self.brandColors.contains(self)
    }

    var brandPalette: BrandPalette? {
        switch self {
        case .apple:
            return BrandPalette(
                bgPage:       (.init(0xF5F5F7), .init(0x000000)),
                bgPanel:      (.init(0xFFFFFF), .init(0x1C1C1E)),
                bgCanvas:     (.init(0xF2F2F7), .init(0x0A0A0A)),
                bgSurface:    (.init(0xE5E5EA), .init(0x2C2C2E)),
                bgActive:     (.init(0xD1D1D6), .init(0x3A3A3C)),
                border:       (.init(0xD1D1D6), .init(0x38383A)),
                borderActive: (.init(0xC7C7CC), .init(0x48484A)),
                inputBorder:  (.init(0xC7C7CC), .init(0x3A3A3C)),
                text1:        (.init(0x000000), .init(0xFFFFFF)),
                text2:        (.init(0x3C3C43), .init(0xEBEBF5)),
                text3:        (.init(0x8E8E93), .init(0x8E8E93)),
                text4:        (.init(0xAEAEB2), .init(0x636366)),
                text5:        (.init(0xC7C7CC), .init(0x48484A)),
                placeholder:  (.init(0x8E8E93), .init(0x636366))
            )
        case .claude:
            return BrandPalette(
                bgPage:       (.init(0xFFF8F3), .init(0x1A110D)),
                bgPanel:      (.init(0xFFFBF7), .init(0x221812)),
                bgCanvas:     (.init(0xFFF5EE), .init(0x1E1410)),
                bgSurface:    (.init(0xF5EAE0), .init(0x2C211A)),
                bgActive:     (.init(0xEBDDD0), .init(0x3A2D22)),
                border:       (.init(0xE0D0C0), .init(0x3A2D22)),
                borderActive: (.init(0xD4C0AE), .init(0x4A3D30)),
                inputBorder:  (.init(0xD8C8B8), .init(0x3D3025)),
                text1:        (.init(0x2A1810), .init(0xF5E5D5)),
                text2:        (.init(0x5C4030), .init(0xC8A890)),
                text3:        (.init(0x907060), .init(0x8A7060)),
                text4:        (.init(0xA88878), .init(0x6A5545)),
                text5:        (.init(0xC0A898), .init(0x4A3D30)),
                placeholder:  (.init(0x9A7A68), .init(0x6A5545))
            )
        case .google:
            return BrandPalette(
                bgPage:       (.init(0xF8F9FA), .init(0x111113)),
                bgPanel:      (.init(0xFFFFFF), .init(0x1F1F23)),
                bgCanvas:     (.init(0xF1F3F4), .init(0x171719)),
                bgSurface:    (.init(0xE8EAED), .init(0x292A2E)),
                bgActive:     (.init(0xDADCE0), .init(0x35363A)),
                border:       (.init(0xDADCE0), .init(0x3C4043)),
                borderActive: (.init(0xBDC1C6), .init(0x5F6368)),
                inputBorder:  (.init(0xDADCE0), .init(0x3C4043)),
                text1:        (.init(0x202124), .init(0xE8EAED)),
                text2:        (.init(0x5F6368), .init(0xBDC1C6)),
                text3:        (.init(0x80868B), .init(0x9AA0A6)),
                text4:        (.init(0x9AA0A6), .init(0x80868B)),
                text5:        (.init(0xBDC1C6), .init(0x5F6368)),
                placeholder:  (.init(0x80868B), .init(0x80868B))
            )
        case .dracula:
            return BrandPalette(
                bgPage:       (.init(0xF8F8F2), .init(0x1E1F29)),
                bgPanel:      (.init(0xFFFFFF), .init(0x282A36)),
                bgCanvas:     (.init(0xF0F0EA), .init(0x21222C)),
                bgSurface:    (.init(0xE8E8E0), .init(0x343746)),
                bgActive:     (.init(0xD8D8D0), .init(0x44475A)),
                border:       (.init(0xD0D0C8), .init(0x44475A)),
                borderActive: (.init(0xC0C0B8), .init(0x6272A4)),
                inputBorder:  (.init(0xC8C8C0), .init(0x44475A)),
                text1:        (.init(0x282A36), .init(0xF8F8F2)),
                text2:        (.init(0x44475A), .init(0xBFBFB2)),
                text3:        (.init(0x6272A4), .init(0x6272A4)),
                text4:        (.init(0x8892B0), .init(0x545878)),
                text5:        (.init(0xB0B8D0), .init(0x44475A)),
                placeholder:  (.init(0x6272A4), .init(0x545878))
            )
        default:
            return nil
        }
    }
}

// MARK: - Brand Palette

struct BrandPalette {
    typealias LP = (light: UInt32, dark: UInt32)
    let bgPage: LP
    let bgPanel: LP
    let bgCanvas: LP
    let bgSurface: LP
    let bgActive: LP
    let border: LP
    let borderActive: LP
    let inputBorder: LP
    let text1: LP
    let text2: LP
    let text3: LP
    let text4: LP
    let text5: LP
    let placeholder: LP
}

// MARK: - Theme Config (Observable)

@Observable
class ThemeConfig {
    static let shared = ThemeConfig()

    var isDark: Bool {
        didSet { UserDefaults.standard.set(isDark, forKey: "themeIsDark") }
    }
    var style: ThemeStyle {
        didSet { UserDefaults.standard.set(style.rawValue, forKey: "themeStyle") }
    }
    var font: ThemeFont {
        didSet { UserDefaults.standard.set(font.rawValue, forKey: "themeFont") }
    }
    var colorChoice: ThemeColor {
        didSet { UserDefaults.standard.set(colorChoice.rawValue, forKey: "themeColor") }
    }
    var panelSize: Theme.PanelSize = .md

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "themeIsDark") != nil {
            isDark = defaults.bool(forKey: "themeIsDark")
        } else {
            isDark = true
        }
        if let s = defaults.string(forKey: "themeStyle").flatMap(ThemeStyle.init(rawValue:)) {
            style = s
        } else {
            style = .default
        }
        if let f = defaults.string(forKey: "themeFont").flatMap(ThemeFont.init(rawValue:)) {
            font = f
        } else {
            font = .grotesk
        }
        if let c = defaults.string(forKey: "themeColor").flatMap(ThemeColor.init(rawValue:)) {
            colorChoice = c
        } else {
            colorChoice = .orange
        }
    }
}

// MARK: - Theme

enum Theme {
    private static var config: ThemeConfig { ThemeConfig.shared }

    // MARK: - Style Helpers

    static var isASCII: Bool { config.style == .ascii }
    static var isCyber: Bool { config.style == .cyber }
    static var isGrey: Bool  { config.colorChoice == .grey }
    static var isBW: Bool    { config.colorChoice == .bw }

    // MARK: - Accent Colors

    static var accent: Color {
        if isBW { return config.isDark ? .white : .black }
        return Color(hex: config.colorChoice.hex)
    }

    static var accentHover: Color {
        if isBW { return config.isDark ? Color(hex: 0xCCCCCC) : Color(hex: 0x333333) }
        return Color(hex: config.colorChoice.hoverHex)
    }

    static var accentDark: Color {
        if isBW { return config.isDark ? Color(hex: 0xAAAAAA) : Color(hex: 0x555555) }
        return Color(hex: config.colorChoice.darkHex)
    }

    // MARK: - Backgrounds

    static var bgPage: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.bgPage.dark : p.bgPage.light)
        }
        return config.isDark ? Color(hex: 0x0A0A0A) : Color(hex: 0xF0ECE4)
    }

    static var bgPanel: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.bgPanel.dark : p.bgPanel.light)
        }
        return config.isDark ? Color(hex: 0x111111) : Color(hex: 0xFAF7F2)
    }

    static var bgCanvas: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.bgCanvas.dark : p.bgCanvas.light)
        }
        return config.isDark ? Color(hex: 0x0E0E0E) : Color(hex: 0xF2EDE5)
    }

    static var bgSurface: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.bgSurface.dark : p.bgSurface.light)
        }
        return config.isDark ? Color(hex: 0x161616) : Color(hex: 0xEDE8E0)
    }

    static var bgActive: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.bgActive.dark : p.bgActive.light)
        }
        return config.isDark ? Color(hex: 0x1A1A1A) : Color(hex: 0xE5DFD5)
    }

    // MARK: - Borders

    static var border: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.border.dark : p.border.light)
        }
        return config.isDark ? Color(hex: 0x1C1C1C) : Color(hex: 0xD8D0C5)
    }

    static var borderActive: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.borderActive.dark : p.borderActive.light)
        }
        return config.isDark ? Color(hex: 0x2A2A2A) : Color(hex: 0xC0B8AA)
    }

    static var inputBorder: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.inputBorder.dark : p.inputBorder.light)
        }
        return config.isDark ? Color(hex: 0x222222) : Color(hex: 0xD0C8BC)
    }

    // MARK: - Text

    static var text1: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.text1.dark : p.text1.light)
        }
        return config.isDark ? Color(hex: 0xE8E8E8) : Color(hex: 0x2A2420)
    }

    static var text2: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.text2.dark : p.text2.light)
        }
        return config.isDark ? Color(hex: 0x888888) : Color(hex: 0x807870)
    }

    static var text3: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.text3.dark : p.text3.light)
        }
        return config.isDark ? Color(hex: 0x555555) : Color(hex: 0xA09888)
    }

    static var text4: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.text4.dark : p.text4.light)
        }
        return config.isDark ? Color(hex: 0x444444) : Color(hex: 0xB0A898)
    }

    static var text5: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.text5.dark : p.text5.light)
        }
        return config.isDark ? Color(hex: 0x333333) : Color(hex: 0xC0B8B0)
    }

    static var placeholder: Color {
        if let p = config.colorChoice.brandPalette {
            return Color(hex: config.isDark ? p.placeholder.dark : p.placeholder.light)
        }
        return config.isDark ? Color(hex: 0x666666) : Color(hex: 0x9A9080)
    }

    // MARK: - Radii (style-dependent)

    static var radiusLg: CGFloat {
        switch config.style {
        case .default:   return 20
        case .brutalist:  return 0
        case .soft:      return 28
        case .tight:     return 4
        case .ascii:     return 0
        case .cyber:     return 2
        }
    }

    static var radiusMd: CGFloat {
        switch config.style {
        case .default:   return 10
        case .brutalist:  return 0
        case .soft:      return 16
        case .tight:     return 3
        case .ascii:     return 0
        case .cyber:     return 2
        }
    }

    static var radiusSm: CGFloat {
        switch config.style {
        case .default:   return 8
        case .brutalist:  return 0
        case .soft:      return 12
        case .tight:     return 2
        case .ascii:     return 0
        case .cyber:     return 1
        }
    }

    // MARK: - Border Style

    static var borderWidth: CGFloat {
        config.style == .brutalist ? 2 : 1
    }

    static var borderStrokeStyle: StrokeStyle {
        if config.style == .ascii {
            return StrokeStyle(lineWidth: 1, dash: [4, 3])
        }
        return StrokeStyle(lineWidth: borderWidth)
    }

    // MARK: - Panel Shadow

    struct PanelShadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    static var panelShadow: PanelShadow {
        switch config.style {
        case .default:
            return PanelShadow(color: .black.opacity(0.6), radius: 40, x: 0, y: 8)
        case .brutalist:
            return PanelShadow(color: .black.opacity(0.35), radius: 0, x: 8, y: 8)
        case .soft:
            return PanelShadow(color: .black.opacity(0.2), radius: 32, x: 0, y: 16)
        case .tight:
            return PanelShadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
        case .ascii:
            return PanelShadow(color: .clear, radius: 0, x: 0, y: 0)
        case .cyber:
            return PanelShadow(color: accent.opacity(0.3), radius: 30, x: 0, y: 0)
        }
    }

    // MARK: - Dimensions

    static let panelWidth: CGFloat     = 1060
    static let panelHeight: CGFloat    = 600
    static let sidebarWidth: CGFloat   = 260

    enum PanelSize: String, CaseIterable, Equatable {
        case sm, md, lg

        var dimensions: (width: CGFloat, height: CGFloat) {
            switch self {
            case .sm: return (720, 440)
            case .md: return (880, 520)
            case .lg: return (1060, 600)
            }
        }

        var sidebarWidth: CGFloat {
            switch self {
            case .sm: return 190
            case .md: return 220
            case .lg: return 260
            }
        }

        var fontScale: CGFloat {
            switch self {
            case .sm: return 0.85
            case .md: return 0.92
            case .lg: return 1.0
            }
        }

        var padding: CGFloat {
            switch self {
            case .sm: return 12
            case .md: return 16
            case .lg: return 20
            }
        }
    }

    static var currentPadding: CGFloat { ThemeConfig.shared.panelSize.padding }
    static var canvasPadding: CGFloat  { ThemeConfig.shared.panelSize == .sm ? 8 : 14 }
    static let seamWidth: CGFloat      = 6

    // MARK: - Fonts

    static func mainFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if config.style == .ascii { return monoFont(size, weight: weight) }
        switch config.font {
        case .grotesk:
            let name = spaceName(for: weight)
            if NSFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            return .system(size: size, weight: weight, design: .rounded)
        case .mono:
            return monoFont(size, weight: weight)
        case .inter:
            let name = interName(for: weight)
            if NSFont(name: name, size: size) != nil {
                return .custom(name, size: size)
            }
            if let helv = NSFont(name: "HelveticaNeue", size: size) {
                return Font(helv)
            }
            return .system(size: size, weight: weight, design: .default)
        case .system:
            return .system(size: size, weight: weight, design: .default)
        }
    }

    static func monoFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name = monoName(for: weight)
        if NSFont(name: name, size: size) != nil {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight, design: .monospaced)
    }

    private static func spaceName(for weight: Font.Weight) -> String {
        switch weight {
        case .light:    return "SpaceGrotesk-Light"
        case .medium:   return "SpaceGrotesk-Medium"
        case .semibold: return "SpaceGrotesk-SemiBold"
        case .bold:     return "SpaceGrotesk-Bold"
        default:        return "SpaceGrotesk-Regular"
        }
    }

    private static func interName(for weight: Font.Weight) -> String {
        switch weight {
        case .light:    return "Inter-Light"
        case .medium:   return "Inter-Medium"
        case .semibold: return "Inter-SemiBold"
        case .bold:     return "Inter-Bold"
        default:        return "Inter-Regular"
        }
    }

    private static func monoName(for weight: Font.Weight) -> String {
        switch weight {
        case .light:    return "JetBrainsMono-Light"
        case .medium:   return "JetBrainsMono-Medium"
        case .semibold: return "JetBrainsMono-SemiBold"
        case .bold:     return "JetBrainsMono-Bold"
        default:        return "JetBrainsMono-Regular"
        }
    }

    // MARK: - App Colors

    struct AppColor {
        let bg: Color
        let text: Color
    }

    static func appColor(for bundleId: String) -> AppColor {
        let id = bundleId.lowercased()
        let colorChoice = config.colorChoice
        let isDark = config.isDark

        // Deterministic per-process hash (consistent within session)
        let stableHash = bundleId.unicodeScalars.reduce(0) { acc, c in acc &* 31 &+ Int(c.value) }

        // Brand schemes: multi-color cycling by bundle ID
        switch colorChoice {
        case .google:
            let palettes: [(bg: UInt32, text: UInt32)] = isDark ? [
                (0x1B2A3A, 0x4285F4),
                (0x3A1C1C, 0xEA4335),
                (0x2B2500, 0xFBBC04),
                (0x1C2E1C, 0x34A853),
            ] : [
                (0xD2E3FC, 0x1565C0),
                (0xFCE8E8, 0xC62828),
                (0xFEF7DC, 0xF57F17),
                (0xD4EDDA, 0x2E7D32),
            ]
            let idx = abs(stableHash) % palettes.count
            return AppColor(bg: Color(hex: palettes[idx].bg), text: Color(hex: palettes[idx].text))

        case .apple:
            let palettes: [(bg: UInt32, text: UInt32)] = isDark ? [
                (0x002855, 0x0A84FF),
                (0x1A3A1A, 0x30D158),
                (0x3A2000, 0xFF9F0A),
                (0x3A0A0A, 0xFF453A),
                (0x2A1A3A, 0xBF5AF2),
                (0x3A0A1A, 0xFF375F),
            ] : [
                (0xD5E8FF, 0x0040DD),
                (0xD4EDDA, 0x248A3D),
                (0xFFEDD5, 0xC93400),
                (0xFFD5D5, 0xC41230),
                (0xEDD5FF, 0x8944AB),
                (0xFFD5E5, 0xC30022),
            ]
            let idx = abs(stableHash) % palettes.count
            return AppColor(bg: Color(hex: palettes[idx].bg), text: Color(hex: palettes[idx].text))

        case .dracula:
            let palettes: [(bg: UInt32, text: UInt32)] = isDark ? [
                (0x231D35, 0xBD93F9),
                (0x2A1730, 0xFF79C6),
                (0x1A2A20, 0x50FA7B),
                (0x2A2805, 0xF1FA8C),
                (0x0A2828, 0x8BE9FD),
                (0x2A2010, 0xFFB86C),
            ] : [
                (0xEAE6FF, 0x6A3DAF),
                (0xFFE5F4, 0xAA004A),
                (0xDEF5E0, 0x1A7A1A),
                (0xFFF8CC, 0x7A5A00),
                (0xCCF5FF, 0x005A7A),
                (0xFFF0CC, 0x7A4000),
            ]
            let idx = abs(stableHash) % palettes.count
            return AppColor(bg: Color(hex: palettes[idx].bg), text: Color(hex: palettes[idx].text))

        case .claude:
            let palettes: [(bg: UInt32, text: UInt32)] = isDark ? [
                (0x2A1810, 0xDA7756),
                (0x1E2420, 0x56A07A),
                (0x221820, 0xAA5566),
                (0x1A1E28, 0x6677AA),
            ] : [
                (0xF5E5DD, 0xAA4422),
                (0xE0F0E8, 0x2A7A50),
                (0xF0E0E5, 0x882244),
                (0xE0E5F5, 0x334488),
            ]
            let idx = abs(stableHash) % palettes.count
            return AppColor(bg: Color(hex: palettes[idx].bg), text: Color(hex: palettes[idx].text))

        case .grey:
            let darkBgs:   [UInt32] = [0x1E1E1E, 0x232323, 0x282828, 0x1A1A1A]
            let darkTexts: [UInt32] = [0x666666, 0x777777, 0x555555, 0x888888]
            let lightBgs:  [UInt32] = [0xE0E0E0, 0xD8D8D8, 0xE5E5E5, 0xCCCCCC]
            let lightTexts:[UInt32] = [0x444444, 0x555555, 0x333333, 0x666666]
            let idx = abs(stableHash) % 4
            return isDark
                ? AppColor(bg: Color(hex: darkBgs[idx]),  text: Color(hex: darkTexts[idx]))
                : AppColor(bg: Color(hex: lightBgs[idx]), text: Color(hex: lightTexts[idx]))

        case .bw:
            return isDark
                ? AppColor(bg: Color(hex: 0x1A1A1A), text: Color(hex: 0x888888))
                : AppColor(bg: Color(hex: 0xE5E5E5), text: Color(hex: 0x222222))

        default:
            break
        }

        // Standard schemes: named app colors with dark/light adaptation
        if id.contains("vscode") || id.contains("cursor") {
            return isDark
                ? AppColor(bg: Color(hex: 0x1E2636), text: Color(hex: 0x7090BB))
                : AppColor(bg: Color(hex: 0xD8E5F5), text: Color(hex: 0x1E4A90))
        } else if id.contains("terminal") || id.contains("iterm") {
            return isDark
                ? AppColor(bg: Color(hex: 0x252525), text: Color(hex: 0x888888))
                : AppColor(bg: Color(hex: 0xDEDEDE), text: Color(hex: 0x3A3A3A))
        } else if id.contains("safari") {
            return isDark
                ? AppColor(bg: Color(hex: 0x333333), text: Color(hex: 0x888888))
                : AppColor(bg: Color(hex: 0xE5E5E5), text: Color(hex: 0x444444))
        } else if id.contains("slack") {
            return isDark
                ? AppColor(bg: Color(hex: 0x2A2A2A), text: Color(hex: 0x666666))
                : AppColor(bg: Color(hex: 0xE2E2E2), text: Color(hex: 0x3A3A3A))
        } else if id.contains("figma") {
            return isDark
                ? AppColor(bg: Color(hex: 0x3D1F6B), text: Color(hex: 0xC49AFF))
                : AppColor(bg: Color(hex: 0xEADAFF), text: Color(hex: 0x6B2DB8))
        } else if id.contains("notes") {
            return isDark
                ? AppColor(bg: Color(hex: 0x2A2A1E), text: Color(hex: 0x887744))
                : AppColor(bg: Color(hex: 0xFFF8DC), text: Color(hex: 0x6B5A1E))
        } else if id.contains("spotify") {
            return isDark
                ? AppColor(bg: Color(hex: 0x1A2A1E), text: Color(hex: 0x449944))
                : AppColor(bg: Color(hex: 0xD8EED8), text: Color(hex: 0x1A5A1A))
        } else if id.contains("messages") || id.contains("mobilesms") {
            return isDark
                ? AppColor(bg: Color(hex: 0x1E2233), text: Color(hex: 0x5577CC))
                : AppColor(bg: Color(hex: 0xDAE4FF), text: Color(hex: 0x1A3A9A))
        } else if id.contains("chrome") || id.contains("arc") {
            return isDark
                ? AppColor(bg: Color(hex: 0x2A2533), text: Color(hex: 0x9977CC))
                : AppColor(bg: Color(hex: 0xECE3FF), text: Color(hex: 0x6A40AA))
        } else if id.contains("mail") {
            return isDark
                ? AppColor(bg: Color(hex: 0x1E2A33), text: Color(hex: 0x5599BB))
                : AppColor(bg: Color(hex: 0xDAEEFF), text: Color(hex: 0x1A5A8A))
        } else if id.contains("xcode") {
            return isDark
                ? AppColor(bg: Color(hex: 0x1A2636), text: Color(hex: 0x5588CC))
                : AppColor(bg: Color(hex: 0xD8E8FF), text: Color(hex: 0x1A4A9A))
        } else if id.contains("finder") {
            return isDark
                ? AppColor(bg: Color(hex: 0x1A2A33), text: Color(hex: 0x5599AA))
                : AppColor(bg: Color(hex: 0xDAEEF5), text: Color(hex: 0x1A5A7A))
        } else {
            let hue = Double(abs(stableHash) % 360) / 360.0
            return isDark
                ? AppColor(
                    bg: Color(hue: hue, saturation: 0.2, brightness: 0.15),
                    text: Color(hue: hue, saturation: 0.3, brightness: 0.55))
                : AppColor(
                    bg: Color(hue: hue, saturation: 0.15, brightness: 0.88),
                    text: Color(hue: hue, saturation: 0.5, brightness: 0.35))
        }
    }

    // MARK: - Themed Border Modifier

    struct ThemedBorder: ViewModifier {
        var radius: CGFloat
        var color: Color?

        func body(content: Content) -> some View {
            content.overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color ?? Theme.border, style: Theme.borderStrokeStyle)
            )
        }
    }
}

// MARK: - View Extension

extension View {
    func themedBorder(radius: CGFloat = Theme.radiusMd, color: Color? = nil) -> some View {
        modifier(Theme.ThemedBorder(radius: radius, color: color))
    }
}

// MARK: - Scanline Overlay (ASCII)

struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let lineCount = Int(geo.size.height / 4)
            Path { path in
                for i in 0..<lineCount {
                    let y = CGFloat(i) * 4 + 2
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.gray.opacity(0.035), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Dot Grid Overlay (Cyber)

struct DotGridOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let cols = Int(geo.size.width / 16) + 1
            let rows = Int(geo.size.height / 16) + 1
            Path { path in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * 16
                        let y = CGFloat(row) * 16
                        path.addEllipse(in: CGRect(x: x - 0.5, y: y - 0.5, width: 1, height: 1))
                    }
                }
            }
            .fill(Color.white.opacity(0.025))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Cyber Bracket Overlay

struct CyberBracketOverlay: View {
    var opacity: Double = 0.35

    var body: some View {
        GeometryReader { geo in
            let size: CGFloat = 10
            let inset: CGFloat = 6
            // Top-left bracket
            Path { path in
                path.move(to: CGPoint(x: inset, y: inset + size))
                path.addLine(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: inset + size, y: inset))
            }
            .stroke(Theme.accent.opacity(opacity), lineWidth: 1)

            // Bottom-right bracket
            Path { path in
                path.move(to: CGPoint(x: geo.size.width - inset - size, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset - size))
            }
            .stroke(Theme.accent.opacity(opacity), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
