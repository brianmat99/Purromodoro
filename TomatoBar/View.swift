import AppKit
import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

extension KeyboardShortcuts.Name {
    static let startStopTimer = Self("startStopTimer")
}

private struct AnimatedGIFView: NSViewRepresentable {
    let gifName: String

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        let imageView = NSImageView()
        imageView.canDrawSubviewsIntoLayer = true
        imageView.imageScaling = .scaleProportionallyDown
        imageView.animates = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: container.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: container.heightAnchor),
        ])
        loadGIF(into: imageView)
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let imageView = nsView.subviews.first as? NSImageView {
            loadGIF(into: imageView)
        }
    }

    private func loadGIF(into imageView: NSImageView) {
        if let url = Bundle.main.url(forResource: gifName, withExtension: "gif"),
           let image = NSImage(contentsOf: url) {
            imageView.image = image
            imageView.animates = true
        }
    }
}

private struct StatusGIFView: View {
    let intervalName: String
    let isPaused: Bool

    private var gifName: String {
        switch intervalName {
        case "Work": return "cat_work"
        case "Short Rest": return "cat_short_rest"
        case "Long Rest": return "cat_long_rest"
        default: return "cat_work"
        }
    }

    private var tagline: String {
        switch intervalName {
        case "Work": return NSLocalizedString("StatusGIFView.tagline.work", comment: "Work tagline")
        case "Short Rest": return NSLocalizedString("StatusGIFView.tagline.shortRest", comment: "Short rest tagline")
        case "Long Rest": return NSLocalizedString("StatusGIFView.tagline.longRest", comment: "Long rest tagline")
        default: return ""
        }
    }

    private var hasGIF: Bool {
        Bundle.main.url(forResource: gifName, withExtension: "gif") != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(tagline)
                .font(.system(.callout, design: .rounded))
                .fontWeight(.medium)
                .padding(.bottom, -4)
            if hasGIF {
                AnimatedGIFView(gifName: gifName)
                    .frame(width: 112, height: 112)
                    .clipped()
                    .opacity(isPaused ? 0.5 : 1.0)
            }
            if isPaused {
                Text("(Paused)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("(Paused)")
                    .font(.caption)
                    .hidden()
            }
        }
    }
}

private let integerFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    formatter.allowsFloats = false
    formatter.minimum = 0
    return formatter
}()

private struct IntervalsView: View {
    @EnvironmentObject var timer: TBTimer
    private var minStr = NSLocalizedString("IntervalsView.min", comment: "min")

    var body: some View {
        VStack {
            Stepper(value: $timer.workIntervalLength, in: 1 ... 60) {
                HStack {
                    Text(NSLocalizedString("IntervalsView.workIntervalLength.label",
                                           comment: "Work interval label"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", value: $timer.workIntervalLength, formatter: integerFormatter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                    Text("min")
                }
            }
            Stepper(value: $timer.shortRestIntervalLength, in: 1 ... 60) {
                HStack {
                    Text(NSLocalizedString("IntervalsView.shortRestIntervalLength.label",
                                           comment: "Short rest interval label"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", value: $timer.shortRestIntervalLength, formatter: integerFormatter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                    Text("min")
                }
            }
            Stepper(value: $timer.longRestIntervalLength, in: 1 ... 60) {
                HStack {
                    Text(NSLocalizedString("IntervalsView.longRestIntervalLength.label",
                                           comment: "Long rest interval label"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", value: $timer.longRestIntervalLength, formatter: integerFormatter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                    Text("min")
                }
            }
            .help(NSLocalizedString("IntervalsView.longRestIntervalLength.help",
                                    comment: "Long rest interval hint"))
            Stepper(value: $timer.workIntervalsInSet, in: 1 ... 10) {
                HStack {
                    Text(NSLocalizedString("IntervalsView.workIntervalsInSet.label",
                                           comment: "Work intervals in a set label"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("", value: $timer.workIntervalsInSet, formatter: integerFormatter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                }
            }
            .help(NSLocalizedString("IntervalsView.workIntervalsInSet.help",
                                    comment: "Work intervals in set hint"))
            Spacer().frame(minHeight: 0)
        }
        .padding(4)
    }
}

private struct SettingsView: View {
    @EnvironmentObject var timer: TBTimer
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

    var body: some View {
        VStack {
            KeyboardShortcuts.Recorder(for: .startStopTimer) {
                Text(NSLocalizedString("SettingsView.shortcut.label",
                                       comment: "Shortcut label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Toggle(isOn: $timer.stopAfterBreak) {
                Text(NSLocalizedString("SettingsView.stopAfterBreak.label",
                                       comment: "Stop after break label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.toggleStyle(.switch)
            Toggle(isOn: $timer.showTimerInMenuBar) {
                Text(NSLocalizedString("SettingsView.showTimerInMenuBar.label",
                                       comment: "Show timer in menu bar label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.toggleStyle(.switch)
                .onChange(of: timer.showTimerInMenuBar) { _ in
                    timer.updateTimeLeft()
                }
            Toggle(isOn: $launchAtLogin.isEnabled) {
                Text(NSLocalizedString("SettingsView.launchAtLogin.label",
                                       comment: "Launch at login label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.toggleStyle(.switch)
            Spacer().frame(minHeight: 0)
        }
        .padding(4)
    }
}

private struct VolumeSlider: View {
    @Binding var volume: Double

    var body: some View {
        Slider(value: $volume, in: 0...2) {
            Text(String(format: "%.1f", volume))
        }.gesture(TapGesture(count: 2).onEnded({
            volume = 1.0
        }))
    }
}

private struct SoundsView: View {
    @EnvironmentObject var player: TBPlayer

    private var columns = [
        GridItem(.flexible()),
        GridItem(.fixed(110))
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
            Text(NSLocalizedString("SoundsView.meow.label",
                                   comment: "Meow label"))
            VolumeSlider(volume: $player.meowVolume)
            Text(NSLocalizedString("SoundsView.ding.label",
                                   comment: "Ding label"))
            VolumeSlider(volume: $player.dingVolume)
            Text(NSLocalizedString("SoundsView.purr.label",
                                   comment: "Purr label"))
            VolumeSlider(volume: $player.purrVolume)
        }.padding(4)
        Spacer().frame(minHeight: 0)
    }
}

private enum ChildView {
    case intervals, settings, sounds
}

struct TBPopoverView: View {
    @ObservedObject var timer = TBTimer()
    @State private var buttonHovered = false
    @State private var activeChildView = ChildView.intervals
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false

    private var startLabel = NSLocalizedString("TBPopoverView.start.label", comment: "Start label")
    private var stopLabel = NSLocalizedString("TBPopoverView.stop.label", comment: "Stop label")

    private let holdDuration: TimeInterval = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if timer.timer != nil {
                StatusGIFView(intervalName: timer.currentIntervalName, isPaused: timer.isPaused)
                    .frame(maxWidth: .infinity)
            }

            HStack(spacing: 8) {
                if timer.timer != nil {
                    Button {
                        timer.togglePause()
                    } label: {
                        Image(systemName: timer.isPaused ? "play.fill" : "pause.fill")
                            .foregroundColor(Color.white)
                            .frame(width: 20)
                    }
                    .controlSize(.large)
                }
                if timer.canSkip {
                    Button {
                        timer.skipCurrentInterval()
                    } label: {
                        Image(systemName: "forward.fill")
                            .foregroundColor(Color.white)
                            .frame(width: 20)
                    }
                    .controlSize(.large)
                    .help("Skip \(timer.currentIntervalName)")
                }
                if timer.timer != nil {
                    // Hold-to-stop button with progress overlay
                    ZStack(alignment: .leading) {
                        // Progress fill
                        GeometryReader { geo in
                            Rectangle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: geo.size.width * holdProgress)
                        }
                        .cornerRadius(6)

                        Text("Hold to Stop")
                            .foregroundColor(Color.white)
                            .font(.system(.body).monospacedDigit())
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 28)
                    .background(Color.accentColor)
                    .cornerRadius(6)
                    .controlSize(.large)
                    .onHover { over in
                        buttonHovered = over
                    }
                    .onLongPressGesture(minimumDuration: holdDuration, perform: {
                        // Hold completed — stop the timer
                        withAnimation(.none) {
                            holdProgress = 0
                            isHolding = false
                        }
                        timer.startStop()
                        TBStatusItem.shared.closePopover(nil)
                    }, onPressingChanged: { pressing in
                        if pressing {
                            isHolding = true
                            withAnimation(.linear(duration: holdDuration)) {
                                holdProgress = 1.0
                            }
                        } else {
                            isHolding = false
                            withAnimation(.easeOut(duration: 0.2)) {
                                holdProgress = 0
                            }
                        }
                    })
                } else {
                    Button {
                        timer.startStop()
                        TBStatusItem.shared.closePopover(nil)
                    } label: {
                        Text(startLabel)
                            .foregroundColor(Color.white)
                            .font(.system(.body).monospacedDigit())
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .keyboardShortcut(.defaultAction)
                }
            }

            if timer.timer != nil || timer.consecutiveWorkIntervals > 0 {
                Text("\(timer.consecutiveWorkIntervals)/\(timer.workIntervalsInSet) work intervals until long rest")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }

            Picker("", selection: $activeChildView) {
                Text(NSLocalizedString("TBPopoverView.intervals.label",
                                       comment: "Intervals label")).tag(ChildView.intervals)
                Text(NSLocalizedString("TBPopoverView.settings.label",
                                       comment: "Settings label")).tag(ChildView.settings)
                Text(NSLocalizedString("TBPopoverView.sounds.label",
                                       comment: "Sounds label")).tag(ChildView.sounds)
            }
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .pickerStyle(.segmented)

            GroupBox {
                switch activeChildView {
                case .intervals:
                    IntervalsView().environmentObject(timer)
                case .settings:
                    SettingsView().environmentObject(timer)
                case .sounds:
                    SoundsView().environmentObject(timer.player)
                }
            }

            Group {
                if timer.dailyCompletedCount > 0 {
                    Text("Purromodoro count today: \(timer.dailyCompletedCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
                Button {
                    NSApplication.shared.terminate(self)
                } label: {
                    Text(NSLocalizedString("TBPopoverView.quit.label",
                                           comment: "Quit label"))
                    Spacer()
                    Text("⌘ Q").foregroundColor(Color.gray)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("q")
            }
        }
        #if DEBUG
            /*
             After several hours of Googling and trying various StackOverflow
             recipes I still haven't figured a reliable way to auto resize
             popover to fit all it's contents (pull requests are welcome!).
             The following code block is used to determine the optimal
             geometry of the popover.
             */
            .overlay(
                GeometryReader { proxy in
                    debugSize(proxy: proxy)
                }
            )
        #endif
            /* Use values from GeometryReader */
//            .frame(width: 240, height: 276)
            .padding(12)
    }
}

#if DEBUG
    func debugSize(proxy: GeometryProxy) -> some View {
        print("Optimal popover size:", proxy.size)
        return Color.clear
    }
#endif
