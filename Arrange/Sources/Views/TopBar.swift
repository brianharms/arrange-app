import SwiftUI
import AppKit

// MARK: - Window Drag Handle

struct WindowDragHandle: NSViewRepresentable {
    func makeNSView(context: Context) -> DragHandleView { DragHandleView() }
    func updateNSView(_ nsView: DragHandleView, context: Context) {}
}

class DragHandleView: NSView {
    override var mouseDownCanMoveWindow: Bool { true }
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

// MARK: - Traffic Light Button

struct TrafficLight: View {
    let fillColor: Color
    let symbol: String
    let groupHovered: Bool
    let action: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 12, height: 12)

            if groupHovered {
                Image(systemName: symbol)
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(.black.opacity(0.5))
            }
        }
        .contentShape(Circle())
        .onTapGesture { action() }
    }
}

// MARK: - Top Bar

struct TopBar: View {
    var dismiss: () -> Void
    var minimize: () -> Void = {}
    var zoom: () -> Void = {}
    @State private var showThemePopover = false
    @State private var trafficHovered = false

    private let trafficRed = Color(red: 1.0, green: 0.373, blue: 0.341)
    private let trafficYellow = Color(red: 1.0, green: 0.741, blue: 0.180)
    private let trafficGreen = Color(red: 0.157, green: 0.788, blue: 0.251)

    var body: some View {
        HStack {
            // Traffic lights
            HStack(spacing: 8) {
                TrafficLight(fillColor: trafficRed, symbol: "xmark", groupHovered: trafficHovered) {
                    dismiss()
                }
                TrafficLight(fillColor: trafficYellow, symbol: "minus", groupHovered: trafficHovered) {
                    minimize()
                }
                TrafficLight(fillColor: trafficGreen, symbol: "plus", groupHovered: trafficHovered) {
                    zoom()
                }
            }
            .onHover { trafficHovered = $0 }
            .padding(.trailing, 8)

            // ARRANGE title (left side)
            Text("ARRANGE")
                .font(Theme.mainFont(15, weight: .bold))
                .foregroundStyle(Theme.text1)
                .tracking(Theme.isCyber ? 6 : 0)
                .allowsHitTesting(false)

            Spacer()

            // Logo (right side, centroid aligned with LG size button)
            Button(action: { showThemePopover.toggle() }) {
                BrandIcon()
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showThemePopover, arrowEdge: .bottom) {
                ThemePopover()
            }
            .padding(.trailing, 5)
        }
        .padding(.vertical, ThemeConfig.shared.panelSize == .sm ? 10 : 16)
        .padding(.horizontal, ThemeConfig.shared.panelSize == .sm ? 16 : 24)
        .background { WindowDragHandle() }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}

// MARK: - Brand Icon

struct BrandIcon: View {
    var body: some View {
        Canvas { context, size in
            let gap: CGFloat = 2
            let blockW = (size.width - gap) / 2
            let blockH = (size.height - gap) / 2

            let r: CGFloat = 3
            context.fill(
                Path(roundedRect: CGRect(x: 0, y: 0, width: blockW, height: blockH), cornerRadius: r),
                with: .color(Theme.accent)
            )
            context.fill(
                Path(roundedRect: CGRect(x: blockW + gap, y: 0, width: blockW, height: blockH), cornerRadius: r),
                with: .color(Theme.text5)
            )
            context.fill(
                Path(roundedRect: CGRect(x: 0, y: blockH + gap, width: blockW, height: blockH), cornerRadius: r),
                with: .color(Theme.text5)
            )
            context.fill(
                Path(roundedRect: CGRect(x: blockW + gap, y: blockH + gap, width: blockW, height: blockH), cornerRadius: r),
                with: .color(Theme.bgActive)
            )
        }
        .frame(width: 24, height: 24)
    }
}

// MARK: - Theme Popover

struct ThemePopover: View {
    private let config = ThemeConfig.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Style section — 3x2 grid
            VStack(alignment: .leading, spacing: 8) {
                Text("STYLE")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                let columns = [
                    GridItem(.flexible(), spacing: 4),
                    GridItem(.flexible(), spacing: 4),
                    GridItem(.flexible(), spacing: 4)
                ]
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(ThemeStyle.allCases, id: \.self) { style in
                        Button(action: { config.style = style }) {
                            Text(style.displayName)
                                .font(Theme.monoFont(10, weight: config.style == style ? .bold : .medium))
                                .foregroundStyle(config.style == style ? Theme.accent : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    config.style == style ? Theme.accent.opacity(0.15) : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(config.style == style ? Theme.accent.opacity(0.4) : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider().opacity(0.3)

            // Font section — segmented
            VStack(alignment: .leading, spacing: 8) {
                Text("FONT")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                HStack(spacing: 0) {
                    ForEach(ThemeFont.allCases, id: \.self) { font in
                        Button(action: { config.font = font }) {
                            Text(font.displayName)
                                .font(Theme.monoFont(10, weight: config.font == font ? .bold : .medium))
                                .foregroundStyle(config.font == font ? Theme.text1 : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(
                                    config.font == font ? Theme.bgActive : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 4)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Theme.bgSurface, in: RoundedRectangle(cornerRadius: 6))
            }

            Divider().opacity(0.3)

            // Color section
            VStack(alignment: .leading, spacing: 8) {
                Text("COLOR")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                HStack(spacing: 6) {
                    // Main colors
                    ForEach(ThemeColor.mainColors, id: \.self) { color in
                        ColorSwatch(color: color, isActive: config.colorChoice == color) {
                            config.colorChoice = color
                        }
                    }

                    // Separator
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 18)
                        .padding(.horizontal, 2)

                    // Special colors
                    ForEach(ThemeColor.specialColors, id: \.self) { color in
                        ColorSwatch(color: color, isActive: config.colorChoice == color) {
                            config.colorChoice = color
                        }
                    }
                }
            }

            Divider().opacity(0.3)

            // Schemes section
            VStack(alignment: .leading, spacing: 8) {
                Text("SCHEME")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                HStack(spacing: 12) {
                    ForEach(ThemeColor.brandColors, id: \.self) { color in
                        VStack(spacing: 3) {
                            ColorSwatch(color: color, isActive: config.colorChoice == color) {
                                config.colorChoice = color
                            }
                            Text(color.displayName)
                                .font(Theme.monoFont(8))
                                .foregroundStyle(config.colorChoice == color ? Theme.text1 : .secondary)
                        }
                    }
                }
            }

            Divider().opacity(0.3)

            // Mode toggle
            HStack {
                Text("MODE")
                    .font(Theme.monoFont(9, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                Spacer()

                HStack(spacing: 0) {
                    Button(action: { config.isDark = true }) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(config.isDark ? .white : .secondary)
                            .frame(width: 28, height: 24)
                            .background(config.isDark ? Theme.accent.opacity(0.3) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)

                    Button(action: { config.isDark = false }) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(!config.isDark ? .white : .secondary)
                            .frame(width: 28, height: 24)
                            .background(!config.isDark ? Theme.accent.opacity(0.3) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(width: 320)
    }
}

// MARK: - Color Swatch

struct ColorSwatch: View {
    let color: ThemeColor
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if color == .bw {
                    // Half black / half white
                    ZStack {
                        Circle().fill(.white)
                        HalfCircle()
                            .fill(.black)
                            .frame(width: 18, height: 18)
                    }
                } else {
                    Circle().fill(Color(hex: color.hex))
                }
            }
            .frame(width: 18, height: 18)
            .overlay(
                Circle()
                    .stroke(.white.opacity(isActive ? 0.8 : 0), lineWidth: 2)
                    .padding(1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Half Circle Shape

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: .degrees(-90),
            endAngle: .degrees(90),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}
