//
//  FlashCardsViewController.swift
//  lang-apps
//
//  Created by Codex on 18.02.2026.
//

import UIKit
import AVFoundation

final class FlashCardsViewController: UIViewController, UIGestureRecognizerDelegate {

    static let CardSizeDifference: CGFloat = 10.0
    static let TopCardHorizontalEdge: CGFloat = 20.0
    static let TossDifference: CGFloat = 30.0

    private let section: FCSection

    private var cardIndex: Int = 0
    private var cards: [FCCard] = []
    private var cardViews: [CardView] = []

    private var restartButton: UIButton?
    private var playButton: UIButton?

    private var isOnAutoMode: Bool = false
    private var autoModeStartDate: TimeInterval = 0
    private var autoModeWaitSeconds: Int = 3
    private var player: AVPlayer?
    private var itemDidFinishObserver: NSObjectProtocol?

    private var draggedCardView: CardView?
    private var dragFirstPosition: CGPoint?
    private var isInverted: Bool = UserDefaults.standard.bool(forKey: "flashcards.isInverted")
    private var hasShownEntryInterstitial = false

    private var stateKey: String {
        "flashcards.lastIndex.\(section.sectionId ?? 0)"
    }

    init(section: FCSection) {
        self.section = section
        super.init(nibName: nil, bundle: nil)

        for card in section.cards ?? [] {
            if let copied = card.copy(with: nil) as? FCCard {
                cards.append(copied)
            }
        }

        let savedIndex = UserDefaults.standard.integer(forKey: stateKey)
        if section.type == .Favorites {
            cardIndex = 0
        } else {
            cardIndex = min(max(0, savedIndex), cards.count)
        }

        UIApplication.shared.isIdleTimerDisabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        cleanupAudioPlayback()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        createCards()
        if let restartButton {
            view.sendSubviewToBack(restartButton)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let viewHeight = view.bounds.height

        var topCardWidthHeight = (view.bounds.width - (2 * Self.TopCardHorizontalEdge))
        if topCardWidthHeight > viewHeight {
            topCardWidthHeight = viewHeight / 2
        }

        for (i, cardView) in cardViews.enumerated() {
            if cardView == draggedCardView { continue }

            let cardWidthHeight = topCardWidthHeight - (Self.CardSizeDifference * CGFloat(i))
            let cardPosY = ((viewHeight - topCardWidthHeight) / 2) + 30 - (Self.CardSizeDifference * CGFloat(i))
            cardView.frame = CGRect(
                x: (view.bounds.width - cardWidthHeight) / 2,
                y: cardPosY,
                width: cardWidthHeight,
                height: cardWidthHeight
            )
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showEntryInterstitialIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveState()
        endAutoMode()
        stopAudioPlayback()
    }

    private func showEntryInterstitialIfNeeded() {
        guard !hasShownEntryInterstitial else { return }
        hasShownEntryInterstitial = true
//        AdMobManager.shared.showInterstitialIfAvailable(from: self, onDismiss: {})
    }

    @objc
    private func didTapPlayButton() {
        isOnAutoMode.toggle()

        if isOnAutoMode {
            let alertController = UIAlertController(title: "Auto Player Speed", message: nil, preferredStyle: .actionSheet)

            if UIDevice.current.userInterfaceIdiom == .pad {
                alertController.popoverPresentationController?.sourceView = playButton
                alertController.popoverPresentationController?.sourceRect = playButton?.bounds ?? .zero
            }

            for speed in 1...5 {
                alertController.addAction(UIAlertAction(title: "\(speed) Second", style: .default) { _ in
                    self.autoModeWaitSeconds = speed
                    self.setPlayButtonAutoMode(isAutoMode: true)
                    self.startAutoMode()
                })
            }

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.isOnAutoMode = false
                self.setPlayButtonAutoMode(isAutoMode: false)
            })

            present(alertController, animated: true)
        } else {
            setPlayButtonAutoMode(isAutoMode: false)
        }
    }

    @objc
    private func didDragView(gesture: UIPanGestureRecognizer) {
        if isOnAutoMode { return }

        guard let cardView = gesture.view as? CardView else { return }

        if gesture.state == .began {
            draggedCardView = cardView
            dragFirstPosition = cardView.frame.origin
        }

        let translated = gesture.translation(in: view)
        let translatedPoint = CGPoint(
            x: (dragFirstPosition?.x ?? 0) + translated.x,
            y: (dragFirstPosition?.y ?? 0) + translated.y
        )

        if gesture.state == .cancelled || gesture.state == .failed || gesture.state == .ended {
            draggedCardView = nil
            dragFirstPosition = nil
            checkAndTossCardView(cardView: cardView, forceToss: false)
        } else {
            cardView.frame = CGRect(
                x: translatedPoint.x,
                y: translatedPoint.y,
                width: cardView.bounds.width,
                height: cardView.bounds.height
            )
        }
    }

    @objc
    private func didTapCard(gesture: UITapGestureRecognizer) {
        if isOnAutoMode { return }
        guard let cardView = gesture.view as? CardView else { return }
        flipCard(cardView: cardView)
    }

    @objc
    private func didTapInvert() {
        isInverted.toggle()
        UserDefaults.standard.set(isInverted, forKey: "flashcards.isInverted")

        for cardView in cardViews {
            cardView.fillCell(card: cardView.card, isInverted: isInverted)
        }
    }

    @objc
    private func didTapRestart() {
        cardIndex = 0
        cards = []
        for card in section.cards ?? [] {
            if let copied = card.copy(with: nil) as? FCCard {
                cards.append(copied)
            }
        }
        createCards()
        saveState()
        if let restartButton {
            view.sendSubviewToBack(restartButton)
        }
    }

    @objc
    private func didTapMenu() {
        endAutoMode()

        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }

        alertController.addAction(UIAlertAction(title: "Change Sides", style: .default) { _ in
            self.didTapInvert()
        })
        alertController.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
            self.didTapRestart()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        navigationItem.title = section.getSectionNameWithRomanNumber()
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu_icon_selected") ?? UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(didTapMenu)
        )

        let restart = UIButton(type: .system)
        restart.setTitle("Congratulations! Tap to restart", for: .normal)
        restart.setTitleColor(.appPrimaryText, for: .normal)
        restart.addTarget(self, action: #selector(didTapRestart), for: .touchUpInside)
        restart.titleLabel?.font = .sfPro(.regular, size: 16)
        restart.isHidden = true
        restart.translatesAutoresizingMaskIntoConstraints = false
        restartButton = restart
        view.addSubview(restart)

        let play = UIButton(type: .system)
        play.setImage(UIImage(named: "auto-play")?.withTintColor(UIColor.appPrimaryText), for: .normal)
        play.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        play.setTitle("Start Auto Mode", for: .normal)
        play.titleLabel?.font = .sfPro(.medium, size: 16)
        play.setTitleColor(UIColor.appPrimaryText, for: .normal)
        play.imageView?.contentMode = .scaleAspectFit
        play.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        play.translatesAutoresizingMaskIntoConstraints = false
        playButton = play
        view.addSubview(play)

        let restartPreferredWidth = restart.widthAnchor.constraint(
            equalTo: view.widthAnchor,
            constant: -(2 * Self.TopCardHorizontalEdge)
        )
        restartPreferredWidth.priority = .defaultHigh

        let restartSquare = restart.heightAnchor.constraint(equalTo: restart.widthAnchor)
        restartSquare.priority = .defaultHigh

        NSLayoutConstraint.activate([
            play.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 29),
            play.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            play.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            play.heightAnchor.constraint(equalToConstant: 30),

            restart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restart.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            restartPreferredWidth,
            restartSquare,
            restart.widthAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.5)
        ])
    }

    private func createCards() {
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        cardViews.removeAll()

        for i in 0..<5 {
            let index = cardIndex + i
            if index >= cards.count { continue }

            let card = cards[index]
            let cardView = CardView(frame: .zero)
            cardView.fillCell(card: card, isInverted: isInverted)
            bindCardActions(cardView)

            if i == 0 {
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragView(gesture:)))
                panGesture.delegate = self
                cardView.isUserInteractionEnabled = true
                cardView.addGestureRecognizer(panGesture)

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard(gesture:)))
                tapGesture.delegate = self
                cardView.addGestureRecognizer(tapGesture)
            }

            view.addSubview(cardView)
            cardViews.append(cardView)
            view.sendSubviewToBack(cardView)
        }

        restartButton?.isHidden = !cardViews.isEmpty
        viewDidLayoutSubviews()
    }

    private func checkAndTossCardView(cardView: CardView, forceToss: Bool) {
        if !forceToss {
            let minX = Self.TopCardHorizontalEdge - Self.TossDifference
            let maxX = Self.TopCardHorizontalEdge + Self.TossDifference
            if cardView.frame.origin.x >= minX && cardView.frame.origin.x <= maxX {
                UIView.animate(withDuration: 0.2) {
                    self.viewDidLayoutSubviews()
                }
                return
            }
        }

        let finalFrame: CGRect
        if cardView.frame.origin.x <= (Self.TopCardHorizontalEdge - Self.TossDifference) {
            finalFrame = CGRect(
                x: -view.bounds.width,
                y: cardView.frame.origin.y,
                width: cardView.frame.width,
                height: cardView.frame.height
            )
        } else {
            finalFrame = CGRect(
                x: 2 * view.bounds.width,
                y: cardView.frame.origin.y,
                width: cardView.frame.width,
                height: cardView.frame.height
            )
        }

        UIView.animate(withDuration: 0.3, animations: {
            cardView.frame = finalFrame
        }) { _ in
            self.handleRemovedItem()
        }
    }

    private func handleRemovedItem() {
        guard let topCard = cardViews.first else {
            restartButton?.isHidden = false
            return
        }

        topCard.removeFromSuperview()
        cardViews.remove(at: 0)
        cardIndex += 1
        saveState()

        let newCardIndex = cardIndex + 4
        if newCardIndex < cards.count {
            let newCard = cards[newCardIndex]
            let newCardView = CardView(frame: .zero)
            newCardView.fillCell(card: newCard, isInverted: isInverted)
            bindCardActions(newCardView)
            cardViews.append(newCardView)
            view.addSubview(newCardView)
            view.sendSubviewToBack(newCardView)
        }

        if cardViews.count == 0 {
            restartButton?.isHidden = false
        } else {
            restartButton?.isHidden = true

            let firstCard = cardViews.first
            firstCard?.gestureRecognizers?.forEach { firstCard?.removeGestureRecognizer($0) }

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragView(gesture:)))
            panGesture.delegate = self
            firstCard?.isUserInteractionEnabled = true
            firstCard?.addGestureRecognizer(panGesture)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCard(gesture:)))
            tapGesture.delegate = self
            firstCard?.addGestureRecognizer(tapGesture)
        }

        viewDidLayoutSubviews()
    }

    private func saveState() {
        if section.type == .Favorites { return }
        UserDefaults.standard.set(cardIndex, forKey: stateKey)
    }

    private func flipCard(cardView: CardView?) {
        guard let cardView, let card = cardView.card else { return }
        card.showAnswer = !card.showAnswer
        cardView.fillCell(card: card, isInverted: isInverted)
        UIView.transition(with: cardView, duration: 0.5, options: .transitionFlipFromRight, animations: nil)
    }

    private func endAutoMode() {
        isOnAutoMode = false
        setPlayButtonAutoMode(isAutoMode: false)
    }

    private func startAutoMode() {
        autoModeStartDate = Date().timeIntervalSince1970
        autoModeRepeat(timeInterval: autoModeStartDate)
    }

    private func autoModeRepeat(timeInterval: TimeInterval) {
        if !isOnAutoMode { return }
        if timeInterval != autoModeStartDate { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000 * autoModeWaitSeconds)) {
            guard let topCardView = self.cardViews.first else {
                self.endAutoMode()
                return
            }
            if !self.isOnAutoMode { return }

            self.flipCard(cardView: topCardView)

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000 * self.autoModeWaitSeconds)) {
                if !self.isOnAutoMode { return }
                self.checkAndTossCardView(cardView: topCardView, forceToss: true)
                self.autoModeRepeat(timeInterval: timeInterval)
            }
        }
    }

    private func setPlayButtonAutoMode(isAutoMode: Bool) {
        if isAutoMode {
            playButton?.setImage(UIImage(named: "auto-stop")?.withTintColor(UIColor.appPrimaryText), for: .normal)
            playButton?.setTitle("Stop Auto Mode", for: .normal)
        } else {
            playButton?.setImage(UIImage(named: "auto-play")?.withTintColor(UIColor.appPrimaryText), for: .normal)
            playButton?.setTitle("Start Auto Mode", for: .normal)
        }
    }

    private func bindCardActions(_ cardView: CardView) {
        cardView.onFavoriteTapped = { [weak self] _ in
            self?.refreshVisibleFavoriteStates()
        }
        cardView.onSpeakerTapped = { [weak self] card, isBackVisible in
            self?.playAudio(for: card, isBackVisible: isBackVisible)
        }
    }

    private func playAudio(for card: FCCard, isBackVisible: Bool) {
        let preferredURL = isBackVisible ? card.sourceAudioURL : card.targetAudioURL
        let fallbackURL = isBackVisible ? card.targetAudioURL : card.sourceAudioURL
        guard let audioURL = preferredURL ?? fallbackURL else { return }
        playAudio(url: audioURL)
    }

    private func playAudio(url: URL) {
        ensurePlaybackAudioSession()
        removeItemFinishObserver()

        let playerItem = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }

        itemDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.removeItemFinishObserver()
        }

        player?.play()
    }

    private func ensurePlaybackAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
#if DEBUG
            print("Failed to configure audio session for playback: \(error)")
#endif
        }
    }

    private func stopAudioPlayback() {
        player?.pause()
        removeItemFinishObserver()
    }

    private func cleanupAudioPlayback() {
        stopAudioPlayback()
        player = nil
    }

    private func removeItemFinishObserver() {
        if let observer = itemDidFinishObserver {
            NotificationCenter.default.removeObserver(observer)
            itemDidFinishObserver = nil
        }
    }

    private func refreshVisibleFavoriteStates() {
        for cardView in cardViews {
            cardView.refreshFavoriteButton()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UIControl)
    }
}

private final class CardView: UIView {

    static let LabelPadding: CGFloat = 5.0

    private static let borderColors: [UIColor] = [
        UIColor(hex: "#3A94E7"),
        UIColor(hex: "#33B8C7"),
        UIColor(hex: "#FF9F2F"),
        UIColor(hex: "#B575FF"),
        UIColor(hex: "#FF6A8C")
    ]

    private var shadowView: UIView?
    private var coverView: UIView?
    private var label: UILabel?
    private var speakerButton: UIButton?
    private var favoriteButton: UIButton?

    var onFavoriteTapped: ((Bool) -> Void)?
    var onSpeakerTapped: ((FCCard, Bool) -> Void)?

    var card: FCCard?
    var isInverted: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.masksToBounds = false

        let shadow = UIView(frame: .zero)
        shadow.backgroundColor = .clear
        shadow.layer.masksToBounds = false
        shadow.layer.shadowRadius = 5
        shadow.layer.shadowOpacity = 0.10
        shadow.layer.shadowColor = UIColor(hex: "#3A94E7").cgColor
        shadow.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(shadow)
        shadowView = shadow

        let cover = UIView(frame: .zero)
        cover.backgroundColor = .appCard
        cover.layer.masksToBounds = true
        cover.layer.cornerRadius = 32.0
        cover.layer.borderWidth = 3.0
        shadow.addSubview(cover)
        coverView = cover

        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.sfPro(.medium, size: 32)
        textLabel.textColor = .appPrimaryText
        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.7
        textLabel.numberOfLines = 4
        cover.addSubview(textLabel)
        label = textLabel

        let favorite = UIButton(type: .system)
        favorite.tintColor = .clear
        favorite.imageView?.contentMode = .scaleAspectFit
        favorite.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        cover.addSubview(favorite)
        favoriteButton = favorite

        let speaker = UIButton(type: .system)
        speaker.tintColor = .appPrimaryText
        speaker.imageView?.contentMode = .scaleAspectFit
        let speakerImage = UIImage(named: "speaker-icon")?.withRenderingMode(.alwaysOriginal) ?? UIImage(systemName: "speaker.wave.2")
        speaker.setImage(speakerImage, for: .normal)
        speaker.addTarget(self, action: #selector(didTapSpeaker), for: .touchUpInside)
        cover.addSubview(speaker)
        speakerButton = speaker
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowView?.frame = bounds
        coverView?.frame = bounds

        let maxLabelHeight: CGFloat = bounds.height * 0.6
        label?.frame = CGRect(
            x: Self.LabelPadding + 16,
            y: (bounds.height - 40 - maxLabelHeight) / 2,
            width: bounds.width - ((Self.LabelPadding + 16) * 2),
            height: maxLabelHeight
        )

        favoriteButton?.frame = CGRect(x: 20, y: bounds.height - 40 - 20, width: 40, height: 40)
        speakerButton?.frame = CGRect(x: bounds.width - 40 - 20, y: bounds.height - 40 - 20, width: 40, height: 40)
    }

    func fillCell(card: FCCard?, isInverted: Bool) {
        guard let card else { return }
        self.card = card
        self.isInverted = isInverted

        let isBackVisible = isInverted ? !card.showAnswer : card.showAnswer
        label?.text = isBackVisible ? card.backText : card.frontText
        coverView?.layer.borderColor = Self.borderColors[card.index % Self.borderColors.count].cgColor
        refreshFavoriteButton()
    }

    func refreshFavoriteButton() {
        guard let card else { return }
        let isFavorite = FlashcardFavoritesStore.shared.isFavorite(card: card)
        let imageName = isFavorite ? "flashcard-heart-fill" : "flashcard-heart-empty"
        let fallbackImage = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        let image = UIImage(named: imageName) ?? fallbackImage
        favoriteButton?.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    @objc
    private func didTapFavorite() {
        guard let card else { return }
        let isFavorite = FlashcardFavoritesStore.shared.toggle(card: card)
        refreshFavoriteButton()
        onFavoriteTapped?(isFavorite)
    }

    @objc
    private func didTapSpeaker() {
        guard let card else { return }
        let isBackVisible = isInverted ? !card.showAnswer : card.showAnswer
        onSpeakerTapped?(card, isBackVisible)
    }
}
