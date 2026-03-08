//
//  MainTabBarController.swift
//  lang-apps
//
//  Created by Codex on 17.02.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
        configureTabBarAppearance()
    }

    private func configureTabs() {
        let lessons = makeNavigationController(
            rootViewController: ViewController(),
            title: "Lessons",
            image: "tabbar-lessons"
        )
        let flashcards = makeNavigationController(
            rootViewController: FlashcardListViewController(),
            title: "Flashcards",
            image: "tabbar-flashcards"
        )
        let favorites = makeNavigationController(
            rootViewController: FavoritesViewController(),
            title: "Favorites",
            image: "tabbar-favorites"
        )
        let settings = makeNavigationController(
            rootViewController: MenuViewController(showCloseButton: false),
            title: "Settings",
            image: "tabbar-settings"
        )

        viewControllers = [lessons, flashcards, favorites, settings]
        selectedIndex = 0
    }

    private func makeNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: String
    ) -> UINavigationController {
        rootViewController.title = title

        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = false

        let item = UITabBarItem(
            title: title,
            image: UIImage(named: image)?.withTintColor(AppTheme.currentPalette.tabbarUnselected),
            selectedImage: UIImage(named: image)?.withTintColor(AppTheme.currentPalette.appPrimaryText)
        )
        navigationController.tabBarItem = item

        return navigationController
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: AppTheme.currentPalette.tabbarUnselected
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppTheme.currentPalette.appPrimaryText
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = AppTheme.currentPalette.appPrimaryText
        tabBar.unselectedItemTintColor = AppTheme.currentPalette.tabbarUnselected
    }
}
