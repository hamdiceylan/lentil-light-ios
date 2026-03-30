//
//  TargetManager.swift
//  lang-apps
//
//  Created by Codex on 20.02.2026.
//

import Foundation

struct TargetConfiguration {
    let appId: String
    let themeTarget: AppThemeTarget
    let lessonsNavigationTitle: String
    let remotePhrasebookEndpoint: String?
    let adMob: AdMobConfiguration
    let revCatApi: String
    let weeklyProductId: String
    let yearlyProductId: String
    let lifetimeProductId: String
}

struct AdMobConfiguration {
    let appID: String
    let bannerUnitID: String
}

enum TargetManager {

    static let current: TargetConfiguration = {
        let bid = Bundle.main.bundleIdentifier ?? ""
        if let c = configuration(for: bid) {
            return c
        }
        return baseConfiguration()
    }()

    private static func configuration(for bundleId: String) -> TargetConfiguration? {
        switch bundleId {
        case "com.diponten.azerbaijani":
            return cfg(
                appId: "6737646573",
                theme: .theme6,
                lessonsNavigationTitle: "Learn Azerbaijani",
                remotePhrasebook: "https://lentil.webron.software/partials/57/azerbaijani_phrasebook.json",
                revCatApi: "",
                weekly: "azerbaijani_weekly",
                yearly: "azerbaijani_yearly",
                lifetime: "azerbaijani_lifetime"
            )
        case "com.diponten.bambara":
            return cfg(
                appId: "6737646423",
                theme: .theme26,
                lessonsNavigationTitle: "Learn Bambara",
                remotePhrasebook: "https://lentil.webron.software/partials/58/bambara_phrasebook.json",
                revCatApi: "",
                weekly: "bambara_weekly",
                yearly: "bambara_yearly",
                lifetime: "bambara_lifetime"
            )
        case "com.diponten.bislama":
            return cfg(
                appId: "6738491003",
                theme: .theme3,
                lessonsNavigationTitle: "Learn Bislama",
                remotePhrasebook: "https://lentil.webron.software/partials/59/bislama_phrasebook.json",
                revCatApi: "",
                weekly: "bislama_weekly",
                yearly: "bislama_yearly",
                lifetime: "bislama_lifetime"
            )
        case "com.diponten.cameroon":
            return cfg(
                appId: "6738719143",
                theme: .theme19,
                lessonsNavigationTitle: "Learn Cameroon",
                remotePhrasebook: "https://lentil.webron.software/partials/60/cameroon_phrasebook.json",
                revCatApi: "",
                weekly: "cameroon_weekly",
                yearly: "cameroon_yearly",
                lifetime: "cameroon_lifetime"
            )
        case "com.diponten.chewa":
            return cfg(
                appId: "6738491060",
                theme: .theme3,
                lessonsNavigationTitle: "Learn Chewa",
                remotePhrasebook: "https://lentil.webron.software/partials/61/chewa_phrasebook.json",
                revCatApi: "",
                weekly: "chewa_weekly",
                yearly: "chewa_yearly",
                lifetime: "chewa_lifetime"
            )
        case "com.diponten.chinyanja":
            return cfg(
                appId: "6738495773",
                theme: .theme13,
                lessonsNavigationTitle: "Learn Chinyanja",
                remotePhrasebook: "https://lentil.webron.software/partials/63/chinyanja_phrasebook.json",
                revCatApi: "",
                weekly: "chinyanja_weekly",
                yearly: "chinyanja_yearly",
                lifetime: "chinyanja_lifetime"
            )
        case "com.diponten.egyptian":
            return cfg(
                appId: "6739933219",
                theme: .theme20,
                lessonsNavigationTitle: "Learn Egyptian Arabic",
                remotePhrasebook: "https://lentil.webron.software/partials/64/egyptian_arabic_phrasebook.json",
                revCatApi: "",
                weekly: "egyptian_arabic_weekly",
                yearly: "egyptian_arabic_yearly",
                lifetime: "egyptian_arabic_lifetime"
            )
        case "com.diponten.ewe":
            return cfg(
                appId: "6737794267",
                theme: .theme11,
                lessonsNavigationTitle: "Learn Ewe",
                remotePhrasebook: "https://lentil.webron.software/partials/65/ewe_phrasebook.json",
                revCatApi: "",
                weekly: "ewe_weekly",
                yearly: "ewe_yearly",
                lifetime: "ewe_lifetime"
            )
        case "com.diponten.fula":
            return cfg(
                appId: "6738495106",
                theme: .theme19,
                lessonsNavigationTitle: "Learn Fula",
                remotePhrasebook: "https://lentil.webron.software/partials/67/fula_phrasebook.json",
                revCatApi: "",
                weekly: "fula_weekly",
                yearly: "fula_yearly",
                lifetime: "fula_lifetime"
            )
        case "com.diponten.hausa":
            return cfg(
                appId: "6737822433",
                theme: .theme7,
                lessonsNavigationTitle: "Learn Hausa",
                remotePhrasebook: "https://lentil.webron.software/partials/68/hausa_phrasebook.json",
                revCatApi: "",
                weekly: "hausa_weekly",
                yearly: "hausa_yearly",
                lifetime: "hausa_lifetime"
            )
        case "com.diponten.hijazi":
            return cfg(
                appId: "6739933127",
                theme: .theme26,
                lessonsNavigationTitle: "Learn Hijazi Dialect",
                remotePhrasebook: "https://lentil.webron.software/partials/69/hijazi_dialect_phrasebook.json",
                revCatApi: "",
                weekly: "hijazi_dialect_weekly",
                yearly: "hijazi_dialect_yearly",
                lifetime: "hijazi_dialect_lifetime"
            )
        case "com.diponten.igbo":
            return cfg(
                appId: "6737974748",
                theme: .theme16,
                lessonsNavigationTitle: "Learn Igbo",
                remotePhrasebook: "https://lentil.webron.software/partials/70/igbo_phrasebook.json",
                revCatApi: "",
                weekly: "igbo_weekly",
                yearly: "igbo_yearly",
                lifetime: "igbo_lifetime"
            )
        case "com.diponten.iraqi":
            return cfg(
                appId: "6738719112",
                theme: .theme23,
                lessonsNavigationTitle: "Learn Iraqi",
                remotePhrasebook: "https://lentil.webron.software/partials/71/iraqi_phrasebook.json",
                revCatApi: "",
                weekly: "iraqi_weekly",
                yearly: "iraqi_yearly",
                lifetime: "iraqi_lifetime"
            )
        case "com.diponten.jahanka":
            return cfg(
                appId: "6738232342",
                theme: .theme2,
                lessonsNavigationTitle: "Learn Jahanka",
                remotePhrasebook: "https://lentil.webron.software/partials/72/jahanka_phrasebook.json",
                revCatApi: "",
                weekly: "jahanka_weekly",
                yearly: "jahanka_yearly",
                lifetime: "jahanka_lifetime"
            )
        case "com.diponten.jola":
            return cfg(
                appId: "6737974902",
                theme: .theme24,
                lessonsNavigationTitle: "Learn Jola",
                remotePhrasebook: "https://lentil.webron.software/partials/73/jola_phrasebook.json",
                revCatApi: "",
                weekly: "jola_weekly",
                yearly: "jola_yearly",
                lifetime: "jola_lifetime"
            )
        case "com.diponten.jordanian":
            return cfg(
                appId: "6738719108",
                theme: .theme2,
                lessonsNavigationTitle: "Learn Jordanian",
                remotePhrasebook: "https://lentil.webron.software/partials/74/jordanian_phrasebook.json",
                revCatApi: "",
                weekly: "jordanian_weekly",
                yearly: "jordanian_yearly",
                lifetime: "jordanian_lifetime"
            )
        case "com.diponten.kirundi":
            return cfg(
                appId: "6737974987",
                theme: .theme21,
                lessonsNavigationTitle: "Learn Kirundi",
                remotePhrasebook: "https://lentil.webron.software/partials/75/kirundi_phrasebook.json",
                revCatApi: "",
                weekly: "kirundi_weekly",
                yearly: "kirundi_yearly",
                lifetime: "kirundi_lifetime"
            )
        case "com.diponten.kituba":
            return cfg(
                appId: "6737822376",
                theme: .theme14,
                lessonsNavigationTitle: "Learn Kituba",
                remotePhrasebook: "https://lentil.webron.software/partials/76/kituba_phrasebook.json",
                revCatApi: "",
                weekly: "kituba_weekly",
                yearly: "kituba_yearly",
                lifetime: "kituba_lifetime"
            )
        case "com.diponten.krio":
            return cfg(
                appId: "6737822540",
                theme: .theme2,
                lessonsNavigationTitle: "Learn Krio",
                remotePhrasebook: "https://lentil.webron.software/partials/77/krio_phrasebook.json",
                revCatApi: "",
                weekly: "krio_weekly",
                yearly: "krio_yearly",
                lifetime: "krio_lifetime"
            )
        case "com.diponten.lao":
            return cfg(
                appId: "6737822232",
                theme: .theme8,
                lessonsNavigationTitle: "Learn Lao",
                remotePhrasebook: "https://lentil.webron.software/partials/78/lao_phrasebook.json",
                revCatApi: "",
                weekly: "lao_weekly",
                yearly: "lao_yearly",
                lifetime: "lao_lifetime"
            )
        case "com.diponten.levantine":
            return cfg(
                appId: "6737794190",
                theme: .theme16,
                lessonsNavigationTitle: "Learn Levantine",
                remotePhrasebook: "https://lentil.webron.software/partials/79/levantine_phrasebook.json",
                revCatApi: "",
                weekly: "levantine_weekly",
                yearly: "levantine_yearly",
                lifetime: "levantine_lifetime"
            )
        case "com.diponten.lingala":
            return cfg(
                appId: "6738232007",
                theme: .theme10,
                lessonsNavigationTitle: "Learn Lingala",
                remotePhrasebook: "https://lentil.webron.software/partials/80/lingala_phrasebook.json",
                revCatApi: "",
                weekly: "lingala_weekly",
                yearly: "lingala_yearly",
                lifetime: "lingala_lifetime"
            )
        case "com.diponten.luganda":
            return cfg(
                appId: "6737794461",
                theme: .theme3,
                lessonsNavigationTitle: "Learn Luganda",
                remotePhrasebook: "https://lentil.webron.software/partials/81/luganda_phrasebook.json",
                revCatApi: "",
                weekly: "luganda_weekly",
                yearly: "luganda_yearly",
                lifetime: "luganda_lifetime"
            )
        case "com.diponten.madinka":
            return cfg(
                appId: "6737974870",
                theme: .theme5,
                lessonsNavigationTitle: "Learn Madinka",
                remotePhrasebook: "https://lentil.webron.software/partials/82/madinka_phrasebook.json",
                revCatApi: "",
                weekly: "madinka_weekly",
                yearly: "madinka_yearly",
                lifetime: "madinka_lifetime"
            )
        case "com.diponten.malagasy":
            return cfg(
                appId: "6737646629",
                theme: .theme16,
                lessonsNavigationTitle: "Learn Malagasy",
                remotePhrasebook: "https://lentil.webron.software/partials/83/malagasy_phrasebook.json",
                revCatApi: "",
                weekly: "malagasy_weekly",
                yearly: "malagasy_yearly",
                lifetime: "malagasy_lifetime"
            )
        case "com.diponten.mali":
            return cfg(
                appId: "6738719135",
                theme: .theme14,
                lessonsNavigationTitle: "Learn French Mali",
                remotePhrasebook: "https://lentil.webron.software/partials/66/french_mali_phrasebook.json",
                revCatApi: "",
                weekly: "french_mali_weekly",
                yearly: "french_mali_yearly",
                lifetime: "french_mali_lifetime"
            )
        case "com.diponten.mauritanian":
            return cfg(
                appId: "6738719197",
                theme: .theme13,
                lessonsNavigationTitle: "Learn Mauritanian",
                remotePhrasebook: "https://lentil.webron.software/partials/84/mauritanian_phrasebook.json",
                revCatApi: "",
                weekly: "mauritanian_weekly",
                yearly: "mauritanian_yearly",
                lifetime: "mauritanian_lifetime"
            )
        case "com.diponten.moldovan":
            return cfg(
                appId: "6737729573",
                theme: .theme4,
                lessonsNavigationTitle: "Learn Moldovan",
                remotePhrasebook: "https://lentil.webron.software/partials/85/moldovan_phrasebook.json",
                revCatApi: "",
                weekly: "moldovan_weekly",
                yearly: "moldovan_yearly",
                lifetime: "moldovan_lifetime"
            )
        case "com.diponten.mongolian":
            return cfg(
                appId: "6737646465",
                theme: .theme23,
                lessonsNavigationTitle: "Learn Mongolian",
                remotePhrasebook: "https://lentil.webron.software/partials/86/mongolian_phrasebook.json",
                revCatApi: "",
                weekly: "mongolian_weekly",
                yearly: "mongolian_yearly",
                lifetime: "mongolian_lifetime"
            )
        case "com.diponten.moore":
            return cfg(
                appId: "6738493696",
                theme: .theme17,
                lessonsNavigationTitle: "Learn Moore",
                remotePhrasebook: "https://lentil.webron.software/partials/87/moore_phrasebook.json",
                revCatApi: "",
                weekly: "moore_weekly",
                yearly: "moore_yearly",
                lifetime: "moore_lifetime"
            )
        case "com.diponten.moremossi":
            return cfg(
                appId: "6737729601",
                theme: .theme8,
                lessonsNavigationTitle: "Learn More (Mossi)",
                remotePhrasebook: "https://lentil.webron.software/partials/89/more_mossi_phrasebook.json",
                revCatApi: "",
                weekly: "more_mossi_weekly",
                yearly: "more_mossi_yearly",
                lifetime: "more_mossi_lifetime"
            )
        case "com.diponten.moroccan":
            return cfg(
                appId: "6737792024",
                theme: .theme13,
                lessonsNavigationTitle: "Learn Moroccan",
                remotePhrasebook: "https://lentil.webron.software/partials/88/moroccan_phrasebook.json",
                revCatApi: "",
                weekly: "moroccan_weekly",
                yearly: "moroccan_yearly",
                lifetime: "moroccan_lifetime"
            )
        case "com.diponten.nepali":
            return cfg(
                appId: "6737729427",
                theme: .theme18,
                lessonsNavigationTitle: "Learn Nepali",
                remotePhrasebook: "https://lentil.webron.software/partials/90/nepali_phrasebook.json",
                revCatApi: "",
                weekly: "nepali_weekly",
                yearly: "nepali_yearly",
                lifetime: "nepali_lifetime"
            )
        case "com.diponten.pulaar":
            return cfg(
                appId: "6737729599",
                theme: .theme23,
                lessonsNavigationTitle: "Learn Pulaar",
                remotePhrasebook: "https://lentil.webron.software/partials/91/pulaar_phrasebook.json",
                revCatApi: "",
                weekly: "pulaar_weekly",
                yearly: "pulaar_yearly",
                lifetime: "pulaar_lifetime"
            )
        case "com.diponten.samoan":
            return cfg(
                appId: "6737729630",
                theme: .theme20,
                lessonsNavigationTitle: "Learn Samoan",
                remotePhrasebook: "https://lentil.webron.software/partials/92/samoan_phrasebook.json",
                revCatApi: "",
                weekly: "samoan_weekly",
                yearly: "samoan_yearly",
                lifetime: "samoan_lifetime"
            )
        case "com.diponten.sarahulle":
            return cfg(
                appId: "6737974975",
                theme: .theme19,
                lessonsNavigationTitle: "Learn Sarahulle",
                remotePhrasebook: "https://lentil.webron.software/partials/93/sarahulle_phrasebook.json",
                revCatApi: "",
                weekly: "sarahulle_weekly",
                yearly: "sarahulle_yearly",
                lifetime: "sarahulle_lifetime"
            )
        case "com.diponten.setswana":
            return cfg(
                appId: "6738232076",
                theme: .theme4,
                lessonsNavigationTitle: "Learn Setswana",
                remotePhrasebook: "https://lentil.webron.software/partials/94/setswana_phrasebook.json",
                revCatApi: "",
                weekly: "setswana_weekly",
                yearly: "setswana_yearly",
                lifetime: "setswana_lifetime"
            )
        case "com.diponten.shona":
            return cfg(
                appId: "6738232061",
                theme: .theme10,
                lessonsNavigationTitle: "Learn Shona",
                remotePhrasebook: "https://lentil.webron.software/partials/95/shona_phrasebook.json",
                revCatApi: "",
                weekly: "shona_weekly",
                yearly: "shona_yearly",
                lifetime: "shona_lifetime"
            )
        case "com.diponten.soninke":
            return cfg(
                appId: "6737729575",
                theme: .theme18,
                lessonsNavigationTitle: "Learn Soninke",
                remotePhrasebook: "https://lentil.webron.software/partials/96/soninke_phrasebook.json",
                revCatApi: "",
                weekly: "soninke_weekly",
                yearly: "soninke_yearly",
                lifetime: "soninke_lifetime"
            )
        case "com.diponten.sranan":
            return cfg(
                appId: "6737822488",
                theme: .theme4,
                lessonsNavigationTitle: "Learn Sranan",
                remotePhrasebook: "https://lentil.webron.software/partials/97/sranan_phrasebook.json",
                revCatApi: "",
                weekly: "sranan_weekly",
                yearly: "sranan_yearly",
                lifetime: "sranan_lifetime"
            )
        case "com.diponten.syrian":
            return cfg(
                appId: "6738719203",
                theme: .theme6,
                lessonsNavigationTitle: "Learn Syrian",
                remotePhrasebook: "https://lentil.webron.software/partials/98/syrian_phrasebook.json",
                revCatApi: "",
                weekly: "syrian_weekly",
                yearly: "syrian_yearly",
                lifetime: "syrian_lifetime"
            )
        case "com.diponten.twi":
            return cfg(
                appId: "6738495359",
                theme: .theme5,
                lessonsNavigationTitle: "Learn Twi",
                remotePhrasebook: "https://lentil.webron.software/partials/99/twi_phrasebook.json",
                revCatApi: "",
                weekly: "twi_weekly",
                yearly: "twi_yearly",
                lifetime: "twi_lifetime"
            )
        case "com.diponten.wolof":
            return cfg(
                appId: "6737974819",
                theme: .theme16,
                lessonsNavigationTitle: "Learn Wolof",
                remotePhrasebook: "https://lentil.webron.software/partials/100/wolof_phrasebook.json",
                revCatApi: "",
                weekly: "wolof_weekly",
                yearly: "wolof_yearly",
                lifetime: "wolof_lifetime"
            )
        case "com.diponten.yoruba":
            return cfg(
                appId: "6738232063",
                theme: .theme11,
                lessonsNavigationTitle: "Learn Yoruba",
                remotePhrasebook: "https://lentil.webron.software/partials/101/yoruba_phrasebook.json",
                revCatApi: "",
                weekly: "yoruba_weekly",
                yearly: "yoruba_yearly",
                lifetime: "yoruba_lifetime"
            )
        case "com.diponten.zarma":
            return cfg(
                appId: "6738232183",
                theme: .theme11,
                lessonsNavigationTitle: "Learn Zarma",
                remotePhrasebook: "https://lentil.webron.software/partials/102/zarma_phrasebook.json",
                revCatApi: "",
                weekly: "zarma_weekly",
                yearly: "zarma_yearly",
                lifetime: "zarma_lifetime"
            )
        case "com.lentil.lang-apps":
            return cfg(
                appId: "",
                theme: .theme1,
                lessonsNavigationTitle: "Learn English",
                remotePhrasebook: nil,
                revCatApi: "",
                weekly: "",
                yearly: "",
                lifetime: ""
            )
        case "motion.studio.cantonese":
            return cfg(
                appId: "1437464903",
                theme: .theme15,
                lessonsNavigationTitle: "Learn Cantonese",
                remotePhrasebook: "https://lentil.webron.software/partials/28/cantonese_phrasebook.json",
                revCatApi: "appl_TWbteZChQykQeCuQcpTweXOkVIu",
                weekly: "cantonese_weekly",
                yearly: "cantonese_yearly",
                lifetime: "cantonese_lifetime"
            )
        case "motion.studio.ch":
            return cfg(
                appId: "1423562291",
                theme: .theme11,
                lessonsNavigationTitle: "Learn Chinese",
                remotePhrasebook: "https://lentil.webron.software/partials/62/chinese_phrasebook.json",
                revCatApi: "",
                weekly: "chinese_weekly",
                yearly: "chinese_yearly",
                lifetime: "chinese_lifetime"
            )
        case "motion.studio.haitian":
            return cfg(
                appId: "1437737010",
                theme: .theme10,
                lessonsNavigationTitle: "Learn Haitian",
                remotePhrasebook: "https://lentil.webron.software/partials/32/haitian_phrasebook.json",
                revCatApi: "appl_KgZlEXSPbwRwqhwNBRquONVgeZV",
                weekly: "haitian_weekly",
                yearly: "haitian_yearly",
                lifetime: "haitian_lifetime"
            )
        case "motion.studio.khmer":
            return cfg(
                appId: "1437854270",
                theme: .theme6,
                lessonsNavigationTitle: "Learn Khmer",
                remotePhrasebook: "https://lentil.webron.software/partials/35/khmer_phrasebook.json",
                revCatApi: "appl_kzJmjOKnitEojDTsJWsCBDqGhOd",
                weekly: "khmer_weekly",
                yearly: "khmer_yearly",
                lifetime: "khmer_lifetime"
            )
        case "motion.studio.swahili":
            return cfg(
                appId: "1437587495",
                theme: .theme12,
                lessonsNavigationTitle: "Learn Swahili",
                remotePhrasebook: "https://lentil.webron.software/partials/29/swahili_phrasebook.json",
                revCatApi: "appl_vOvZkJcAStTSjvSMStjYiXdRspL",
                weekly: "swahili_weekly",
                yearly: "swahili_yearly",
                lifetime: "swahili_lifetime"
            )
        default:
            return nil
        }
    }

    private static func cfg(
        appId: String,
        theme: AppThemeTarget,
        lessonsNavigationTitle: String,
        remotePhrasebook: String?,
        revCatApi: String,
        weekly: String,
        yearly: String,
        lifetime: String
    ) -> TargetConfiguration {
        TargetConfiguration(
            appId: appId,
            themeTarget: theme,
            lessonsNavigationTitle: lessonsNavigationTitle,
            remotePhrasebookEndpoint: remotePhrasebook,
            adMob: AdMobConfiguration(
                appID: infoValue(primaryKey: "ADMOB_APP_ID", fallbackKey: nil),
                bannerUnitID: infoValue(primaryKey: "ADMOB_BANNER_UNIT_ID", fallbackKey: nil)
            ),
            revCatApi: revCatApi,
            weeklyProductId: weekly,
            yearlyProductId: yearly,
            lifetimeProductId: lifetime
        )
    }

    private static func baseConfiguration() -> TargetConfiguration {
        cfg(
            appId: "",
            theme: .theme1,
            lessonsNavigationTitle: "Learn English",
            remotePhrasebook: nil,
            revCatApi: "",
            weekly: "",
            yearly: "",
            lifetime: ""
        )
    }

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
