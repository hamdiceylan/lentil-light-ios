//
//  StationData.swift
//  lang-apps
//
//  Created by Atech on 16.02.2026.
//

import Foundation

struct StationTranslation: Decodable {
    let source: String
    let target: String
    let startTime: TimeInterval?
    let endTime: TimeInterval?
    let sourceAudioURL: URL?
    let targetAudioURL: URL?
}

struct LearningStation: Decodable {
    let id: String
    let name: String
    let streamURL: String
    let imageURL: String
    let desc: String
    let longDesc: String
    let translations: [StationTranslation]?
}

enum LearningStationRepository {

    private struct StationsPayload: Decodable {
        let station: [LearningStation]
    }

    static func loadStationsForCurrentTarget(completion: @escaping ([LearningStation]) -> Void) {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            completion([])
            return
        }

        let decoder = JSONDecoder()
        if let payload = try? decoder.decode(StationsPayload.self, from: data) {
            completion(sortStations(payload.station))
            return
        }

        if let stations = try? decoder.decode([LearningStation].self, from: data) {
            completion(sortStations(stations))
            return
        }

        completion([])
    }

    static func loadRemoteStationsForCurrentTarget(completion: @escaping ([LearningStation]) -> Void) {
        loadStationsForCurrentTarget(completion: completion)
    }

    private static func sortStations(_ stations: [LearningStation]) -> [LearningStation] {
        stations.sorted {
            let lhs = Int($0.id) ?? Int.max
            let rhs = Int($1.id) ?? Int.max
            return lhs < rhs
        }
    }

}
