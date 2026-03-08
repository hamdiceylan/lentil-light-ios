//
//  AdMobManager.swift
//  lang-apps
//

import UIKit
import GoogleMobileAds

final class AdMobManager: NSObject {
    static let shared = AdMobManager()

    private override init() {}

    private enum TestIDs {
        static let banner = "ca-app-pub-3940256099942544/2435281174"
        static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    }

    private var didStartSDK = false 
    private var interstitialAd: InterstitialAd?
    private var interstitialDismissAction: (() -> Void)?
    private var bannersByContainer: [ObjectIdentifier: BannerView] = [:]

    func start() {
        guard !didStartSDK else { return }
        didStartSDK = true
        MobileAds.shared.start(completionHandler: nil)
        preloadInterstitial()
    }

    func preloadInterstitial() {
        start()
        InterstitialAd.load(with: TestIDs.interstitial, request: Request()) { [weak self] ad, _ in
            guard let self else { return }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    func showInterstitialIfAvailable(from viewController: UIViewController, onDismiss: @escaping () -> Void) {
        start()
        guard let ad = interstitialAd else {
            onDismiss()
            preloadInterstitial()
            return
        }

        interstitialDismissAction = onDismiss
        ad.present(from: viewController)
    }

    @discardableResult
    func attachTestBanner(to containerView: UIView, rootViewController: UIViewController) -> CGFloat {
        start()
        let width = containerView.bounds.width
        guard width > 0 else { return 0 }

        let key = ObjectIdentifier(containerView)
        let bannerSize = AdSizeBanner
        let bannerView: BannerView

        if let existing = bannersByContainer[key] {
            bannerView = existing
            bannerView.adSize = bannerSize
        } else {
            let created = BannerView(adSize: bannerSize)
            created.translatesAutoresizingMaskIntoConstraints = false
            created.adUnitID = TestIDs.banner
            created.rootViewController = rootViewController
            containerView.addSubview(created)
            NSLayoutConstraint.activate([
                created.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                created.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            bannersByContainer[key] = created
            bannerView = created
        }

        bannerView.rootViewController = rootViewController
        bannerView.load(Request())
        return bannerSize.size.height
    }
}

extension AdMobManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        let action = interstitialDismissAction
        interstitialDismissAction = nil
        action?()
        preloadInterstitial()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitialAd = nil
        let action = interstitialDismissAction
        interstitialDismissAction = nil
        action?()
        preloadInterstitial()
    }
}
