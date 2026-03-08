//
//  ListenViewControllerVariants.swift
//  lang-apps
//
//  Created by Burak Kose on 16.02.2026.
//

import UIKit
import AVFoundation

final class ListenViewControllerVariant1: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let station: LearningStation
    private let subtitleText: String
    private let subtitleColor: UIColor
    private let showWords: Bool
    private let rows: [ListenVariantContextRow]

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let stickyHeaderContainerView = UIView()
    private let stickyHeaderView = ListenVariantStickyHeaderView()

    private let stickyHeaderHorizontalInset: CGFloat = 15
    private let stickyHeaderTopInset: CGFloat = 12
    private let stickyHeaderBottomInset: CGFloat = 8
    private let stickyHeaderExpandedHeight: CGFloat = 305
    private let stickyHeaderCollapsedHeight: CGFloat = 96
    private let stickyHeaderAnimationDuration: TimeInterval = 0.34

    private var isStickyHeaderCollapsed = false
    private var isUpdatingStickyHeaderLayout = false
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private var durationObserver: NSKeyValueObservation?
    private var isScrubbing = false

    init(station: LearningStation, subtitle: String, subtitleColor: UIColor, showWords: Bool) {
        self.station = station
        self.subtitleText = subtitle
        self.subtitleColor = subtitleColor
        self.showWords = showWords
        self.rows = showWords ? ListenVariantContextRows.rows(for: station.name) : []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
        setupPlayerBindings()
        preparePlayer()
    }

    deinit {
        cleanupPlayer()
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        navigationItem.title = station.name

        let shareBarButton = UIBarButtonItem(
            image: UIImage(named: "share-icon"),
            style: .plain,
            target: self,
            action: #selector(didTapShare)
        )
        if #available(iOS 26.0, *) {
            shareBarButton.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = shareBarButton

        stickyHeaderView.configure(subtitle: subtitleText, subtitleColor: subtitleColor)
        stickyHeaderView.setIconHidden(false, animated: false)

        stickyHeaderContainerView.backgroundColor = .appBackground
        stickyHeaderView.translatesAutoresizingMaskIntoConstraints = false
        stickyHeaderContainerView.addSubview(stickyHeaderView)
        NSLayoutConstraint.activate([
            stickyHeaderView.topAnchor.constraint(equalTo: stickyHeaderContainerView.topAnchor, constant: stickyHeaderTopInset),
            stickyHeaderView.leadingAnchor.constraint(equalTo: stickyHeaderContainerView.leadingAnchor, constant: stickyHeaderHorizontalInset),
            stickyHeaderView.trailingAnchor.constraint(equalTo: stickyHeaderContainerView.trailingAnchor, constant: -stickyHeaderHorizontalInset),
            stickyHeaderView.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor, constant: -stickyHeaderBottomInset)
        ])

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = showWords
        tableView.alwaysBounceVertical = showWords
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListenVariantContextRowCell.self, forCellReuseIdentifier: ListenVariantContextRowCell.reuseId)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc
    private func didTapShare() {
        // Intentionally left empty until share flow is defined.
    }

    private func setupPlayerBindings() {
        stickyHeaderView.onPlayTapped = { [weak self] in
            self?.handlePlayTapped()
        }
        stickyHeaderView.onStopTapped = { [weak self] in
            self?.handleStopTapped()
        }
        stickyHeaderView.onSliderTouchDown = { [weak self] in
            self?.isScrubbing = true
        }
        stickyHeaderView.onSliderValueChanged = { [weak self] value in
            self?.handleSliderValueChanged(value)
        }
        stickyHeaderView.onSliderTouchUp = { [weak self] value in
            self?.handleSliderTouchUp(value)
        }
    }

    private func preparePlayer() {
        guard let url = URL(string: station.streamURL), !station.streamURL.isEmpty else {
            stickyHeaderView.setControlsEnabled(false)
            stickyHeaderView.updateProgress(current: 0, total: 0)
            stickyHeaderView.updatePlaybackState(isPlaying: false)
            return
        }

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.automaticallyWaitsToMinimizeStalling = true
        self.player = player

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Keep silent: playback can still work on some paths even if session setup fails.
        }

        statusObserver = playerItem.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                switch item.status {
                case .failed:
                    self.stickyHeaderView.setControlsEnabled(false)
                    self.stickyHeaderView.updatePlaybackState(isPlaying: false)
                case .readyToPlay, .unknown:
                    self.stickyHeaderView.setControlsEnabled(true)
                @unknown default:
                    self.stickyHeaderView.setControlsEnabled(true)
                }
            }
        }

        durationObserver = playerItem.observe(\.duration, options: [.initial, .new]) { [weak self] item, _ in
            guard let self else { return }
            let total = self.finiteSeconds(from: item.duration) ?? 0
            DispatchQueue.main.async {
                self.stickyHeaderView.updateProgress(current: self.currentPlaybackTime, total: total)
            }
        }

        addTimeObserver(to: player)
        stickyHeaderView.setControlsEnabled(true)
        stickyHeaderView.updateProgress(current: 0, total: 0)
        stickyHeaderView.updatePlaybackState(isPlaying: false)
    }

    private func addTimeObserver(to player: AVPlayer) {
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self, !self.isScrubbing else { return }
            let total = self.finiteSeconds(from: player.currentItem?.duration) ?? 0
            self.stickyHeaderView.updateProgress(current: self.currentPlaybackTime, total: total)
            self.stickyHeaderView.updatePlaybackState(isPlaying: player.timeControlStatus == .playing)
        }
    }

    private func cleanupPlayer() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        statusObserver = nil
        durationObserver = nil
        player?.pause()
        player = nil
    }

    private var currentPlaybackTime: TimeInterval {
        guard let player else { return 0 }
        let seconds = CMTimeGetSeconds(player.currentTime())
        return seconds.isFinite && !seconds.isNaN ? seconds : 0
    }

    private func finiteSeconds(from time: CMTime?) -> TimeInterval? {
        guard let time else { return nil }
        let seconds = CMTimeGetSeconds(time)
        guard seconds.isFinite, !seconds.isNaN else { return nil }
        return max(0, seconds)
    }

    private func handlePlayTapped() {
        if player == nil {
            preparePlayer()
        }
        guard let player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            stickyHeaderView.updatePlaybackState(isPlaying: false)
            return
        }
        player.play()
        stickyHeaderView.updatePlaybackState(isPlaying: true)
    }

    private func handleStopTapped() {
        guard let player else { return }
        player.pause()
        player.seek(to: .zero)
        stickyHeaderView.updatePlaybackState(isPlaying: false)
        let total = finiteSeconds(from: player.currentItem?.duration) ?? 0
        stickyHeaderView.updateProgress(current: 0, total: total)
    }

    private func handleSliderValueChanged(_ value: Float) {
        guard let player else { return }
        guard let total = finiteSeconds(from: player.currentItem?.duration), total > 0 else { return }
        let preview = TimeInterval(value) * total
        stickyHeaderView.updateProgress(current: preview, total: total, updateSlider: false)
    }

    private func handleSliderTouchUp(_ value: Float) {
        defer { isScrubbing = false }
        guard let player else { return }
        guard let total = finiteSeconds(from: player.currentItem?.duration), total > 0 else { return }
        let target = TimeInterval(value) * total
        let seekTime = CMTime(seconds: target, preferredTimescale: 600)
        player.seek(to: seekTime) { [weak self] _ in
            guard let self else { return }
            let updatedTotal = self.finiteSeconds(from: player.currentItem?.duration) ?? total
            self.stickyHeaderView.updateProgress(current: target, total: updatedTotal)
        }
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListenVariantContextRowCell.reuseId,
            for: indexPath
        ) as? ListenVariantContextRowCell else {
            return UITableViewCell()
        }

        let row = rows[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == rows.count - 1
        cell.configure(row: row, isFirst: isFirst, isLast: isLast)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        stickyHeaderContainerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentCardHeight = isStickyHeaderCollapsed ? stickyHeaderCollapsedHeight : stickyHeaderExpandedHeight
        return stickyHeaderTopInset + currentCardHeight + stickyHeaderBottomInset
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard showWords, !rows.isEmpty else { return nil }
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        showWords && !rows.isEmpty ? 8 : 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView else { return }
        guard showWords else { return }
        guard !isUpdatingStickyHeaderLayout else { return }

        let yOffset = scrollView.contentOffset.y
        let panTranslationY = scrollView.panGestureRecognizer.translation(in: scrollView).y
        let isScrollingUp = panTranslationY < 0
        let isScrollingDown = panTranslationY > 0

        if !isStickyHeaderCollapsed, isScrollingUp, yOffset > 20 {
            setStickyHeaderCollapsed(true, animated: true)
            return
        }

        if isStickyHeaderCollapsed, isScrollingDown, yOffset <= 0 {
            setStickyHeaderCollapsed(false, animated: true)
        }
    }

    private func setStickyHeaderCollapsed(_ collapsed: Bool, animated: Bool) {
        guard collapsed != isStickyHeaderCollapsed else { return }

        isStickyHeaderCollapsed = collapsed
        isUpdatingStickyHeaderLayout = true

        stickyHeaderView.setIconHidden(collapsed, animated: animated, duration: stickyHeaderAnimationDuration)

        let layoutUpdate = {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.tableView.layoutIfNeeded()
            var offset = self.tableView.contentOffset
            let minOffset = -self.tableView.adjustedContentInset.top
            if offset.y < minOffset {
                offset.y = minOffset
                self.tableView.contentOffset = offset
            }
        }

        if animated {
            UIView.animate(
                withDuration: stickyHeaderAnimationDuration,
                delay: 0,
                options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
            ) {
                layoutUpdate()
            } completion: { _ in
                self.isUpdatingStickyHeaderLayout = false
            }
            return
        }

        UIView.performWithoutAnimation {
            layoutUpdate()
        }
        isUpdatingStickyHeaderLayout = false
    }
}

private struct ListenVariantContextRow {
    let source: String
    let target: String
}

private enum ListenVariantContextRows {
    static func rows(for title: String) -> [ListenVariantContextRow] {
        switch title {
        case "La gent":
            return [
                ListenVariantContextRow(source: "jo", target: "I"),
                ListenVariantContextRow(source: "jo i tu", target: "I and you"),
                ListenVariantContextRow(source: "nosaltres dos/\nnosaltres dues", target: "both of us"),
                ListenVariantContextRow(source: "ell", target: "he"),
                ListenVariantContextRow(source: "ell i ella", target: "he and she"),
                ListenVariantContextRow(source: "ells dos / elles dues", target: "they both"),
                ListenVariantContextRow(source: "l'home", target: "the man"),
                ListenVariantContextRow(source: "la dona", target: "the woman"),
                ListenVariantContextRow(source: "el nen", target: "the child"),
                ListenVariantContextRow(source: "jo", target: "I"),
                ListenVariantContextRow(source: "jo i tu", target: "I and you"),
                ListenVariantContextRow(source: "nosaltres dos/\nnosaltres dues", target: "both of us"),
                ListenVariantContextRow(source: "ell", target: "he"),
                ListenVariantContextRow(source: "ell i ella", target: "he and she"),
                ListenVariantContextRow(source: "ells dos / elles dues", target: "they both"),
                ListenVariantContextRow(source: "l'home", target: "the man"),
                ListenVariantContextRow(source: "la dona", target: "the woman"),
                ListenVariantContextRow(source: "el nen", target: "the child")
            ]
        default:
            return []
        }
    }
}

private final class ListenVariantStickyHeaderView: UIView {

    var onPlayTapped: (() -> Void)?
    var onStopTapped: (() -> Void)?
    var onSliderTouchDown: (() -> Void)?
    var onSliderValueChanged: ((Float) -> Void)?
    var onSliderTouchUp: ((Float) -> Void)?

    private let cardView = UIView()
    private let subtitleLabel = ListenVariantInsetLabel()
    private let iconView = UIImageView()
    private let currentTimeLabel = UILabel()
    private let totalTimeLabel = UILabel()
    private let progressSlider = UISlider()
    private let playButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)

    private var iconHeightConstraint: NSLayoutConstraint!
    private var timeTopFromIconConstraint: NSLayoutConstraint!
    private var timeTopFromSubtitleConstraint: NSLayoutConstraint!
    private var currentTimeLeadingConstraint: NSLayoutConstraint!
    private var playButtonWidthConstraint: NSLayoutConstraint!
    private var playButtonHeightConstraint: NSLayoutConstraint!
    private var stopButtonWidthConstraint: NSLayoutConstraint!
    private var stopButtonHeightConstraint: NSLayoutConstraint!
    private var progressHeightConstraint: NSLayoutConstraint!
    private var expandedLayoutConstraints: [NSLayoutConstraint] = []
    private var compactLayoutConstraints: [NSLayoutConstraint] = []
    private var isCompactLayout = false
    private var isIconHidden = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(subtitle: String, subtitleColor: UIColor) {
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = subtitleColor
    }

    func setIconHidden(_ hidden: Bool, animated: Bool, duration: TimeInterval = 0.2) {
        guard hidden != isIconHidden else { return }
        isIconHidden = hidden

        iconHeightConstraint.constant = hidden ? 0 : 100
        timeTopFromIconConstraint.isActive = !hidden
        timeTopFromSubtitleConstraint.isActive = hidden
        applyCompactLayout(hidden)

        let updates = {
            self.iconView.alpha = hidden ? 0 : 1
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: 0.92,
                initialSpringVelocity: 0.25,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: updates
            )
        } else {
            updates()
        }
    }

    private func configureUI() {
        backgroundColor = .clear

        cardView.backgroundColor = .appCard
        cardView.layer.cornerRadius = 16
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 16

        subtitleLabel.font = .sfPro(.regular, size: 12)
        subtitleLabel.textInsets = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 13)
        subtitleLabel.backgroundColor = .appSubtitleBackground
        subtitleLabel.layer.cornerRadius = 12
        subtitleLabel.clipsToBounds = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        iconView.image = UIImage(named: "listen-icon")
        iconView.contentMode = .scaleAspectFit

        currentTimeLabel.text = "00:00"
        currentTimeLabel.font = .sfPro(.semiBold, size: 9)
        currentTimeLabel.textColor = .appPrimaryText

        totalTimeLabel.text = "--:--"
        totalTimeLabel.font = .sfPro(.semiBold, size: 9)
        totalTimeLabel.textColor = .appPrimaryText

        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.value = 0
        progressSlider.minimumTrackTintColor = AppTheme.currentPalette.listenTint
        progressSlider.maximumTrackTintColor = AppTheme.currentPalette.listenSecondaryTint
        progressSlider.thumbTintColor = AppTheme.currentPalette.listenTint
//        progressSlider.setThumbImage(UIImage(named: "slider-thumb"), for: .normal)
        progressSlider.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        progressSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        playButton.setImage(UIImage(named: "play-circle"), for: .normal)
        stopButton.setImage(UIImage(named: "stop-circle"), for: .normal)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(didTapStop), for: .touchUpInside)
    }

    func setControlsEnabled(_ enabled: Bool) {
        playButton.isEnabled = enabled
        stopButton.isEnabled = enabled
        progressSlider.isEnabled = enabled

        let alpha: CGFloat = enabled ? 1 : 0.45
        playButton.alpha = alpha
        stopButton.alpha = alpha
        progressSlider.alpha = alpha
    }

    func updatePlaybackState(isPlaying: Bool) {
        if isPlaying {
            playButton.setImage(UIImage(named: "pause-circle"), for: .normal)
            return
        }
        playButton.setImage(UIImage(named: "play-circle"), for: .normal)
        playButton.tintColor = nil
    }

    func updateProgress(current: TimeInterval, total: TimeInterval, updateSlider: Bool = true) {
        currentTimeLabel.text = Self.formatTime(current)

        if total > 0 {
            totalTimeLabel.text = Self.formatTime(total)
            if updateSlider {
                progressSlider.value = Float(min(max(current / total, 0), 1))
            }
            progressSlider.isEnabled = true
        } else {
            totalTimeLabel.text = "--:--"
            if updateSlider {
                progressSlider.value = 0
            }
            progressSlider.isEnabled = false
        }
    }

    private static func formatTime(_ value: TimeInterval) -> String {
        let safe = max(0, Int(value.rounded()))
        let hours = safe / 3600
        let minutes = (safe % 3600) / 60
        let seconds = safe % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc
    private func didTapPlay() {
        onPlayTapped?()
    }

    @objc
    private func didTapStop() {
        onStopTapped?()
    }

    @objc
    private func sliderTouchDown() {
        onSliderTouchDown?()
    }

    @objc
    private func sliderValueChanged() {
        onSliderValueChanged?(progressSlider.value)
    }

    @objc
    private func sliderTouchUp() {
        onSliderTouchUp?(progressSlider.value)
    }

    private func setupLayout() {
        [cardView, subtitleLabel, iconView, currentTimeLabel, totalTimeLabel, progressSlider, playButton, stopButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        addSubview(cardView)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(iconView)
        cardView.addSubview(currentTimeLabel)
        cardView.addSubview(totalTimeLabel)
        cardView.addSubview(progressSlider)
        cardView.addSubview(playButton)
        cardView.addSubview(stopButton)

        iconHeightConstraint = iconView.heightAnchor.constraint(equalToConstant: 100)
        timeTopFromIconConstraint = currentTimeLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 23)
        timeTopFromSubtitleConstraint = currentTimeLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18)
        currentTimeLeadingConstraint = currentTimeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 35)
        playButtonWidthConstraint = playButton.widthAnchor.constraint(equalToConstant: 42)
        playButtonHeightConstraint = playButton.heightAnchor.constraint(equalToConstant: 42)
        stopButtonWidthConstraint = stopButton.widthAnchor.constraint(equalToConstant: 42)
        stopButtonHeightConstraint = stopButton.heightAnchor.constraint(equalToConstant: 42)
        progressHeightConstraint = progressSlider.heightAnchor.constraint(equalToConstant: 17)

        expandedLayoutConstraints = [
            subtitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            subtitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            progressSlider.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 6),
            progressSlider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 35),
            progressSlider.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -35),

            playButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 23),
            playButton.trailingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: -2),

            stopButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            stopButton.leadingAnchor.constraint(equalTo: cardView.centerXAnchor, constant: 2)
        ]

        compactLayoutConstraints = [
            currentTimeLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            progressSlider.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 12),
            progressSlider.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -10),

            playButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: stopButton.leadingAnchor, constant: -6),

            stopButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stopButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14)
        ]

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            subtitleLabel.heightAnchor.constraint(equalToConstant: 24),

            iconView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 23),
            iconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconHeightConstraint,

            timeTopFromIconConstraint,
            currentTimeLeadingConstraint,
            currentTimeLabel.heightAnchor.constraint(equalToConstant: 11),

            totalTimeLabel.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
            totalTimeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -35),
            totalTimeLabel.heightAnchor.constraint(equalToConstant: 11),

            progressHeightConstraint,
            progressSlider.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),

            playButtonWidthConstraint,
            playButtonHeightConstraint,
            stopButtonWidthConstraint,
            stopButtonHeightConstraint
        ])

        NSLayoutConstraint.activate(expandedLayoutConstraints)
    }

    private func applyCompactLayout(_ compact: Bool) {
        guard compact != isCompactLayout else { return }
        isCompactLayout = compact

        if compact {
            NSLayoutConstraint.deactivate(expandedLayoutConstraints)
            NSLayoutConstraint.activate(compactLayoutConstraints)
            timeTopFromIconConstraint.isActive = false
            timeTopFromSubtitleConstraint.isActive = false
            currentTimeLeadingConstraint.constant = 14
            playButtonWidthConstraint.constant = 32
            playButtonHeightConstraint.constant = 32
            stopButtonWidthConstraint.constant = 32
            stopButtonHeightConstraint.constant = 32
            progressHeightConstraint.constant = 14
            cardView.layer.cornerRadius = 48
            subtitleLabel.isHidden = true
            currentTimeLabel.isHidden = false
            totalTimeLabel.isHidden = true
            return
        }

        NSLayoutConstraint.deactivate(compactLayoutConstraints)
        NSLayoutConstraint.activate(expandedLayoutConstraints)
        currentTimeLeadingConstraint.constant = 35
        timeTopFromIconConstraint.isActive = !isIconHidden
        timeTopFromSubtitleConstraint.isActive = isIconHidden
        playButtonWidthConstraint.constant = 42
        playButtonHeightConstraint.constant = 42
        stopButtonWidthConstraint.constant = 42
        stopButtonHeightConstraint.constant = 42
        progressHeightConstraint.constant = 17
        cardView.layer.cornerRadius = 16
        subtitleLabel.isHidden = false
        currentTimeLabel.isHidden = false
        totalTimeLabel.isHidden = false
    }
}

private final class ListenVariantContextRowCell: UITableViewCell {
    static let reuseId = "ListenVariantContextRowCell"

    private let cardContainerView = UIView()
    private let sourceLabel = UILabel()
    private let arrowLabel = UILabel()
    private let targetLabel = UILabel()
    private let contentStackView = UIStackView()
    private let separatorView = ListenVariantDashedSeparatorView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardContainerView.layer.mask = nil
        cardContainerView.layer.cornerRadius = 0
        cardContainerView.layer.maskedCorners = []
        cardContainerView.layer.masksToBounds = false
    }

    func configure(row: ListenVariantContextRow, isFirst: Bool, isLast: Bool) {
        sourceLabel.text = row.source
        targetLabel.text = row.target
        separatorView.isHidden = isLast

        let radius: CGFloat = 16
        let corners: CACornerMask = {
            if isFirst && isLast {
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            if isFirst {
                return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            if isLast {
                return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            return []
        }()

        if corners.isEmpty {
            cardContainerView.layer.mask = nil
            cardContainerView.layer.cornerRadius = 0
            cardContainerView.layer.maskedCorners = []
            cardContainerView.layer.masksToBounds = false
        } else {
            cardContainerView.layer.cornerRadius = radius
            cardContainerView.layer.maskedCorners = corners
            cardContainerView.layer.masksToBounds = true
        }
    }

    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none

        cardContainerView.backgroundColor = .appCard

        sourceLabel.font = .sfPro(.regular, size: 14)
        sourceLabel.textColor = .appPrimaryText
        sourceLabel.numberOfLines = 0

        arrowLabel.text = "→"
        arrowLabel.font = .sfPro(.regular, size: 15)
        arrowLabel.textColor = UIColor(hex: "#999999")
        arrowLabel.textAlignment = .center

        targetLabel.font = .sfPro(.regular, size: 14)
        targetLabel.textColor = UIColor(hex: "#407093")
        targetLabel.textAlignment = .left
        targetLabel.numberOfLines = 0

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 25
    }

    private func setupLayout() {
        [cardContainerView, sourceLabel, arrowLabel, targetLabel, contentStackView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(contentStackView)
        cardContainerView.addSubview(separatorView)

        contentStackView.addArrangedSubview(sourceLabel)
        contentStackView.addArrangedSubview(arrowLabel)
        contentStackView.addArrangedSubview(targetLabel)

        sourceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        targetLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        arrowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 15),
            contentStackView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -15),
            contentStackView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -12),

            arrowLabel.widthAnchor.constraint(equalToConstant: 14),
            sourceLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 0.43),

            separatorView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 15),
            separatorView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -15),
            separatorView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

private final class ListenVariantDashedSeparatorView: UIView {

    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(shapeLayer)
        shapeLayer.strokeColor = UIColor.separatorColor.cgColor
        shapeLayer.lineDashPattern = [2, 3]
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        shapeLayer.path = path.cgPath
    }
}

private final class ListenVariantInsetLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
