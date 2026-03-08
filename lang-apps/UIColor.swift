//
//  UIColor.swift
//  lang-apps
//
//  Created by Atech on 13.02.2026.
//

import UIKit

enum AppThemeTarget: String {
    case theme1
    case theme2
    case theme3
    case theme4
    case theme5
    case theme6
    case theme7
    case theme8
    case theme9
    case theme10
    case theme11
    case theme12
    case theme13
    case theme14
    case theme15
    case theme16
    case theme17
    case theme18
    case theme19
    case theme20
    case theme21
    case theme22
    case theme23
    case theme24
    case theme25
    case theme26

    static var current: AppThemeTarget {
        TargetManager.current.themeTarget
    }
}

struct AppThemePalette {
    let tabbarUnselected: UIColor
    let appBackground: UIColor
    let appCard: UIColor
    let appPrimaryText: UIColor
    let appSubtitleBackground: UIColor
    let listenTint: UIColor
    let listenSecondaryTint: UIColor
    let separatorColor: UIColor
    let homeHeader: UIColor
    let buttonGradientStart: UIColor
    let buttonGradientEnd: UIColor
    let paywallIcon: UIColor
    let paywallClose: UIColor
    let paywallSelectedBorder: UIColor
    let paywallBorder: UIColor
    let paywallBackground: UIColor
    let paywallSelectedBackground: UIColor
    let paywallSave: UIColor
    let ctaButton: UIColor
}

enum AppTheme {
    static var target: AppThemeTarget = .current

    private static let fallbackPalette = AppThemePalette(
        tabbarUnselected: UIColor(hex: "#989898"),
        appBackground: UIColor(hex: "#F9F9F9"),
        appCard: .white,
        appPrimaryText: UIColor(hex: "#111111"),
        appSubtitleBackground: UIColor(hex: "#F8F8F8"),
        listenTint: UIColor(hex: "#FFFFFF"),
        listenSecondaryTint: UIColor(hex: "#FFFFFF"),
        separatorColor: UIColor(hex: "#3A3A3A"),
        homeHeader: UIColor(hex: "#A05F3A"),
        buttonGradientStart: UIColor(hex: "#3742D7"),
        buttonGradientEnd: UIColor(hex: "#359AE3"),
        paywallIcon: UIColor(hex: "#359AE3"),
        paywallClose: UIColor(hex: "#359AE3"),
        paywallSelectedBorder: UIColor(hex: "#359AE3"),
        paywallBorder: UIColor(hex: "#359AE3"),
        paywallBackground: UIColor(hex: "#359AE3"),
        paywallSelectedBackground: UIColor(hex: "#359AE3"),
        paywallSave: UIColor(hex: "#34C759"),
        ctaButton: UIColor(hex: "#FFFFFF"),
    )

    private static let palettes: [AppThemeTarget: AppThemePalette] = [
        .theme1: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#F9F9F9"),
            appCard: .white,
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#F8F8F8"),
            listenTint: UIColor(hex: "#3A94E7"),
            listenSecondaryTint: UIColor(hex: "#D0EFFF"),
            separatorColor: UIColor(hex: "#3A3A3A"),
            homeHeader: UIColor(hex: "#3F81EA"),
            buttonGradientStart: UIColor(hex: "#3742D7"),
            buttonGradientEnd: UIColor(hex: "#359AE3"),
            paywallIcon: UIColor(hex: "#359AE3"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#359AE3"),
            paywallBorder: UIColor(hex: "#DDDDDD"),
            paywallBackground: UIColor(hex: "#FFFFFF"),
            paywallSelectedBackground: UIColor(hex: "#D1EBFF"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme2: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#1C1C1C"),
            appCard: UIColor(hex: "#282828"),
            appPrimaryText: .white,
            appSubtitleBackground: UIColor(hex: "#353535"),
            listenTint: UIColor(hex: "#666666"),
            listenSecondaryTint: UIColor(hex: "#D9D9D9"),
            separatorColor: UIColor(hex: "#424242"),
            homeHeader: UIColor(hex: "#373737"),
            buttonGradientStart: UIColor(hex: "#3742D7"),
            buttonGradientEnd: UIColor(hex: "#359AE3"),
            paywallIcon: UIColor(hex: "#359AE3"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#007AFF"),
            paywallBorder: UIColor(hex: "#515151"),
            paywallBackground: UIColor(hex: "#2F2F2F"),
            paywallSelectedBackground: UIColor(hex: "#2E4660"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme3: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#F0B48F"),
            appCard: UIColor(hex: "#F8C3A2"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#FFD9C2"),
            listenTint: UIColor(hex: "#A05F3A"),
            listenSecondaryTint: UIColor(hex: "#E0AA88"),
            separatorColor: UIColor(hex: "#CB926F"),
            homeHeader: UIColor(hex: "#D68F67"),
            buttonGradientStart: UIColor(hex: "#B8714A"),
            buttonGradientEnd: UIColor(hex: "#9C5C37"),
            paywallIcon: UIColor(hex: "#D68F67"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#CF7644"),
            paywallBorder: UIColor(hex: "#D68F67"),
            paywallBackground: UIColor(hex: "#F6C5A9"),
            paywallSelectedBackground: UIColor(hex: "#FFDFCE"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme4: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#342C28"),
            appCard: UIColor(hex: "#3C322E"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#342C28"),
            listenTint: UIColor(hex: "#666666"),
            listenSecondaryTint: UIColor(hex: "#D9D9D9"),
            separatorColor: UIColor(hex: "#424242"),
            homeHeader: UIColor(hex: "#3E332E"),
            buttonGradientStart: UIColor(hex: "#B8714A"),
            buttonGradientEnd: UIColor(hex: "#9C5C37"),
            paywallIcon: UIColor(hex: "#A05E39"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#B57048"),
            paywallBorder: UIColor(hex: "#4D3E37"),
            paywallBackground: UIColor(hex: "#3E332E"),
            paywallSelectedBackground: UIColor(hex: "#553E30"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme5: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#F9DEDC"),
            appCard: UIColor(hex: "#F9DEDC"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#FCEEEE"),
            listenTint: UIColor(hex: "#E46962"),
            listenSecondaryTint: UIColor(hex: "#E19996"),
            separatorColor: UIColor(hex: "#CB926F"),
            homeHeader: UIColor(hex: "#F2B8B5"),
            buttonGradientStart: UIColor(hex: "#E46962"),
            buttonGradientEnd: UIColor(hex: "#E46962"),
            paywallIcon: UIColor(hex: "#E46962"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#E46962"),
            paywallBorder: UIColor(hex: "#F1ADA9"),
            paywallBackground: UIColor(hex: "#F9DEDC"),
            paywallSelectedBackground: UIColor(hex: "#F2B8B5"),
            paywallSave: UIColor(hex: "#F19893"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme6: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#000000"),
            appCard: UIColor(hex: "#1E1116"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#39222A"),
            listenTint: UIColor(hex: "#A76C83"),
            listenSecondaryTint: UIColor(hex: "#5A283C"),
            separatorColor: UIColor(hex: "#424242"),
            homeHeader: UIColor(hex: "#31101D"),
            buttonGradientStart: UIColor(hex: "#BB7D96"),
            buttonGradientEnd: UIColor(hex: "#532236"),
            paywallIcon: UIColor(hex: "#A2677E"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#AC7088"),
            paywallBorder: UIColor(hex: "#553B45"),
            paywallBackground: UIColor(hex: "#35272C"),
            paywallSelectedBackground: UIColor(hex: "#672842"),
            paywallSave: UIColor(hex: "#F19893"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme7: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#FFFBEB"),
            appCard: UIColor(hex: "#FFFDF5"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#FCEEEE"),
            listenTint: UIColor(hex: "#1E1E1E"),
            listenSecondaryTint: UIColor(hex: "#C5B987"),
            separatorColor: UIColor(hex: "#CB926F"),
            homeHeader: UIColor(hex: "#FFF1C2"),
            buttonGradientStart: UIColor(hex: "#3B3934"),
            buttonGradientEnd: UIColor(hex: "#3B3934"),
            paywallIcon: UIColor(hex: "#9A8952"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#9E8E56"),
            paywallBorder: UIColor(hex: "#FFF1C2"),
            paywallBackground: UIColor(hex: "#FEF6DB"),
            paywallSelectedBackground: UIColor(hex: "#FFF1C2"),
            paywallSave: UIColor(hex: "#A5945A"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme8: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#1C1C1B"),
            appCard: UIColor(hex: "#252525"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#3F3924"),
            listenTint: UIColor(hex: "#D6AA19"),
            listenSecondaryTint: UIColor(hex: "#3F3924"),
            separatorColor: UIColor(hex: "#424242"),
            homeHeader: UIColor(hex: "#201C0D"),
            buttonGradientStart: UIColor(hex: "#D6AA19"),
            buttonGradientEnd: UIColor(hex: "#D6AA19"),
            paywallIcon: UIColor(hex: "#8D782D"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#D6AA19"),
            paywallBorder: UIColor(hex: "#5A4D1F"),
            paywallBackground: UIColor(hex: "#3C3416"),
            paywallSelectedBackground: UIColor(hex: "#635317"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme9: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#E1EBFA"),
            appCard: UIColor(hex: "#C0D4F5"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#E1EBFA"),
            listenTint: UIColor(hex: "#224A8A"),
            listenSecondaryTint: UIColor(hex: "#E1EBFA"),
            separatorColor: UIColor(hex: "#CB926F"),
            homeHeader: UIColor(hex: "#C0D4F5"),
            buttonGradientStart: UIColor(hex: "#224A8A"),
            buttonGradientEnd: UIColor(hex: "#224A8A"),
            paywallIcon: UIColor(hex: "#224A8A"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#3271D7"),
            paywallBorder: UIColor(hex: "#9EBEF1"),
            paywallBackground: UIColor(hex: "#C0D4F5"),
            paywallSelectedBackground: UIColor(hex: "#9EBEF1"),
            paywallSave: UIColor(hex: "#3271D7"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme10: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#141B27"),
            appCard: UIColor(hex: "#162235"),
            appPrimaryText: .white,
            appSubtitleBackground: UIColor(hex: "#183057"),
            listenTint: UIColor(hex: "#3F81EA"),
            listenSecondaryTint: UIColor(hex: "#224A8A"),
            separatorColor: UIColor(hex: "#3A3A3A"),
            homeHeader: UIColor(hex: "#3F81EA"),
            buttonGradientStart: UIColor(hex: "#3F81EA"),
            buttonGradientEnd: UIColor(hex: "#3F81EA"),
            paywallIcon: UIColor(hex: "#2A61BA"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#3271D7"),
            paywallBorder: UIColor(hex: "#224A8A"),
            paywallBackground: UIColor(hex: "#15253F"),
            paywallSelectedBackground: UIColor(hex: "#183057"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme11: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#EBDADA"),
            appCard: UIColor(hex: "#F4E4E4"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#EBDADA"),
            listenTint: UIColor(hex: "#BA7070"),
            listenSecondaryTint: UIColor(hex: "#E2B2B2"),
            separatorColor: UIColor(hex: "#CB926F"),
            homeHeader: UIColor(hex: "#FFEFE8"),
            buttonGradientStart: UIColor(hex: "#EF6162"),
            buttonGradientEnd: UIColor(hex: "#EF6162"),
            paywallIcon: UIColor(hex: "#224A8A"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#3271D7"),
            paywallBorder: UIColor(hex: "#9EBEF1"),
            paywallBackground: UIColor(hex: "#C0D4F5"),
            paywallSelectedBackground: UIColor(hex: "#9EBEF1"),
            paywallSave: UIColor(hex: "#3271D7"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme12: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#131026"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#081E40"),
            listenTint: UIColor(hex: "#3F81EA"),
            listenSecondaryTint: UIColor(hex: "#224A8A"),
            separatorColor: UIColor(hex: "#2A4064"),
            homeHeader: UIColor(hex: "#131026"),
            buttonGradientStart: UIColor(hex: "#EF6162"),
            buttonGradientEnd: UIColor(hex: "#EF6162"),
            paywallIcon: UIColor(hex: "#EF6162"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#5A4AC7"),
            paywallBorder: UIColor(hex: "#2E2957"),
            paywallBackground: UIColor(hex: "#131026"),
            paywallSelectedBackground: UIColor(hex: "#261E5F"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme13: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#BFE0E4"),
            appCard: UIColor(hex: "#C9E8EB"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#CEF4F4"),
            listenTint: UIColor(hex: "#00AAAA"),
            listenSecondaryTint: UIColor(hex: "#9AC4CA"),
            separatorColor: UIColor(hex: "#84BEC4"),
            homeHeader: UIColor(hex: "#C9E8EB"),
            buttonGradientStart: UIColor(hex: "#00AAAA"),
            buttonGradientEnd: UIColor(hex: "#00AAAA"),
            paywallIcon: UIColor(hex: "#00AAAA"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#00AAAA"),
            paywallBorder: UIColor(hex: "#D0F0F3"),
            paywallBackground: UIColor(hex: "#C9E8EB"),
            paywallSelectedBackground: UIColor(hex: "#81D7D0"),
            paywallSave: UIColor(hex: "#00AAAA"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme14: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#072020"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#092B2B"),
            listenTint: UIColor(hex: "#00AAAA"),
            listenSecondaryTint: UIColor(hex: "#044242"),
            separatorColor: UIColor(hex: "#2A4064"),
            homeHeader: UIColor(hex: "#072020"),
            buttonGradientStart: UIColor(hex: "#00AAAA"),
            buttonGradientEnd: UIColor(hex: "#00AAAA"),
            paywallIcon: UIColor(hex: "#EF6162"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#00AAAA"),
            paywallBorder: UIColor(hex: "#163A3A"),
            paywallBackground: UIColor(hex: "#072020"),
            paywallSelectedBackground: UIColor(hex: "#1F5656"),
            paywallSave: UIColor(hex: "#34C759"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme15: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#D0D4F9"),
            appCard: UIColor(hex: "#D4D9FF"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#E2E5FF"),
            listenTint: UIColor(hex: "#5248BB"),
            listenSecondaryTint: UIColor(hex: "#979DDB"),
            separatorColor: UIColor(hex: "#84BEC4"),
            homeHeader: UIColor(hex: "#C4BEFF"),
            buttonGradientStart: UIColor(hex: "#5248BB"),
            buttonGradientEnd: UIColor(hex: "#5248BB"),
            paywallIcon: UIColor(hex: "#5248BB"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#5248BB"),
            paywallBorder: UIColor(hex: "#A7A0F0"),
            paywallBackground: UIColor(hex: "#D4D0FF"),
            paywallSelectedBackground: UIColor(hex: "#B6B0FB"),
            paywallSave: UIColor(hex: "#817ACA"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme16: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#272535"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#373644"),
            listenTint: UIColor(hex: "#5248BB"),
            listenSecondaryTint: UIColor(hex: "#373360"),
            separatorColor: UIColor(hex: "#2A4064"),
            homeHeader: UIColor(hex: "#272535"),
            buttonGradientStart: UIColor(hex: "#5248BB"),
            buttonGradientEnd: UIColor(hex: "#5248BB"),
            paywallIcon: UIColor(hex: "#5248BB"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#5248BB"),
            paywallBorder: UIColor(hex: "#3F3A72"),
            paywallBackground: UIColor(hex: "#272535"),
            paywallSelectedBackground: UIColor(hex: "#403C66"),
            paywallSave: UIColor(hex: "#5248BB"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme17: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#F3F2E1"),
            appCard: UIColor(hex: "#E4E2C8"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#D6D1B1"),
            listenTint: UIColor(hex: "#8D8B68"),
            listenSecondaryTint: UIColor(hex: "#B9B79F"),
            separatorColor: UIColor(hex: "#84BEC4"),
            homeHeader: UIColor(hex: "#E4E2C8"),
            buttonGradientStart: UIColor(hex: "#8D8B68"),
            buttonGradientEnd: UIColor(hex: "#8D8B68"),
            paywallIcon: UIColor(hex: "#8D8B68"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#8D8B68"),
            paywallBorder: UIColor(hex: "#CAC680"),
            paywallBackground: UIColor(hex: "#E4E2C8"),
            paywallSelectedBackground: UIColor(hex: "#C9C7AE"),
            paywallSave: UIColor(hex: "#959041"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme18: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#161616"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#23221A"),
            listenTint: UIColor(hex: "#B9B026"),
            listenSecondaryTint: UIColor(hex: "#434121"),
            separatorColor: UIColor(hex: "#2A4064"),
            homeHeader: UIColor(hex: "#1F1D07"),
            buttonGradientStart: UIColor(hex: "#B9B026"),
            buttonGradientEnd: UIColor(hex: "#B9B026"),
            paywallIcon: UIColor(hex: "#777331"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#B9B026"),
            paywallBorder: UIColor(hex: "#464310"),
            paywallBackground: UIColor(hex: "#1F1D07"),
            paywallSelectedBackground: UIColor(hex: "#3E3A0F"),
            paywallSave: UIColor(hex: "#58551F"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme19: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#D6CFC5"),
            appCard: UIColor(hex: "#C2B7A7"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#D6CFC5"),
            listenTint: UIColor(hex: "#4A2628"),
            listenSecondaryTint: UIColor(hex: "#D6CFC5"),
            separatorColor: UIColor(hex: "#84BEC4"),
            homeHeader: UIColor(hex: "#C2B7A7"),
            buttonGradientStart: UIColor(hex: "#4A2628"),
            buttonGradientEnd: UIColor(hex: "#4A2628"),
            paywallIcon: UIColor(hex: "#605A01"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#C2B7A7"),
            paywallBorder: UIColor(hex: "#C1B39F"),
            paywallBackground: UIColor(hex: "#D6CBBC"),
            paywallSelectedBackground: UIColor(hex: "#E7DAC7"),
            paywallSave: UIColor(hex: "#4A2628"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme20: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#161616"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#23221A"),
            listenTint: UIColor(hex: "#AB6D14"),
            listenSecondaryTint: UIColor(hex: "#434121"),
            separatorColor: UIColor(hex: "#2A4064"),
            homeHeader: UIColor(hex: "#30281C"),
            buttonGradientStart: UIColor(hex: "#AB6D14"),
            buttonGradientEnd: UIColor(hex: "#AB6D14"),
            paywallIcon: UIColor(hex: "#777331"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#B9B026"),
            paywallBorder: UIColor(hex: "#464310"),
            paywallBackground: UIColor(hex: "#1F1D07"),
            paywallSelectedBackground: UIColor(hex: "#3E3A0F"),
            paywallSave: UIColor(hex: "#58551F"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme21: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#F7F7F7"),
            appCard: UIColor(hex: "#FCFCFC"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#EDEDED"),
            listenTint: UIColor(hex: "#6A5C55"),
            listenSecondaryTint: UIColor(hex: "#D6CFC5"),
            separatorColor: UIColor(hex: "#84BEC4"),
            homeHeader: UIColor(hex: "#D7D1C9"),
            buttonGradientStart: UIColor(hex: "#6A5C55"),
            buttonGradientEnd: UIColor(hex: "#6A5C55"),
            paywallIcon: UIColor(hex: "#6A5C55"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#C2B7A7"),
            paywallBorder: UIColor(hex: "#C1B39F"),
            paywallBackground: UIColor(hex: "#F2EDE7"),
            paywallSelectedBackground: UIColor(hex: "#D7D1C9"),
            paywallSave: UIColor(hex: "#6A5C55"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme22: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#161616"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#23221A"),
            listenTint: UIColor(hex: "#FFE9C1"),
            listenSecondaryTint: UIColor(hex: "#544D41"),
            separatorColor: UIColor(hex: "#2A4064"),
            homeHeader: UIColor(hex: "#1F1F1F"),
            buttonGradientStart: UIColor(hex: "#FFE9C1"),
            buttonGradientEnd: UIColor(hex: "#FFE9C1"),
            paywallIcon: UIColor(hex: "#F0EEED"),
            paywallClose: UIColor(hex: "#F0EEED"),
            paywallSelectedBorder: UIColor(hex: "#E2A17B"),
            paywallBorder: UIColor(hex: "#4C4B44"),
            paywallBackground: UIColor(hex: "#1F1F1F"),
            paywallSelectedBackground: UIColor(hex: "#4A4542"),
            paywallSave: UIColor(hex: "#B3A197"),
            ctaButton: UIColor(hex: "#000000"),
        ),
        .theme23: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#CFDFDF"),
            appCard: UIColor(hex: "#FCFCFC"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#EDEDED"),
            listenTint: UIColor(hex: "#617472"),
            listenSecondaryTint: UIColor(hex: "#DDE9E8"),
            separatorColor: UIColor(hex: "#84BEC4"),
            homeHeader: UIColor(hex: "#BED2D0"),
            buttonGradientStart: UIColor(hex: "#617472"),
            buttonGradientEnd: UIColor(hex: "#617472"),
            paywallIcon: UIColor(hex: "#6A5C55"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#5F7575"),
            paywallBorder: UIColor(hex: "#AEBCBC"),
            paywallBackground: UIColor(hex: "#BED2D0"),
            paywallSelectedBackground: UIColor(hex: "#93BEBA"),
            paywallSave: UIColor(hex: "#617472"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        .theme24: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#161616"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#23221A"),
            listenTint: UIColor(hex: "#13B3A7"),
            listenSecondaryTint: UIColor(hex: "#315653"),
            separatorColor: UIColor(hex: "#3A3A3A"),
            homeHeader: UIColor(hex: "#151E1E"),
            buttonGradientStart: UIColor(hex: "#13B3A7"),
            buttonGradientEnd: UIColor(hex: "#13B3A7"),
            paywallIcon: UIColor(hex: "#13B3A7"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#13B3A7"),
            paywallBorder: UIColor(hex: "#293332"),
            paywallBackground: UIColor(hex: "#151E1E"),
            paywallSelectedBackground: UIColor(hex: "#3F5B59"),
            paywallSave: UIColor(hex: "#476866"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        
        .theme25: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#000000").withAlphaComponent(0.7),
            appBackground: UIColor(hex: "#F4D1D2"),
            appCard: UIColor(hex: "#F0C2C1"),
            appPrimaryText: UIColor(hex: "#000000"),
            appSubtitleBackground: UIColor(hex: "#F4D1D2"),
            listenTint: UIColor(hex: "#EA4362"),
            listenSecondaryTint: UIColor(hex: "#DDE9E8"),
            separatorColor: UIColor(hex: "#A85A68"),
            homeHeader: UIColor(hex: "#F0C2C1"),
            buttonGradientStart: UIColor(hex: "#EA4362"),
            buttonGradientEnd: UIColor(hex: "#EA4362"),
            paywallIcon: UIColor(hex: "#6A5C55"),
            paywallClose: UIColor(hex: "#646262"),
            paywallSelectedBorder: UIColor(hex: "#B85668"),
            paywallBorder: UIColor(hex: "#CD9E9D"),
            paywallBackground: UIColor(hex: "#F0C2C1"),
            paywallSelectedBackground: UIColor(hex: "#E994A4"),
            paywallSave: UIColor(hex: "#C49190"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        ),
        
        .theme26: AppThemePalette(
            tabbarUnselected: UIColor(hex: "#989898"),
            appBackground: UIColor(hex: "#05040C"),
            appCard: UIColor(hex: "#191718"),
            appPrimaryText: UIColor(hex: "#FFFFFF"),
            appSubtitleBackground: UIColor(hex: "#23221A"),
            listenTint: UIColor(hex: "#EA4362"),
            listenSecondaryTint: UIColor(hex: "#7A454F"),
            separatorColor: UIColor(hex: "#3A3536"),
            homeHeader: UIColor(hex: "#1A1214"),
            buttonGradientStart: UIColor(hex: "#EA4362"),
            buttonGradientEnd: UIColor(hex: "#EA4362"),
            paywallIcon: UIColor(hex: "#EA4362"),
            paywallClose: UIColor(hex: "#999999"),
            paywallSelectedBorder: UIColor(hex: "#EA4362"),
            paywallBorder: UIColor(hex: "#362428"),
            paywallBackground: UIColor(hex: "#1A1214"),
            paywallSelectedBackground: UIColor(hex: "#4D3138"),
            paywallSave: UIColor(hex: "#4D3138"),
            ctaButton: UIColor(hex: "#FFFFFF"),
        )
    ]

    static func apply(target: AppThemeTarget) {
        self.target = target
    }

    static var currentPalette: AppThemePalette {
        palettes[target] ?? fallbackPalette
    }

    static var showWordsInListenVariation: Bool {
        true
    }
}

extension UIColor {
    static var appBackground: UIColor {
        AppTheme.currentPalette.appBackground
    }

    static var appCard: UIColor {
        AppTheme.currentPalette.appCard
    }

    static var appPrimaryText: UIColor {
        AppTheme.currentPalette.appPrimaryText
    }

    static var appSubtitleBackground: UIColor {
        AppTheme.currentPalette.appSubtitleBackground
    }
    
    static var separatorColor: UIColor {
        AppTheme.currentPalette.separatorColor
    }

    static var buttonGradientStart: UIColor {
        AppTheme.currentPalette.buttonGradientStart
    }

    static var buttonGradientEnd: UIColor {
        AppTheme.currentPalette.buttonGradientEnd
    }

    convenience init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let alpha, red, green, blue: UInt64
        switch sanitized.count {
        case 3:
            (alpha, red, green, blue) = (
                255,
                ((value >> 8) & 0xF) * 17,
                ((value >> 4) & 0xF) * 17,
                (value & 0xF) * 17
            )
        case 6:
            (alpha, red, green, blue) = (
                255,
                (value >> 16) & 0xFF,
                (value >> 8) & 0xFF,
                value & 0xFF
            )
        case 8:
            (alpha, red, green, blue) = (
                (value >> 24) & 0xFF,
                (value >> 16) & 0xFF,
                (value >> 8) & 0xFF,
                value & 0xFF
            )
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }
}
