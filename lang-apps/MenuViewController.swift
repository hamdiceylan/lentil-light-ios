//
//  MenuViewController.swift
//  lang-apps
//
//  Created by Atech on 10.02.2026.
//

import UIKit
import StoreKit

fileprivate struct MenuItem {
    let title: String
    let iconAssetName: String?
    let fallbackSystemName: String
}

final class MenuViewController: UIViewController {
    private enum ExternalLinks {
        static let supportEmail = "learning-apps@atechconsultancy.co.uk"
        static let privacyURL = URL(string: "https://www.myapp.page/privacy-policy")
        static let termsURL = URL(string :"https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    }


    private let showCloseButton: Bool
    private let contentView = UIView()
    private let closeButton = UIButton(type: .system)
    private var showsPremiumCell: Bool {
        !UserManager.shared.premium
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .zero
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PremiumMenuCell.self, forCellWithReuseIdentifier: PremiumMenuCell.reuseIdentifier)
        collectionView.register(MenuItemCell.self, forCellWithReuseIdentifier: MenuItemCell.reuseIdentifier)
        return collectionView
    }()

    // iconAssetName alanlarina kendi icon isimlerini verebilirsin.
    private let items: [MenuItem] = [
        MenuItem(title: "Share the App", iconAssetName: "share-menu", fallbackSystemName: "sharedwithyou"),
        MenuItem(title: "Rate Us on App Store", iconAssetName: "star-menu", fallbackSystemName: "star"),
        MenuItem(title: "Privacy Policy", iconAssetName: "privacy-menu", fallbackSystemName: "shield"),
        MenuItem(title: "Terms of Service", iconAssetName: "privacy-menu", fallbackSystemName: "shield")
    ]

    init(showCloseButton: Bool = true) {
        self.showCloseButton = showCloseButton
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePremiumStateChanged),
            name: .didGoPremiumNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func configureUI() {
        view.backgroundColor = .clear

        contentView.backgroundColor = .appBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true

        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.appPrimaryText, for: .normal)
        closeButton.titleLabel?.font = .sfPro(.regular, size: 16)
        closeButton.isHidden = !showCloseButton
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }

    private func setupLayout() {
        [contentView, closeButton, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(contentView)
        contentView.addSubview(closeButton)
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            closeButton.heightAnchor.constraint(equalToConstant: showCloseButton ? 24 : 0),

            collectionView.topAnchor.constraint(
                equalTo: showCloseButton ? closeButton.bottomAnchor : contentView.safeAreaLayoutGuide.topAnchor,
                constant: showCloseButton ? 24 : 16
            ),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
            collectionView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc
    private func didTapClose() {
        dismiss(animated: true)
    }

    private func didTapPremium() {
        guard !UserManager.shared.premium else { return }
        let paywallViewController = PaywallViewController()
        paywallViewController.isRoot = false
        paywallViewController.modalPresentationStyle = .fullScreen
        present(paywallViewController, animated: true)
    }

    @objc
    private func handlePremiumStateChanged() {
        collectionView.reloadData()
    }

    private func handleMenuTap(title: String) {
        switch title {
        case "Share the App":
            presentShareSheet()
        case "Rate Us on App Store":
            requestAppReview()
        case "Privacy Policy":
            openExternal(url: ExternalLinks.privacyURL)
        case "Terms of Service":
            openExternal(url: ExternalLinks.termsURL)
        default:
            break
        }
    }

    private func presentShareSheet() {
        let items: [Any] = [
            "Check out this language learning app.",
        ]

        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        present(activityController, animated: true)
    }
    
    private func requestAppReview() {
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(TargetManager.current.appId)&action=write-review") {
            UIApplication.shared.open(url)
        }
    }

    private func openExternal(url: URL?) {
        guard let url, UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension MenuViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count + (showsPremiumCell ? 1 : 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if showsPremiumCell && indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PremiumMenuCell.reuseIdentifier,
                for: indexPath
            ) as? PremiumMenuCell else {
                return UICollectionViewCell()
            }
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MenuItemCell.reuseIdentifier,
            for: indexPath
        ) as? MenuItemCell else {
            return UICollectionViewCell()
        }
        let itemIndex = indexPath.item - (showsPremiumCell ? 1 : 0)
        guard items.indices.contains(itemIndex) else { return UICollectionViewCell() }
        cell.configure(with: items[itemIndex])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if showsPremiumCell && indexPath.item == 0 {
            didTapPremium()
            return
        }
        let itemIndex = indexPath.item - (showsPremiumCell ? 1 : 0)
        guard items.indices.contains(itemIndex) else { return }
        handleMenuTap(title: items[itemIndex].title)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if showsPremiumCell && indexPath.item == 0 {
            return CGSize(width: collectionView.bounds.width, height: 72)
        }
        return CGSize(width: collectionView.bounds.width, height: 56)
    }
}

private final class PremiumMenuCell: UICollectionViewCell {
    static let reuseIdentifier = "PremiumMenuCell"

    private let gradientContainer = GradientContainerView()
    private let iconView = UIImageView()
    private let titleLabelView = UILabel()
    private let chevronView = UIImageView(image: UIImage(named: "arrow-right"))
    private let contentStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        gradientContainer.layer.cornerRadius = 16

        iconView.image = UIImage(named: "crown-menu")
        iconView.tintColor = AppTheme.currentPalette.ctaButton
        iconView.contentMode = .scaleAspectFit

        titleLabelView.text = "Get Premium"
        titleLabelView.font = .sfPro(.medium, size: 18)
        titleLabelView.textColor = AppTheme.currentPalette.ctaButton

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .fill
        contentStackView.spacing = 10
    }

    private func setupLayout() {
        [gradientContainer, contentStackView, iconView, titleLabelView, chevronView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(gradientContainer)
        gradientContainer.addSubview(contentStackView)
        contentStackView.addArrangedSubview(iconView)
        contentStackView.addArrangedSubview(titleLabelView)
        contentStackView.addArrangedSubview(chevronView)

        NSLayoutConstraint.activate([
            gradientContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentStackView.centerXAnchor.constraint(equalTo: gradientContainer.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: gradientContainer.centerYAnchor),

            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            chevronView.widthAnchor.constraint(equalToConstant: 20),
            chevronView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

private final class GradientContainerView: UIView {

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .buttonGradientStart

        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = [UIColor.buttonGradientStart.cgColor, UIColor.buttonGradientEnd.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class MenuItemCell: UICollectionViewCell {
    static let reuseIdentifier = "MenuItemCell"

    private let iconView = UIImageView()
    private let titleLabelView = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: MenuItem) {
        if let iconName = item.iconAssetName, let image = UIImage(named: iconName) {
            iconView.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            iconView.image = UIImage(systemName: item.fallbackSystemName)
        }
        titleLabelView.text = item.title
    }

    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = AppTheme.currentPalette.appCard
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        iconView.tintColor = .appPrimaryText
        iconView.contentMode = .scaleAspectFit

        titleLabelView.font = .sfPro(.medium, size: 32 / 2)
        titleLabelView.textColor = .appPrimaryText

        chevronView.tintColor = .appPrimaryText
        chevronView.contentMode = .scaleAspectFit
    }

    private func setupLayout() {
        [iconView, titleLabelView, chevronView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabelView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            titleLabelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabelView.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -12),

            chevronView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            chevronView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 14),
            chevronView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
}
