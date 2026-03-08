//
//  PhrasebookModels.swift
//  lang-apps
//

import Foundation

struct Phrasebook: Codable {
    let sourceLanguage: Language
    let targetLanguage: Language
    let totalLessons: Int
    let totalPhrases: Int
    let lessons: [Lesson]
}

struct Language: Codable {
    let name: String
    let code: String
}

struct Lesson: Codable {
    let id: Int
    let title: String
    let phraseCount: Int
    let phrases: [Phrase]
}

struct Phrase: Codable {
    let id: String
    let sourceText: String
    let targetText: String
    let romanized: String
    let sourceAudio: URL
    let targetAudio: URL
}
