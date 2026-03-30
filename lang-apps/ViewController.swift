//
//  ViewController.swift
//  lang-apps
//
//  Created by Burak Kose on 10.02.2026.
//

import UIKit

final class ViewController: UIViewController {
    private let freeTopicLimit = 3

    private struct Topic {
        let station: LearningStation
        let subtitle: String
        let subtitleColor: UIColor
    }

    private static let subtitleColorPalette: [UIColor] = [
        UIColor(hex: "#B8B1A2"),
        UIColor(hex: "#3A8DFF"),
        UIColor(hex: "#FF9F2F"),
        UIColor(hex: "#B575FF"),
        UIColor(hex: "#33B8C7"),
        UIColor(hex: "#FF6A8C")
    ]

    private var topics: [Topic] = []

    private var fallbackTopics: [Topic] {
        let defaults: [LearningStation] = [
            LearningStation(id: "1", name: "People", streamURL: "", imageURL: "", desc: "English lesson", longDesc: "", translations: nil),
            LearningStation(id: "2", name: "Family members", streamURL: "", imageURL: "", desc: "English lesson", longDesc: "", translations: nil),
            LearningStation(id: "3", name: "Greetings", streamURL: "", imageURL: "", desc: "English lesson", longDesc: "", translations: nil)
        ]

        return defaults.enumerated().map { index, station in
            Topic(
                station: station,
                subtitle: station.desc,
                subtitleColor: Self.subtitleColorPalette[index % Self.subtitleColorPalette.count]
            )
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TopicCell.self, forCellWithReuseIdentifier: TopicCell.reuseIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        setupLayout()
        loadTopics()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePremiumStateChanged),
            name: .didPremiumStatusChanged,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserManager.shared.checkSubscriptionStatus()
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
    }

    private func configureNavigationBar() {
        let navTitle = UILabel()
        navTitle.text = TargetManager.current.lessonsNavigationTitle
        navTitle.font = .sfPro(.semiBold, size: 24)
        navTitle.textColor = .appPrimaryText
        let navTitleBarButton = UIBarButtonItem(customView: navTitle)
        if #available(iOS 26.0, *) {
            navTitleBarButton.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = navTitleBarButton

        let menuButton = UIBarButtonItem(
            image: UIImage(named: "menu-icon"),
            style: .plain,
            target: self,
            action: #selector(didTapMenu)
        )
        if #available(iOS 26.0, *) {
            menuButton.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = menuButton

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBackground
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .appPrimaryText
    }

    private func loadTopics() {
        LearningStationRepository.loadStationsForCurrentTarget { [weak self] stations in
            guard let self else { return }
            DispatchQueue.main.async {
                let source = stations.isEmpty ? self.fallbackTopics.map(\.station) : stations
                self.topics = source.enumerated().map { index, station in
                    Topic(
                        station: station,
                        subtitle: Self.subtitleText(for: station),
                        subtitleColor: Self.subtitleColorPalette[index % Self.subtitleColorPalette.count]
                    )
                }
                self.collectionView.reloadData()
            }
        }
    }

    private func setupLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc
    private func didTapMenu() {
        let menuViewController = MenuViewController()
        present(menuViewController, animated: true)
    }

    @objc
    private func handlePremiumStateChanged() {
        collectionView.reloadData()
    }

    private func isTopicLocked(at index: Int) -> Bool {
        !UserManager.shared.premium && index >= freeTopicLimit
    }

    private func presentPaywall() {
        guard !UserManager.shared.premium else { return }
        let paywallViewController = PaywallViewController()
        paywallViewController.isRoot = false
        paywallViewController.modalPresentationStyle = .fullScreen
        present(paywallViewController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopicCell.reuseIdentifier,
            for: indexPath
        ) as? TopicCell else {
            return UICollectionViewCell()
        }

        let topic = topics[indexPath.item]
        cell.configure(
            title: topic.station.name,
            subtitle: topic.subtitle,
            subtitleColor: topic.subtitleColor,
            isLocked: isTopicLocked(at: indexPath.item)
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 96)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if isTopicLocked(at: indexPath.item) {
            presentPaywall()
            return
        }
        navigationItem.backButtonDisplayMode = .minimal

        let topic = topics[indexPath.item]
        let viewController = ListenViewControllerVariant1(
            station: topic.station,
            subtitle: topic.subtitle,
            subtitleColor: topic.subtitleColor,
            showWords: false
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension ViewController {
    static func subtitleText(for station: LearningStation) -> String {
        let trimmed = station.desc.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Lesson" : trimmed
    }
}

private final class TopicCell: UICollectionViewCell {
    static let reuseIdentifier = "TopicCell"

    private let cardView = UIView()
    private let iconView = UIImageView(image: UIImage(named: "topic-headphone"))
    private let titleLabel = UILabel()
    private let subtitleLabel = InsetLabel()
    private let labelsStackView = UIStackView()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
    private let lockView = UIImageView(image: UIImage(named: "lock-icon") ?? UIImage(systemName: "lock.fill"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 16).cgPath
    }

    func configure(title: String, subtitle: String, subtitleColor: UIColor, isLocked: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = subtitleColor
        chevronView.isHidden = isLocked
        lockView.isHidden = !isLocked
    }

    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false

        cardView.backgroundColor = .appCard
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 16

        titleLabel.font = .sfPro(.medium, size: 18)
        titleLabel.textColor = .appPrimaryText

        subtitleLabel.font = .sfPro(.regular, size: 12)
        subtitleLabel.textInsets = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 13)
        subtitleLabel.backgroundColor = .appSubtitleBackground
        subtitleLabel.layer.cornerRadius = 12
        subtitleLabel.clipsToBounds = true
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)

        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.alignment = .leading

        chevronView.tintColor = .appPrimaryText
        lockView.tintColor = .appPrimaryText
        lockView.contentMode = .scaleAspectFit
        lockView.isHidden = true
    }

    private func setupLayout() {
        [cardView, iconView, titleLabel, subtitleLabel, labelsStackView, chevronView, lockView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(cardView)
        cardView.addSubview(iconView)
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        cardView.addSubview(labelsStackView)
        cardView.addSubview(chevronView)
        cardView.addSubview(lockView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 19),
            iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -19),
            iconView.widthAnchor.constraint(equalToConstant: 58),
            iconView.heightAnchor.constraint(equalToConstant: 58),

            labelsStackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            labelsStackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            labelsStackView.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -40),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 24),

            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            chevronView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            lockView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            lockView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            lockView.widthAnchor.constraint(equalToConstant: 20),
            lockView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

private final class InsetLabel: UILabel {
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
