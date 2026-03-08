//
//  TargetManager.swift
//  lang-apps
//
//  Created by Codex on 20.02.2026.
//

import Foundation

enum BuildTargetFlag: String {
    case base
    case km // khmer
    case ht // haitian creole
    case sw // swahili
    case yue // cantonese (ISO 639-3)

    static var current: BuildTargetFlag {
#if KM
        return .km
#elseif HT
        return .ht
#elseif SW
        return .sw
#elseif YUE
        return .yue
#else
        return .base
#endif
    }
}

struct AdMobConfiguration {
    let appID: String
    let bannerUnitID: String
}

struct TargetConfiguration {
    let appId: String
    let flag: BuildTargetFlag
    let themeTarget: AppThemeTarget
    let lessonsNavigationTitle: String
    let remotePhrasebookEndpoint: String?
    let adMob: AdMobConfiguration
    let revCatApi: String
    let weeklyProductId: String
    let yearlyProductId: String
    let lifetimeProductId: String
}

enum TargetManager {
    static let current: TargetConfiguration = {
        switch BuildTargetFlag.current {
        case .base:
            return TargetConfiguration(
                appId: "",
                flag: .base,
                themeTarget: .theme1,
                lessonsNavigationTitle: "Learn English",
                remotePhrasebookEndpoint: nil,
                adMob: AdMobConfiguration(
                    appID: infoValue(primaryKey: "ADMOB_APP_ID", fallbackKey: nil),
                    bannerUnitID: infoValue(primaryKey: "ADMOB_BANNER_UNIT_ID", fallbackKey: nil)
                ),
                revCatApi: "",
                weeklyProductId: "",
                yearlyProductId: "",
                lifetimeProductId: ""
            )
        case .sw:
            return TargetConfiguration(
                appId: "1437587495",
                flag: .sw,
                themeTarget: .theme12,
                lessonsNavigationTitle: "Learn Swahili",
                remotePhrasebookEndpoint: "https://lentil.webron.software/partials/29/swahili_phrasebook.json",
                adMob: AdMobConfiguration(
                    appID: infoValue(primaryKey: "ADMOB_APP_ID", fallbackKey: nil),
                    bannerUnitID: infoValue(primaryKey: "ADMOB_BANNER_UNIT_ID", fallbackKey: nil)
                ),
                revCatApi: "appl_vOvZkJcAStTSjvSMStjYiXdRspL",
                weeklyProductId: "swahili_weekly",
                yearlyProductId: "swahili_yearly",
                lifetimeProductId: "swahili_lifetime"
            )
        case .km:
            return TargetConfiguration(
                appId: "1437854270",
                flag: .km,
                themeTarget: .theme6,
                lessonsNavigationTitle: "Learn Khmer",
                remotePhrasebookEndpoint: "https://lentil.webron.software/partials/35/khmer_phrasebook.json",
                adMob: AdMobConfiguration(
                    appID: infoValue(primaryKey: "ADMOB_APP_ID", fallbackKey: nil),
                    bannerUnitID: infoValue(primaryKey: "ADMOB_BANNER_UNIT_ID", fallbackKey: nil)
                ),
                revCatApi: "appl_kzJmjOKnitEojDTsJWsCBDqGhOd",
                weeklyProductId: "khmer_weekly",
                yearlyProductId: "khmer_yearly",
                lifetimeProductId: "khmer_lifetime"
            )
        case .ht:
            return TargetConfiguration(
                appId: "1437737010",
                flag: .ht,
                themeTarget: .theme10,
                lessonsNavigationTitle: "Learn Haitian",
                remotePhrasebookEndpoint: "https://lentil.webron.software/partials/32/haitian_phrasebook.json",
                adMob: AdMobConfiguration(
                    appID: infoValue(primaryKey: "ADMOB_APP_ID", fallbackKey: nil),
                    bannerUnitID: infoValue(primaryKey: "ADMOB_BANNER_UNIT_ID", fallbackKey: nil)
                ),
                revCatApi: "appl_KgZlEXSPbwRwqhwNBRquONVgeZV",
                weeklyProductId: "haitian_weekly",
                yearlyProductId: "haitian_yearly",
                lifetimeProductId: "haitian_lifetime"
            )
        case .yue:
            return TargetConfiguration(
                appId: "1437464903",
                flag: .yue,
                themeTarget: .theme15,
                lessonsNavigationTitle: "Learn Cantonese",
                remotePhrasebookEndpoint: "https://lentil.webron.software/partials/28/cantonese_phrasebook.json",
                adMob: AdMobConfiguration(
                    appID: infoValue(primaryKey: "ADMOB_APP_ID", fallbackKey: nil),
                    bannerUnitID: infoValue(primaryKey: "ADMOB_BANNER_UNIT_ID", fallbackKey: nil)
                ),
                revCatApi: "appl_TWbteZChQykQeCuQcpTweXOkVIu",
                weeklyProductId: "cantonese_weekly",
                yearlyProductId: "cantonese_yearly",
                lifetimeProductId: "cantonese_lifetime"
            )
        }
    }()

    private static func infoValue(primaryKey: String, fallbackKey: String?) -> String {
        if let value = Bundle.main.object(forInfoDictionaryKey: primaryKey) as? String, !value.isEmpty {
            return value
        }

        if let fallbackKey,
           let fallbackValue = Bundle.main.object(forInfoDictionaryKey: fallbackKey) as? String,
           !fallbackValue.isEmpty {
            return fallbackValue
        }

        return ""
    }
}
