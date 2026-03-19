//
//  SectionCell.swift
//  lang-apps
//
//  Created by Atech on 18.02.2026.
//

import UIKit
import UICircularProgressRing

final class SectionCell: UITableViewCell {

    static let Identifier: String = "SectionCell"

    var label: UILabel?
    var progressRing: UICircularProgressRing?
    private var rightLockView: UIImageView?
    private var lastShadowBounds: CGRect = .zero

    private lazy var shadowContainerView = createShadowContainerView()
    private lazy var containerView = createContainerView()
    private lazy var indexView = createIndexView()

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
        label?.text = nil
        progressRing?.startProgress(to: 0.0, duration: 0.0)
        progressRing?.isHidden = false
        rightLockView?.isHidden = true
    }

    func fillCell(section: FCSection, indexPath: IndexPath, isPremiumLocked: Bool = false) {
        let cardCount = section.cards?.count ?? 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail

        if section.type == .Favorites {
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(
                string: "Favourites\n",
                attributes: [
                    .font: UIFont.sfPro(.medium, size: 16) as Any,
                    .foregroundColor: UIColor.appPrimaryText,
                    .paragraphStyle: paragraphStyle
                ]
            ))
            text.append(NSAttributedString(
                string: "\(cardCount) words",
                attributes: [
                    .font: UIFont.sfPro(.regular, size: 13) as Any,
                    .foregroundColor: UIColor(hex: "#8E8E93"),
                    .paragraphStyle: paragraphStyle
                ]
            ))
            label?.attributedText = text

            indexView.configure(content: .icon(UIImage(systemName: "heart.fill") ?? UIImage()), isPremiumLocked: false)
            progressRing?.isHidden = true
            rightLockView?.isHidden = true
            return
        }

        let titleText = section.getSectionName()
        let subtitleText = "\(cardCount) words"
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            string: "\(titleText)\n",
            attributes: [
                .font: UIFont.sfPro(.medium, size: 16) as Any,
                .foregroundColor: UIColor.appPrimaryText,
                .paragraphStyle: paragraphStyle
            ]
        ))
        text.append(NSAttributedString(
            string: subtitleText,
            attributes: [
                .font: UIFont.sfPro(.regular, size: 13) as Any,
                .foregroundColor: UIColor(hex: "#8E8E93"),
                .paragraphStyle: paragraphStyle
            ]
        ))
        label?.attributedText = text

        indexView.configure(content: .number(section.sectionIndex), isPremiumLocked: isPremiumLocked)

        if isPremiumLocked {
            progressRing?.isHidden = true
            rightLockView?.isHidden = false
            return
        }

        let seenCount = UserDefaults.standard.integer(forKey: "flashcards.lastIndex.\(section.sectionId ?? 0)")
        let total = max(1, cardCount)
        let progress = (CGFloat(min(seenCount, total)) / CGFloat(total)) * 100.0

        progressRing?.isHidden = false
        rightLockView?.isHidden = true
        progressRing?.innerRingColor = AppTheme.currentPalette.listenTint
        progressRing?.maxValue = 100.0
        progressRing?.startProgress(to: progress, duration: 0.3)
    }

    func fillTestCell(section: FCSection, indexPath: IndexPath) {
        fillCell(section: section, indexPath: indexPath)
    }

    func fillMatchCell(section: FCSection, indexPath: IndexPath) {
        fillCell(section: section, indexPath: indexPath)
    }

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false

        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.font = UIFont.sfPro(.regular, size: 16)
        textLabel.textColor = .appPrimaryText
        textLabel.textAlignment = .left
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.numberOfLines = 2
        label = textLabel

        let ring = UICircularProgressRing()
        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.style = .ontop
        ring.outerRingColor = AppTheme.currentPalette.listenSecondaryTint
        ring.circleBackgroundColor = .clear
        ring.outerRingWidth = 3.0
        ring.innerRingWidth = 5.0
        ring.font = UIFont.sfPro(.medium, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        ring.fontColor = UIColor(hex: "#7A7A7A")
        ring.maxValue = 100.0
        progressRing = ring

        let lockView = UIImageView(image: UIImage(named: "lock-icon") ?? UIImage(systemName: "lock.fill"))
        lockView.translatesAutoresizingMaskIntoConstraints = false
        lockView.contentMode = .scaleAspectFit
        lockView.tintColor = UIColor(hex: "#A0A0A0")
        lockView.isHidden = true
        rightLockView = lockView

        contentView.addSubview(shadowContainerView)
        shadowContainerView.addSubview(containerView)
        containerView.addSubview(textLabel)
        containerView.addSubview(ring)
        containerView.addSubview(indexView)
        containerView.addSubview(lockView)
    }

    private func setupLayout() {
        guard let label, let progressRing, let rightLockView else { return }

        NSLayoutConstraint.activate([
            shadowContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shadowContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            shadowContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shadowContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            shadowContainerView.heightAnchor.constraint(equalToConstant: 80),

            containerView.topAnchor.constraint(equalTo: shadowContainerView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowContainerView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowContainerView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowContainerView.bottomAnchor),

            indexView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            indexView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            indexView.heightAnchor.constraint(equalToConstant: 37),
            indexView.widthAnchor.constraint(equalToConstant: 37),

            progressRing.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            progressRing.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            progressRing.heightAnchor.constraint(equalToConstant: 48),
            progressRing.widthAnchor.constraint(equalToConstant: 48),

            rightLockView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            rightLockView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightLockView.widthAnchor.constraint(equalToConstant: 24),
            rightLockView.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: indexView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: progressRing.leadingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    private func createShadowContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 16
        view.layer.masksToBounds = false
        return view
    }

    private func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appCard
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }

    private func updateShadowPath() {
        let bounds = shadowContainerView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard bounds != lastShadowBounds else { return }
        lastShadowBounds = bounds
        let shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        ).cgPath
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shadowContainerView.layer.shadowPath = shadowPath
        CATransaction.commit()
    }

    private func createIndexView() -> SectionIndexView {
        let view = SectionIndexView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }
}

final class SectionIndexView: UIView {

    enum Content {
        case number(Int)
        case icon(UIImage)
    }

    private let numberLabel = UILabel()
    private let iconView = UIImageView()
    private let lockView = UIImageView()
    private let containerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(hex: "#FFC444")
        containerView.layer.cornerRadius = 16

        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = UIFont.sfPro(.medium, size: 14)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white

        lockView.translatesAutoresizingMaskIntoConstraints = false
        lockView.image = UIImage(systemName: "lock.fill")
        lockView.tintColor = UIColor(hex: "#A0A0A0")
        lockView.contentMode = .scaleAspectFit

        addSubview(containerView)
        containerView.addSubview(numberLabel)
        containerView.addSubview(iconView)
        addSubview(lockView)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 32),
            containerView.widthAnchor.constraint(equalToConstant: 32),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),

            numberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            lockView.widthAnchor.constraint(equalToConstant: 12),
            lockView.heightAnchor.constraint(equalToConstant: 12),
            lockView.topAnchor.constraint(equalTo: containerView.topAnchor),
            lockView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    func configure(content: Content, isPremiumLocked: Bool) {
        lockView.isHidden = !isPremiumLocked

        switch content {
        case .number(let num):
            numberLabel.text = "\(num)"
            numberLabel.isHidden = false
            iconView.isHidden = true
        case .icon(let image):
            iconView.image = image
            numberLabel.isHidden = true
            iconView.isHidden = false
        }
    }
}
