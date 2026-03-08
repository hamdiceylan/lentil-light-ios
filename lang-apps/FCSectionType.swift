//
//  FCSectionType.swift
//  lang-apps
//
//  Created by Atech on 18.02.2026.
//

import Foundation

enum FCSectionType {
    case List
    case Favorites
}

final class FCCard: NSObject, NSCopying {
    var cardId: Int?
    var sectionId: Int?
    var index: Int = 0
    let frontText: String
    let backText: String
    let sourceAudioURL: URL?
    let targetAudioURL: URL?
    var showAnswer: Bool = false

    init(
        cardId: Int? = nil,
        sectionId: Int? = nil,
        index: Int = 0,
        frontText: String,
        backText: String,
        sourceAudioURL: URL? = nil,
        targetAudioURL: URL? = nil
    ) {
        self.cardId = cardId
        self.sectionId = sectionId
        self.index = index
        self.frontText = frontText
        self.backText = backText
        self.sourceAudioURL = sourceAudioURL
        self.targetAudioURL = targetAudioURL
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copied = FCCard(
            cardId: cardId,
            sectionId: sectionId,
            index: index,
            frontText: frontText,
            backText: backText,
            sourceAudioURL: sourceAudioURL,
            targetAudioURL: targetAudioURL
        )
        copied.showAnswer = false
        return copied
    }
}

final class FCSection: NSObject {
    var sectionId: Int?
    var cards: [FCCard]?
    var type: FCSectionType = .List
    var name: String?
    var subtitle: String?
    var sectionIndex: Int = 0

    override init() {
        super.init()
    }

    init(
        sectionId: Int? = nil,
        type: FCSectionType = .List,
        name: String? = nil,
        subtitle: String? = nil,
        sectionIndex: Int = 0,
        cards: [FCCard] = []
    ) {
        self.sectionId = sectionId
        self.type = type
        self.name = name
        self.subtitle = subtitle
        self.sectionIndex = sectionIndex
        self.cards = cards
        super.init()
    }

    func getSectionName() -> String {
        if type == .Favorites {
            return "Favourites"
        }
        return name ?? "Section"
    }

    func getSectionNameWithRomanNumber() -> String {
        getSectionName()
    }
}
