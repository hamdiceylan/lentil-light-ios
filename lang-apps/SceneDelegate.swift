//
//  SceneDelegate.swift
//  lang-apps
//
//  Created by Atech on 10.02.2026.
//

import UIKit
import AppTrackingTransparency

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        if OnboardingViewController.hasSeen {
            showPostOnboardingFlow(animated: false)
            window.makeKeyAndVisible()
            return
        }

        let onboardingViewController = OnboardingViewController { [weak self] in
            self?.showPostOnboardingFlow(animated: true)
        }
        window.rootViewController = onboardingViewController
        window.makeKeyAndVisible()
    }

    private func showPostOnboardingFlow(animated: Bool) {
        if UserManager.shared.premium {
            showMainApp(animated: animated)
        } else {
            showRootPaywall(animated: animated)
        }
    }

    private func showRootPaywall(animated: Bool) {
        let paywallViewController = PaywallViewController()
        paywallViewController.isRoot = true

        guard let window else { return }
        if animated {
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
                window.rootViewController = paywallViewController
            }
        } else {
            window.rootViewController = paywallViewController
        }
    }

    private func showMainApp(animated: Bool) {
        let rootViewController = UINavigationController(rootViewController: ViewController())

        guard let window else { return }
        if animated {
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {
                window.rootViewController = rootViewController
            } completion: { _ in
                Self.requestTrackingPermissionIfNeeded()
            }
        } else {
            window.rootViewController = rootViewController
            Self.requestTrackingPermissionIfNeeded()
        }
    }

    private static func requestTrackingPermissionIfNeeded() {
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
