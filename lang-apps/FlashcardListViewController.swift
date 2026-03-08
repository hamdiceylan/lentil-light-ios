//
//  FlashcardListViewController.swift
//  lang-apps
//
//  Created by Atech on 18.02.2026.
//

import UIKit

final class FlashcardListViewController: UIViewController {

    private let freeSectionLimit = 3

    private var baseSections: [FCSection] = []
    private var sections: [FCSection] = []

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .appBackground
        view.separatorStyle = .none
        view.tableFooterView = UIView()
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No sections found."
        label.textColor = UIColor(hex: "#8E8E93")
        label.font = .sfPro(.medium, size: 17)
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupLayout()
        configureTable()
        loadBaseSections()
        reloadSections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSections()
        tableView.reloadData()
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
    }

    private func setupLayout() {
        [tableView, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        let headerSpacer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 15))
        headerSpacer.backgroundColor = .clear
        tableView.tableHeaderView = headerSpacer

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SectionCell.self, forCellReuseIdentifier: SectionCell.Identifier)
    }

    private func reloadSections() {
        sections = []

        let favoriteCards = FlashcardFavoritesStore.shared.favoriteCards()
        let favoritesSection = FCSection(
            sectionId: -999,
            type: .Favorites,
            name: "Favourites",
            subtitle: "\(favoriteCards.count) words",
            sectionIndex: 0,
            cards: favoriteCards
        )
        sections.append(favoritesSection)

        sections.append(contentsOf: baseSections)
        updateState()
    }

    private func loadBaseSections() {
        LearningStationRepository.loadStationsForCurrentTarget { [weak self] stations in
            guard let self else { return }
            let baseSections = self.makeBaseSections(from: stations)
            DispatchQueue.main.async {
                self.baseSections = baseSections
                self.reloadSections()
            }
        }
    }

    private func makeBaseSections(from stations: [LearningStation]) -> [FCSection] {
        var result: [FCSection] = []

        for (sectionIndex, station) in stations.enumerated() {
            let cards: [FCCard] = (station.translations ?? []).enumerated().compactMap { index, translation in
                let source = translation.source.trimmingCharacters(in: .whitespacesAndNewlines)
                let target = translation.target.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !source.isEmpty, !target.isEmpty else { return nil }

                return FCCard(
                    cardId: index,
                    sectionId: Int(station.id),
                    index: index,
                    frontText: target,
                    backText: source,
                    sourceAudioURL: translation.sourceAudioURL,
                    targetAudioURL: translation.targetAudioURL
                )
            }

            guard !cards.isEmpty else { continue }

            let section = FCSection(
                sectionId: Int(station.id),
                type: .List,
                name: station.name,
                subtitle: "\(cards.count) words",
                sectionIndex: sectionIndex + 1,
                cards: cards
            )
            result.append(section)
        }

        return result
    }

    private func updateState() {
        let isEmpty = sections.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        tableView.reloadData()
    }
}

extension FlashcardListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SectionCell.Identifier,
            for: indexPath
        ) as? SectionCell else {
            return UITableViewCell()
        }

        let section = sections[indexPath.row]
        cell.fillCell(section: section, indexPath: indexPath, isPremiumLocked: isSectionLocked(at: indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSectionLocked(at: indexPath.row) {
            presentPaywall()
            return
        }
        let section = sections[indexPath.row]
        let controller = FlashCardsViewController(section: section)
        navigationController?.pushViewController(controller, animated: true)
    }

    private func isSectionLocked(at index: Int) -> Bool {
        !UserManager.shared.premium && index >= freeSectionLimit
    }

    private func presentPaywall() {
        guard !UserManager.shared.premium else { return }
        let paywallViewController = PaywallViewController()
        paywallViewController.isRoot = false
        paywallViewController.modalPresentationStyle = .fullScreen
        present(paywallViewController, animated: true)
    }
}
