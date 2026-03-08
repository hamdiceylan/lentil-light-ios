//
//  OnboardingViewController.swift
//  lang-apps
//
//  Created by Atech on 10.02.2026.
//

import UIKit

private struct OnboardingPage {
    let imageName: String
    let title: String
}

final class OnboardingViewController: UIViewController {
    private enum Storage {
        static let seenKey = "onboarding.seen.v1"
    }

    static var hasSeen: Bool {
        UserDefaults.standard.bool(forKey: Storage.seenKey)
    }

    private let onFinish: () -> Void
    private var currentPage: Int = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(imageName: "onboarding1", title: "Learn by Listening.\nSpeak with Confidence."),
        OnboardingPage(imageName: "onboarding2", title: "Understand Words\nin Context"),
        OnboardingPage(imageName: "onboarding3", title: "Speak Naturally,\nEvery Day")
    ]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.reuseIdentifier)
        return collectionView
    }()

    private let continueButton = OnboardingGradientButton()

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        continueButton.updateGradientFrame()
    }

    private func configureUI() {
        view.backgroundColor = .appBackground

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(AppTheme.currentPalette.ctaButton, for: .normal)
        continueButton.titleLabel?.font = .sfPro(.medium, size: 24)
        continueButton.layer.cornerRadius = 65/2
        continueButton.clipsToBounds = true
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }

    private func setupLayout() {
        [collectionView, continueButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(collectionView)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: UIDevice.responsiveSize(small: -30, medium: -70, large: -70)),
            continueButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }

    @objc
    private func didTapContinue() {
        if currentPage < pages.count - 1 {
            let nextPage = currentPage + 1
            let indexPath = IndexPath(item: nextPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentPage = nextPage
            return
        }

        UserDefaults.standard.set(true, forKey: Storage.seenKey)
        onFinish()
    }
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingPageCell.reuseIdentifier,
            for: indexPath
        ) as? OnboardingPageCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: pages[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        currentPage = Int(round(scrollView.contentOffset.x / pageWidth))
    }
}

private final class OnboardingPageCell: UICollectionViewCell {
    static let reuseIdentifier = "OnboardingPageCell"

    private let decoratorImageView = UIImageView()
    private let heroImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with page: OnboardingPage) {
        heroImageView.image = UIImage(named: page.imageName)
        titleLabel.text = page.title
    }

    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        decoratorImageView.image = UIImage(named: "decorator-image")
        decoratorImageView.contentMode = .scaleToFill
        decoratorImageView.clipsToBounds = true

        heroImageView.contentMode = .scaleAspectFit

        titleLabel.font = .sfPro(.semiBold, size: 30)
        titleLabel.textColor = .appPrimaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
    }

    private func setupLayout() {
        [decoratorImageView, heroImageView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            decoratorImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            decoratorImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            decoratorImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            decoratorImageView.heightAnchor.constraint(equalToConstant: contentView.bounds.height * 0.57),

            heroImageView.bottomAnchor.constraint(equalTo: decoratorImageView.bottomAnchor, constant: -71),
            heroImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: decoratorImageView.bottomAnchor, constant: UIDevice.responsiveSize(small: 30, medium: 62, large: 62)),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
}

private final class OnboardingGradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.buttonGradientStart.cgColor, UIColor.buttonGradientEnd.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateGradientFrame() {
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
}
