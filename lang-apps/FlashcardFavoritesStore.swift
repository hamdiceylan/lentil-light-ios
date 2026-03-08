//
//  FlashcardFavoritesStore.swift
//  lang-apps
//
//  Created by Codex on 18.02.2026.
//

import Foundation

struct FlashcardFavoriteItem: Codable, Equatable {
    let id: String
    let sectionId: Int?
    let cardId: Int?
    let index: Int
    let frontText: String
    let backText: String
    let sourceAudioURL: URL?
    let targetAudioURL: URL?
    let createdAt: TimeInterval
}

final class FlashcardFavoritesStore {

    static let shared = FlashcardFavoritesStore()

    private let key = "flashcards.favorites.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isFavorite(card: FCCard) -> Bool {
        let id = favoriteID(for: card)
        return items().contains(where: { $0.id == id })
    }

    @discardableResult
    func toggle(card: FCCard) -> Bool {
        var current = items()
        let item = makeItem(from: card)

        if let index = current.firstIndex(where: { $0.id == item.id }) {
            current.remove(at: index)
            save(current)
            return false
        }

        current.insert(item, at: 0)
        save(deduplicated(current))
        return true
    }

    func favoriteCards() -> [FCCard] {
        items().map {
            FCCard(
                cardId: $0.cardId,
                sectionId: $0.sectionId,
                index: $0.index,
                frontText: $0.frontText,
                backText: $0.backText,
                sourceAudioURL: $0.sourceAudioURL,
                targetAudioURL: $0.targetAudioURL
            )
        }
    }

    func favoriteItems() -> [FlashcardFavoriteItem] {
        items()
    }

    @discardableResult
    func remove(id: String) -> Bool {
        var current = items()
        guard let index = current.firstIndex(where: { $0.id == id }) else { return false }
        current.remove(at: index)
        save(current)
        return true
    }

    private func items() -> [FlashcardFavoriteItem] {
        guard let data = defaults.data(forKey: key) else { return [] }
        guard let decoded = try? JSONDecoder().decode([FlashcardFavoriteItem].self, from: data) else { return [] }
        return decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func save(_ items: [FlashcardFavoriteItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }

    private func deduplicated(_ items: [FlashcardFavoriteItem]) -> [FlashcardFavoriteItem] {
        var seen: Set<String> = []
        var result: [FlashcardFavoriteItem] = []

        for item in items {
            guard !seen.contains(item.id) else { continue }
            seen.insert(item.id)
            result.append(item)
        }

        return result
    }

    private func makeItem(from card: FCCard) -> FlashcardFavoriteItem {
        FlashcardFavoriteItem(
            id: favoriteID(for: card),
            sectionId: card.sectionId,
            cardId: card.cardId,
            index: card.index,
            frontText: card.frontText,
            backText: card.backText,
            sourceAudioURL: card.sourceAudioURL,
            targetAudioURL: card.targetAudioURL,
            createdAt: Date().timeIntervalSince1970
        )
    }

    func favoriteID(for card: FCCard) -> String {
        let sectionId = card.sectionId ?? -1
        let cardId = card.cardId ?? -1
        return "\(sectionId)|\(cardId)|\(card.frontText)|\(card.backText)"
    }
}
