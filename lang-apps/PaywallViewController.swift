//
//  PaywallViewController.swift
//  PicCollageApp
//
//  Created by Atech on 15.12.2025.
//  Copyright © 2025 Appus Studio LP. All rights reserved.
//


import UIKit
import SwiftUI
import AppTrackingTransparency

class PaywallViewController: UIViewController {
    var isRoot: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppTheme.currentPalette.appBackground
        
        let purchaseView = PurchaseView { [weak self] in
            self?.handleDismiss()
        }
        
        let hostingController = UIHostingController(rootView: purchaseView)

        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Auto-close if already premium
        if UserManager.shared.premium {
            DispatchQueue.main.async { [weak self] in
                self?.handleDismiss()
            }
        }
    }
    
    private func handleDismiss() {
        if isRoot {
            navigateToMainApp()
        } else {
            dismiss(animated: true)
        }
    }
    
    private func navigateToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        let mainViewController = UINavigationController(rootViewController: ViewController())
        let shouldRequestTracking = isRoot

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = mainViewController
        } completion: { _ in
            guard shouldRequestTracking else { return }
            Self.requestTrackingPermissionIfNeeded()
        }
        window.makeKeyAndVisible()
    }

    private static func requestTrackingPermissionIfNeeded() {
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}
