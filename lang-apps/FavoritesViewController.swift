//
//  FavoritesViewController.swift
//  lang-apps
//
//  Created by Codex on 18.02.2026.
//

import UIKit
import AVFoundation

final class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    private struct AudioPair {
        let sourceURL: URL?
        let targetURL: URL?
    }

    private var allWords: [FlashcardFavoriteItem] = []
    private var words: [FlashcardFavoriteItem] = []
    private var selectedIndex: Int?
    private var audioByFavoriteID: [String: AudioPair] = [:]

    private var phrasebookTask: URLSessionDataTask?
    private let remotePhrasebookEndpoint = TargetManager.current.remotePhrasebookEndpoint
    private var remotePhrasebook: Phrasebook?

    private var player: AVPlayer?
    private var itemDidFinishObserver: NSObjectProtocol?

    private let topContainerView = UIView()
    private let previousButton = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    private let searchHeaderView = UIView()
    private let searchContainerView = UIView()
    private let searchIconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    private let searchTextField = UITextField()
    private lazy var keyboardDismissTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTapAction))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .appBackground
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        return view
    }()

    private let emptyStateStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "favorite-empty"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No words have been added\nto favorites yet"
        label.textColor = UIColor(hex: "#5E7399")
        label.font = .sfPro(.medium, size: 20)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        let description = "You can add your desired words to\nyour favorites by clicking the ♡ icon."
        let attributed = NSMutableAttributedString(
            string: description,
            attributes: [
                .foregroundColor: UIColor.appPrimaryText.withAlphaComponent(0.45),
                .font: UIFont.sfPro(.regular, size: 16) as Any
            ]
        )
        if let range = description.range(of: "♡") {
            let nsRange = NSRange(range, in: description)
            attributed.addAttribute(.foregroundColor, value: UIColor(hex: "#F59A23"), range: nsRange)
        }
        label.attributedText = attributed
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
        configureTable()
        loadRemotePhrasebookIfNeeded()
        reloadWords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRemotePhrasebookIfNeeded()
        reloadWords()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSearchHeaderLayout()
        applyBottomInset()
    }

    deinit {
        phrasebookTask?.cancel()
        cleanupAudioPlayback()
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        view.addGestureRecognizer(keyboardDismissTapGesture)

        topContainerView.backgroundColor = .appCard
        topContainerView.layer.cornerRadius = 10
        topContainerView.layer.shadowColor = UIColor.black.cgColor
        topContainerView.layer.shadowOpacity = 0.2
        topContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topContainerView.layer.shadowRadius = 1

        configureTopAssetButton(previousButton, imageName: "previous-icon")
        previousButton.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)

        configureTopAssetButton(playButton, imageName: "play-circle-large")
        playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)

        configureTopAssetButton(nextButton, imageName: "next-icon")
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)

        topContainerView.addSubview(previousButton)
        topContainerView.addSubview(playButton)
        topContainerView.addSubview(nextButton)

        searchContainerView.backgroundColor = .appCard
        searchContainerView.layer.cornerRadius = 10
        searchContainerView.layer.shadowColor = UIColor.black.cgColor
        searchContainerView.layer.shadowOpacity = 0.05
        searchContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        searchContainerView.layer.shadowRadius = 1

        searchIconView.tintColor = .appPrimaryText.withAlphaComponent(0.45)
        searchIconView.contentMode = .scaleAspectFit

        searchTextField.font = .sfPro(.regular, size: 15)
        searchTextField.textColor = .appPrimaryText
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .done
        searchTextField.autocorrectionType = .no
        searchTextField.autocapitalizationType = .none
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.appPrimaryText.withAlphaComponent(0.4)]
        )
        searchTextField.addTarget(self, action: #selector(searchTextDidChange), for: .editingChanged)
        searchTextField.delegate = self

        searchContainerView.addSubview(searchIconView)
        searchContainerView.addSubview(searchTextField)
    }

    private func setupLayout() {
        [topContainerView, previousButton, playButton, nextButton, searchContainerView, searchIconView, searchTextField, tableView, emptyStateStackView, emptyImageView, emptyTitleLabel, emptyDescriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(topContainerView)
        view.addSubview(tableView)
        view.addSubview(emptyStateStackView)
        emptyStateStackView.addArrangedSubview(emptyImageView)
        emptyStateStackView.addArrangedSubview(emptyTitleLabel)
        emptyStateStackView.addArrangedSubview(emptyDescriptionLabel)
        emptyStateStackView.setCustomSpacing(20, after: emptyImageView)
        emptyStateStackView.setCustomSpacing(18, after: emptyTitleLabel)

        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            topContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            topContainerView.heightAnchor.constraint(equalToConstant: 46),

            previousButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 18),
            previousButton.widthAnchor.constraint(equalToConstant: 28),
            previousButton.heightAnchor.constraint(equalToConstant: 28),

            playButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 38),
            playButton.heightAnchor.constraint(equalToConstant: 38),

            nextButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -18),
            nextButton.widthAnchor.constraint(equalToConstant: 28),
            nextButton.heightAnchor.constraint(equalToConstant: 28),

            tableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -36),
            emptyStateStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 28),
            emptyStateStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -28),

            emptyImageView.widthAnchor.constraint(equalToConstant: 170),
            emptyImageView.heightAnchor.constraint(equalToConstant: 170)
        ])

        configureSearchHeaderIfNeeded()
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 170
        tableView.register(ListenPlayExpandedCell.self, forCellReuseIdentifier: ListenPlayExpandedCell.reuseId)
        configureSearchHeaderIfNeeded()
    }

    private func configureSearchHeaderIfNeeded() {
        guard searchContainerView.superview == nil else { return }

        searchHeaderView.backgroundColor = .clear
        searchHeaderView.addSubview(searchContainerView)

        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: searchHeaderView.topAnchor),
            searchContainerView.leadingAnchor.constraint(equalTo: searchHeaderView.leadingAnchor),
            searchContainerView.trailingAnchor.constraint(equalTo: searchHeaderView.trailingAnchor),
            searchContainerView.heightAnchor.constraint(equalToConstant: 44),
            searchContainerView.bottomAnchor.constraint(equalTo: searchHeaderView.bottomAnchor, constant: -10),

            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 16),
            searchIconView.heightAnchor.constraint(equalToConstant: 16),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])

        tableView.tableHeaderView = searchHeaderView
    }

    private func updateSearchHeaderLayout() {
        guard tableView.tableHeaderView === searchHeaderView else { return }
        let width = tableView.bounds.width
        guard width > 0 else { return }

        let fittingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let height = searchHeaderView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if searchHeaderView.frame.size.width != width || searchHeaderView.frame.size.height != height {
            searchHeaderView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            tableView.tableHeaderView = searchHeaderView
        }
    }

    private func configureTopAssetButton(_ button: UIButton, imageName: String) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: imageName)
        config.baseForegroundColor = .appPrimaryText
        config.contentInsets = .zero
        button.configuration = config
    }

    private func applyBottomInset() {
        let bottomInset: CGFloat = 56
        if tableView.contentInset.bottom != bottomInset {
            tableView.contentInset.bottom = bottomInset
            tableView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }

    private func reloadWords() {
        allWords = FlashcardFavoritesStore.shared.favoriteItems()
        rebuildAudioMap()
        applySearchFilter()
    }

    private func applySearchFilter() {
        let selectedID = selectedIndex.flatMap { words.indices.contains($0) ? words[$0].id : nil }
        let query = normalizedSearchText(searchTextField.text)

        if query.isEmpty {
            words = allWords
        } else {
            words = allWords.filter { item in
                matchesSearch(item.frontText, query: query) ||
                matchesSearch(item.backText, query: query)
            }
        }

        selectedIndex = selectedID.flatMap { id in
            words.firstIndex { $0.id == id }
        }

        let hasAnyFavorites = !allWords.isEmpty
        let hasRows = !words.isEmpty

        emptyStateStackView.isHidden = hasAnyFavorites
        topContainerView.isHidden = !hasAnyFavorites
        tableView.isHidden = !hasAnyFavorites
        previousButton.isEnabled = hasRows
        playButton.isEnabled = hasRows
        nextButton.isEnabled = hasRows
        tableView.reloadData()
    }

    private func removeFavorite(id: String) {
        _ = FlashcardFavoritesStore.shared.remove(id: id)
        reloadWords()
    }

    private func loadRemotePhrasebookIfNeeded() {
        guard remotePhrasebook == nil,
              let endpoint = remotePhrasebookEndpoint,
              let url = URL(string: endpoint) else { return }

        phrasebookTask?.cancel()
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        phrasebookTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  let data,
                  let phrasebook = try? JSONDecoder().decode(Phrasebook.self, from: data) else {
                return
            }

            DispatchQueue.main.async {
                self.remotePhrasebook = phrasebook
                self.rebuildAudioMap()
                self.tableView.reloadData()
            }
        }
        phrasebookTask?.resume()
    }

    private func rebuildAudioMap() {
        guard let remotePhrasebook else {
            audioByFavoriteID = [:]
            return
        }

        var result: [String: AudioPair] = [:]
        for item in allWords {
            result[item.id] = audioPair(for: item, in: remotePhrasebook)
        }
        audioByFavoriteID = result
    }

    private func audioPair(for item: FlashcardFavoriteItem, in phrasebook: Phrasebook) -> AudioPair {
        guard let sectionID = item.sectionId,
              let lesson = lesson(for: sectionID, in: phrasebook) else {
            return AudioPair(sourceURL: nil, targetURL: nil)
        }

        let phrase = matchedPhrase(for: item, in: lesson)
        guard let phrase else { return AudioPair(sourceURL: nil, targetURL: nil) }
        let sourceURL = phrase.sourceAudio
        let targetURL = phrase.targetAudio
        return AudioPair(sourceURL: sourceURL, targetURL: targetURL)
    }

    private func lesson(for sectionID: Int, in phrasebook: Phrasebook) -> Lesson? {
        if let exact = phrasebook.lessons.first(where: { $0.id == sectionID }) {
            return exact
        }
        if let minusOne = phrasebook.lessons.first(where: { $0.id == sectionID - 1 }) {
            return minusOne
        }
        if let plusOne = phrasebook.lessons.first(where: { $0.id == sectionID + 1 }) {
            return plusOne
        }

        let zeroBasedIndex = sectionID - 1
        if phrasebook.lessons.indices.contains(zeroBasedIndex) {
            return phrasebook.lessons[zeroBasedIndex]
        }

        return nil
    }

    private func matchedPhrase(
        for item: FlashcardFavoriteItem,
        in lesson: Lesson
    ) -> Phrase? {
        let expectedSource = normalizedText(item.backText)
        let expectedTarget = normalizedText(item.frontText.components(separatedBy: "\n").first ?? item.frontText)

        let phraseIndex = item.cardId ?? item.index
        if lesson.phrases.indices.contains(phraseIndex) {
            let phrase = lesson.phrases[phraseIndex]
            if phraseMatches(phrase, expectedSource: expectedSource, expectedTarget: expectedTarget) {
                return phrase
            }
        }

        return lesson.phrases.first { phrase in
            phraseMatches(phrase, expectedSource: expectedSource, expectedTarget: expectedTarget)
        }
    }

    private func phraseMatches(
        _ phrase: Phrase,
        expectedSource: String,
        expectedTarget: String
    ) -> Bool {
        let phraseSource = normalizedText(phrase.sourceText)
        let phraseTarget = normalizedText(phrase.targetText)

        let sourceMatches = !expectedSource.isEmpty && phraseSource == expectedSource
        let targetMatches = !expectedTarget.isEmpty && phraseTarget == expectedTarget
        return sourceMatches || targetMatches
    }

    private func normalizedText(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }

    private func makeRow(from item: FlashcardFavoriteItem) -> ListenPlayRow {
        let source = item.backText.trimmingCharacters(in: .whitespacesAndNewlines)
        let target = item.frontText.trimmingCharacters(in: .whitespacesAndNewlines)

        let parts = target.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        let primary = parts.first.map(String.init)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let secondary = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines) : ""

        let card = FCCard(
            cardId: item.cardId,
            sectionId: item.sectionId,
            index: item.index,
            frontText: item.frontText,
            backText: item.backText,
            sourceAudioURL: item.sourceAudioURL,
            targetAudioURL: item.targetAudioURL
        )

        return ListenPlayRow(
            id: item.id,
            titleText: source.isEmpty ? target : source,
            sourceText: source,
            languageText: primary.isEmpty ? target : primary,
            secondaryText: secondary.isEmpty ? source : secondary,
            card: card,
            sourceAudioURL: audioByFavoriteID[item.id]?.sourceURL ?? item.sourceAudioURL,
            targetAudioURL: audioByFavoriteID[item.id]?.targetURL ?? item.targetAudioURL
        )
    }

    @objc
    private func previousButtonAction() {
        navigate(offset: -1)
    }

    @objc
    private func playButtonAction() {
        guard !words.isEmpty else { return }
        if selectedIndex == nil {
            selectedIndex = 0
        }
        tableView.reloadData()
        scrollToSelectedRow(animated: true)
        if let selectedIndex {
            playManually(at: selectedIndex, rate: 1.0)
        }
    }

    @objc
    private func nextButtonAction() {
        navigate(offset: 1)
    }

    @objc
    private func searchTextDidChange() {
        applySearchFilter()
    }

    @objc
    private func dismissKeyboardTapAction() {
        view.endEditing(true)
    }

    private func navigate(offset: Int) {
        guard !words.isEmpty else { return }
        let current = selectedIndex ?? 0
        let newIndex = min(max(current + offset, 0), words.count - 1)
        selectedIndex = newIndex
        tableView.reloadData()
        scrollToSelectedRow(animated: true)
        playManually(at: newIndex, rate: 1.0)
    }

    private func scrollToSelectedRow(animated: Bool) {
        guard let selectedIndex, words.indices.contains(selectedIndex) else { return }
        guard tableView.numberOfRows(inSection: 0) > selectedIndex else { return }

        let indexPath = IndexPath(row: selectedIndex, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }

    private func playManually(at index: Int, rate: Float) {
        guard words.indices.contains(index) else { return }
        let row = makeRow(from: words[index])
        playRowAudio(row: row, rate: rate)
    }

    private func playRowAudio(row: ListenPlayRow, rate: Float) {
        let audioSequence = orderedAudioURLs(for: row)
        guard !audioSequence.isEmpty else { return }
        playAudioSequence(audioSequence, at: 0, rate: rate)
    }

    private func orderedAudioURLs(for row: ListenPlayRow) -> [URL] {
        var result: [URL] = []
        if let sourceAudioURL = row.sourceAudioURL {
            result.append(sourceAudioURL)
        }
        if let targetAudioURL = row.targetAudioURL,
           targetAudioURL != row.sourceAudioURL {
            result.append(targetAudioURL)
        }
        return result
    }

    private func playAudioSequence(_ urls: [URL], at index: Int, rate: Float) {
        guard urls.indices.contains(index) else { return }

        ensurePlaybackAudioSession()
        removeItemFinishObserver()

        let playerItem = AVPlayerItem(url: urls[index])
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
            guard let self else { return }
            self.playAudioSequence(urls, at: index + 1, rate: rate)
        }

        if rate == 1 {
            player?.play()
        } else {
            player?.playImmediately(atRate: rate)
        }
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

    private func normalizedSearchText(_ value: String?) -> String {
        (value ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }

    private func matchesSearch(_ value: String, query: String) -> Bool {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .contains(query)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListenPlayExpandedCell.reuseId,
            for: indexPath
        ) as? ListenPlayExpandedCell else {
            return UITableViewCell()
        }

        let word = words[indexPath.row]
        let row = makeRow(from: word)
        cell.configure(
            row: row,
            isFavorite: true,
            isInPlayList: false,
            isSelectedState: selectedIndex == indexPath.row
        )
        cell.onFavoriteTap = { [weak self] in
            self?.removeFavorite(id: word.id)
        }
        cell.onDownloadTap = nil
        cell.onSpeakerTap = { [weak self] in
            self?.playManually(at: indexPath.row, rate: 1.0)
        }
        cell.onTurtleTap = { [weak self] in
            self?.playManually(at: indexPath.row, rate: 0.7)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let row = makeRow(from: words[indexPath.row])
        UIPasteboard.general.string = row.languageText
        playManually(at: indexPath.row, rate: 1.0)
        tableView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === keyboardDismissTapGesture else { return true }
        if let touchedView = touch.view, touchedView.isDescendant(of: searchContainerView) {
            return false
        }
        return true
    }
}

struct ListenPlayRow {
    let id: String
    let titleText: String
    let sourceText: String
    let languageText: String
    let secondaryText: String
    let card: FCCard
    let sourceAudioURL: URL?
    let targetAudioURL: URL?
}

private final class FavoritesInsetLabel: UILabel {
    var textInsets: UIEdgeInsets = .zero {
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

final class ListenPlayExpandedCell: UITableViewCell {
    static let reuseId = "ListenPlayExpandedCell"

    var onDownloadTap: (() -> Void)?
    var onFavoriteTap: (() -> Void)?
    var onTurtleTap: (() -> Void)?
    var onSpeakerTap: (() -> Void)?

    private let shadowContainerView = UIView()
    private let cardView = UIView()
    private let separatorView = UIView()

    private let titleLabel = FavoritesInsetLabel()
    private let favoriteButton = UIButton(type: .system)

    private let languageLabel = FavoritesInsetLabel()
    private let speakerButton = UIButton(type: .system)

    private let secondaryLabel = UILabel()
    private let turtleButton = UIButton(type: .system)
    private var lastShadowBounds: CGRect = .zero

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowPath()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onDownloadTap = nil
        onFavoriteTap = nil
        onTurtleTap = nil
        onSpeakerTap = nil
    }

    func configure(
        row: ListenPlayRow,
        isFavorite: Bool,
        isInPlayList: Bool,
        isSelectedState: Bool,
        isSourceAudioPlaying: Bool = false,
        isTargetAudioPlaying: Bool = false
    ) {
        titleLabel.text = row.titleText
        languageLabel.text = row.languageText
        secondaryLabel.text = row.secondaryText
        cardView.layer.borderColor = isSelectedState ? AppTheme.currentPalette.listenTint.cgColor : UIColor.clear.cgColor
        updatePlaybackHighlight(
            isSourceAudioPlaying: isSourceAudioPlaying,
            isTargetAudioPlaying: isTargetAudioPlaying
        )

        let favoriteSymbol = isFavorite ? "word-heart-fill" : "word-heart-empty"
        setButtonSymbol(favoriteButton, symbol: favoriteSymbol)
    }

    func updatePlaybackHighlight(isSourceAudioPlaying: Bool, isTargetAudioPlaying: Bool) {
        applySourceHighlight(isSourceAudioPlaying)
        applyTargetHighlight(isTargetAudioPlaying)
    }

    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false

        shadowContainerView.backgroundColor = .clear
        shadowContainerView.layer.shadowColor = UIColor.black.cgColor
        shadowContainerView.layer.shadowOpacity = 0.05
        shadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        shadowContainerView.layer.shadowRadius = 12
        shadowContainerView.layer.masksToBounds = false

        cardView.backgroundColor = .appCard
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = UIColor.clear.cgColor
        cardView.layer.masksToBounds = true

        separatorView.backgroundColor = .separatorColor.withAlphaComponent(0.7)

        titleLabel.font = .sfPro(.regular, size: 15)
        titleLabel.textColor = .appPrimaryText
        titleLabel.numberOfLines = 0

        configureButton(favoriteButton, symbol: "heart")
        configureButton(turtleButton, symbol: "play-slow")
        configureButton(speakerButton, symbol: "play-circle-small")

        languageLabel.font = .sfPro(.regular, size: 15)
        languageLabel.textColor = AppTheme.currentPalette.listenTint
        languageLabel.numberOfLines = 0

        secondaryLabel.font = .sfPro(.regular, size: 13)
        secondaryLabel.textColor = .appPrimaryText.withAlphaComponent(0.6)
        secondaryLabel.numberOfLines = 0
        secondaryLabel.backgroundColor = AppTheme.currentPalette.listenSecondaryTint
        secondaryLabel.layer.cornerRadius = 6
        secondaryLabel.layer.masksToBounds = true

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        turtleButton.addTarget(self, action: #selector(turtleTapped), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(speakerTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        [shadowContainerView, cardView, titleLabel, favoriteButton, separatorView, languageLabel, speakerButton, secondaryLabel, turtleButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(shadowContainerView)
        shadowContainerView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(favoriteButton)
        cardView.addSubview(separatorView)
        cardView.addSubview(languageLabel)
        cardView.addSubview(speakerButton)
        cardView.addSubview(secondaryLabel)
        cardView.addSubview(turtleButton)

        NSLayoutConstraint.activate([
            shadowContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            shadowContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shadowContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shadowContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            cardView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 17),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 26),
            titleLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -8),

            favoriteButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 15),
            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            favoriteButton.widthAnchor.constraint(equalToConstant: 19),
            favoriteButton.heightAnchor.constraint(equalToConstant: 19),

            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 17),
            separatorView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -17),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            languageLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            languageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 17),
            languageLabel.trailingAnchor.constraint(lessThanOrEqualTo: speakerButton.leadingAnchor, constant: -10),
            languageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 26),

            speakerButton.widthAnchor.constraint(equalToConstant: 24),
            speakerButton.heightAnchor.constraint(equalToConstant: 24),
            speakerButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            speakerButton.topAnchor.constraint(equalTo: languageLabel.topAnchor),

            secondaryLabel.topAnchor.constraint(equalTo: languageLabel.bottomAnchor, constant: 13),
            secondaryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 17),
            secondaryLabel.trailingAnchor.constraint(lessThanOrEqualTo: turtleButton.leadingAnchor, constant: -10),
            secondaryLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -13),

            turtleButton.widthAnchor.constraint(equalToConstant: 20),
            turtleButton.heightAnchor.constraint(equalToConstant: 20),
            turtleButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            turtleButton.topAnchor.constraint(equalTo: secondaryLabel.topAnchor)
        ])

        languageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        secondaryLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func updateShadowPath() {
        let bounds = shadowContainerView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard bounds != lastShadowBounds else { return }
        lastShadowBounds = bounds
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shadowContainerView.layer.shadowPath = shadowPath
        CATransaction.commit()
    }

    private func applySourceHighlight(_ isHighlighted: Bool) {
        if isHighlighted {
            titleLabel.font = .sfPro(.regular, size: 18)
            titleLabel.textColor = AppTheme.currentPalette.ctaButton
            titleLabel.backgroundColor = AppTheme.currentPalette.listenTint
            titleLabel.layer.cornerRadius = 8
            titleLabel.layer.masksToBounds = true
            titleLabel.textInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
            return
        }

        titleLabel.font = .sfPro(.regular, size: 15)
        titleLabel.textColor = .appPrimaryText
        titleLabel.backgroundColor = .clear
        titleLabel.layer.cornerRadius = 0
        titleLabel.layer.masksToBounds = false
        titleLabel.textInsets = .zero
    }

    private func applyTargetHighlight(_ isHighlighted: Bool) {
        if isHighlighted {
            languageLabel.font = .sfPro(.regular, size: 18)
            languageLabel.textColor = AppTheme.currentPalette.ctaButton
            languageLabel.backgroundColor = AppTheme.currentPalette.listenTint
            languageLabel.layer.cornerRadius = 8
            languageLabel.layer.masksToBounds = true
            languageLabel.textInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
            return
        }

        languageLabel.font = .sfPro(.regular, size: 15)
        languageLabel.textColor = AppTheme.currentPalette.listenTint
        languageLabel.backgroundColor = .clear
        languageLabel.layer.cornerRadius = 0
        languageLabel.layer.masksToBounds = false
        languageLabel.textInsets = .zero
    }

    private func configureButton(_ button: UIButton, symbol: String) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: symbol)
        button.configuration = config
    }

    private func setButtonSymbol(_ button: UIButton, symbol: String) {
        var config = button.configuration ?? UIButton.Configuration.plain()
        config.image = UIImage(named: symbol)
        button.configuration = config
    }

    @objc
    private func favoriteTapped() {
        onFavoriteTap?()
    }

    @objc
    private func turtleTapped() {
        onTurtleTap?()
    }

    @objc
    private func speakerTapped() {
        onSpeakerTap?()
    }
}
