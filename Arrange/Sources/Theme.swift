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
    case grotesk, mono, system

    var displayName: String {
        switch self {
        case .grotesk: return "Grotesk"
        case .mono:    return "Mono"
        case .system:  return "System"
        }
    }
}

// MARK: - Theme Color

enum ThemeColor: String, CaseIterable {
    case red, orange, amber, green, teal, cyan, blue, violet, rose, grey, bw

    var displayName: String {
        switch self {
        case .bw: return "B&W"
        default:  return rawValue.capitalized
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
        case .grey:   return 0x888888
        case .bw:     return 0x000000
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
        case .grey:   return 0x999999
        case .bw:     return 0x000000
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
        case .grey:   return 0x666666
        case .bw:     return 0x000000
        }
    }

    static var mainColors: [ThemeColor] {
        [.red, .orange, .amber, .green, .teal, .cyan, .blue, .violet, .rose]
    }

    static var specialColors: [ThemeColor] {
        [.grey, .bw]
    }
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
    var panelSize: Theme.PanelSize = .sm

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

    // MARK: - Backgrounds (warm-toned light mode)

    static var bgPage: Color    { config.isDark ? Color(hex: 0x0A0A0A) : Color(hex: 0xF0ECE4) }
    static var bgPanel: Color   { config.isDark ? Color(hex: 0x111111) : Color(hex: 0xFAF7F2) }
    static var bgCanvas: Color  { config.isDark ? Color(hex: 0x0E0E0E) : Color(hex: 0xF2EDE5) }
    static var bgSurface: Color { config.isDark ? Color(hex: 0x161616) : Color(hex: 0xEDE8E0) }
    static var bgActive: Color  { config.isDark ? Color(hex: 0x1A1A1A) : Color(hex: 0xE5DFD5) }

    // MARK: - Borders

    static var border: Color       { config.isDark ? Color(hex: 0x1C1C1C) : Color(hex: 0xD8D0C5) }
    static var borderActive: Color { config.isDark ? Color(hex: 0x2A2A2A) : Color(hex: 0xC0B8AA) }
    static var inputBorder: Color  { config.isDark ? Color(hex: 0x222222) : Color(hex: 0xD0C8BC) }

    // MARK: - Text

    static var text1: Color { config.isDark ? Color(hex: 0xE8E8E8) : Color(hex: 0x2A2420) }
    static var text2: Color { config.isDark ? Color(hex: 0x888888) : Color(hex: 0x807870) }
    static var text3: Color { config.isDark ? Color(hex: 0x555555) : Color(hex: 0xA09888) }
    static var text4: Color { config.isDark ? Color(hex: 0x444444) : Color(hex: 0xB0A898) }
    static var text5: Color { config.isDark ? Color(hex: 0x333333) : Color(hex: 0xC0B8B0) }
    static var placeholder: Color { config.isDark ? Color(hex: 0x666666) : Color(hex: 0x9A9080) }

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
            return .system(size: size, weight: weight, design: .default)
        case .mono:
            return monoFont(size, weight: weight)
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

        if id.contains("vscode") || id.contains("cursor") {
            return AppColor(bg: Color(hex: 0x1E2636), text: Color(hex: 0x7090BB))
        } else if id.contains("terminal") || id.contains("iterm") {
            return AppColor(bg: Color(hex: 0x252525), text: Color(hex: 0x888888))
        } else if id.contains("safari") {
            return AppColor(bg: Color(hex: 0x333333), text: Color(hex: 0x888888))
        } else if id.contains("slack") {
            return AppColor(bg: Color(hex: 0x2A2A2A), text: Color(hex: 0x666666))
        } else if id.contains("figma") {
            return AppColor(bg: Color(hex: 0x3D1F6B), text: Color(hex: 0xC49AFF))
        } else if id.contains("notes") {
            return AppColor(bg: Color(hex: 0x2A2A1E), text: Color(hex: 0x887744))
        } else if id.contains("spotify") {
            return AppColor(bg: Color(hex: 0x1A2A1E), text: Color(hex: 0x449944))
        } else if id.contains("messages") || id.contains("mobilesms") {
            return AppColor(bg: Color(hex: 0x1E2233), text: Color(hex: 0x5577CC))
        } else if id.contains("chrome") || id.contains("arc") {
            return AppColor(bg: Color(hex: 0x2A2533), text: Color(hex: 0x9977CC))
        } else if id.contains("mail") {
            return AppColor(bg: Color(hex: 0x1E2A33), text: Color(hex: 0x5599BB))
        } else if id.contains("xcode") {
            return AppColor(bg: Color(hex: 0x1A2636), text: Color(hex: 0x5588CC))
        } else if id.contains("finder") {
            return AppColor(bg: Color(hex: 0x1A2A33), text: Color(hex: 0x5599AA))
        } else {
            let hash = abs(bundleId.hashValue)
            let hue = Double(hash % 360) / 360.0
            return AppColor(
                bg: Color(hue: hue, saturation: 0.2, brightness: 0.15),
                text: Color(hue: hue, saturation: 0.3, brightness: 0.55)
            )
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
