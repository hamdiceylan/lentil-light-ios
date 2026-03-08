//
//  PaywallView.swift
//  PicCollage
//
//  Created by Atech on 15.12.2025.
//

import SwiftUI
import RevenueCat
import Combine

struct PurchaseView: View {
    
    @StateObject var purchaseModel: PurchaseModel = PurchaseModel()
    
    @State private var shakeDegrees = 0.0
    @State private var shakeZoom = 0.9
    @State private var showCloseButton = false
    @State private var progress: CGFloat = 0.0
    
    var onDismiss: (() -> Void)?
    
    @State var showNoneRestoredAlert: Bool = false
    @State private var showTermsActionSheet: Bool = false
    
    @State private var freeTrial: Bool = false
    @State private var selectedProductId: String = ""
    @State private var isUserSelectingProduct: Bool = false
    
    let iconColor: Color = .init(AppTheme.currentPalette.paywallIcon)
    let buttonColor: Color = .init(AppTheme.currentPalette.listenTint)
    let selectedBorderColor: Color = .init(AppTheme.currentPalette.paywallSelectedBorder)
    let borderColor: Color = .init(AppTheme.currentPalette.paywallBorder)
    
    private let onboardingButtonHorizontalInset: CGFloat = 34
    private let onboardingButtonHeight: CGFloat = 65
    
    private let allowCloseAfter: CGFloat = 5.0 //time in seconds until close is allows
    
    var hasCooldown: Bool = true
    
    let placeholderProductDetails: [PurchaseProductDetails] = [
        PurchaseProductDetails(price: "-", productId: "demo", duration: "week", durationPlanName: "week", hasTrial: false),
        PurchaseProductDetails(price: "-", productId: "demo", duration: "week", durationPlanName: "week", hasTrial: false)
    ]
    
    var callToActionText: String {
        if let selectedProductTrial = purchaseModel.productDetails.first(where: {$0.productId == selectedProductId})?.hasTrial {
            if selectedProductTrial {
                return "Try for Free"
            }
            else {
                return "Unlock Now"
            }
        }
        else {
            return "Unlock Now"
        }
    }
    
    var calculateFullPrice: Double? {
        if let weeklyPriceString = purchaseModel.productDetails.first(where: { $0.duration == "week" })?.price {
            
            // Remove non-numeric characters except ',' and '.'
            let cleanPriceString = weeklyPriceString
                .replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
                .replacingOccurrences(of: ",", with: ".") // Convert ',' to '.'
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: "en_US")
            
            if let number = formatter.number(from: cleanPriceString) {
                let weeklyPriceDouble = number.doubleValue
                return weeklyPriceDouble * 52
            }
        }
        
        return nil
    }
    
    var selectedProductDescription: String {
        guard let selectedProduct = purchaseModel.productDetails.first(where: { $0.productId == selectedProductId }) else {
            return ""
        }
        
        if selectedProduct.hasTrial {
            // 3 days trial, then $4.99 per week format
            return "3 days trial, then \(selectedProduct.price) per \(selectedProduct.duration)"
        } else if selectedProduct.duration == "year" {
            // $24.99 per year format
            return "\(selectedProduct.price) per \(selectedProduct.duration)"
        } else {
            return "\(selectedProduct.price) \(selectedProduct.duration)"
        }
    }
    
    var calculatePercentageSaved: Int {
        if let calculateFullPrice = calculateFullPrice, let yearlyPriceString = purchaseModel.productDetails.first(where: {$0.duration == "year"})?.price {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            
            if let number = formatter.number(from: yearlyPriceString) {
                let yearlyPriceDouble = number.doubleValue
                
                let saved = Int(100 - ((yearlyPriceDouble / calculateFullPrice) * 100))
                
                if saved > 0 {
                    return saved
                }
                
            }
            
        }
        return 90
    }
    
    var body: some View {
        ZStack (alignment: .top) {
            Color(AppTheme.currentPalette.appBackground)
                .ignoresSafeArea()
            
            HStack {
                Spacer()
                
                Image(systemName: "multiply")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .foregroundStyle(Color(AppTheme.currentPalette.paywallClose))
                    .opacity(0.3)
                    .onTapGesture {
                        onDismiss?()
                    }
            }
            .padding(.top)
            .padding(.top, 5)
            .padding(.horizontal)
            .zIndex(999)
            
            
            VStack (spacing: 0) {
                
                ZStack {
                    Image("paywall_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIDevice.responsiveSize(small: 70, medium: 84, large: 96))
                        .scaleEffect(shakeZoom)
                        .rotationEffect(.degrees(shakeDegrees))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                startShaking()
                            }
                        }
                }
                .padding(.bottom, UIDevice.responsiveSize(small: 43, medium: 46, large: 48))
                .padding(.top, UIDevice.responsiveSize(small: 28, medium: 38, large: 48))
                
                VStack {
                    Text("Get Premium Features")
                        .font(.sfPro(.semiBold, size: UIDevice.responsiveSize(small: 25, medium: 28, large: 30)))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack (alignment: .leading , spacing: UIDevice.responsiveSize(small: 14, medium: 16, large: 20)) {
                        PurchaseFeatureView(title: "Unlimited Audio Listening", icon: "unlimited-listening", color: iconColor)
                        PurchaseFeatureView(title: "Unlimited Topics", icon: "unlimited-topics", color: iconColor)
                        PurchaseFeatureView(title: "No Ads", icon: "remove-ads", color: iconColor)
                    }
                    .padding(.top, UIDevice.responsiveSize(small: 14, medium: 16, large: 18))
                    .padding(.horizontal, UIDevice.responsiveSize(small: 0, medium: 10, large: 14))
                }
                
                Spacer()
                // Product-CTA
                VStack (spacing: UIDevice.responsiveSize(small: 28, medium: 38, large: 39)) {
                    // product-product
                    VStack (spacing: UIDevice.responsiveSize(small: 10, medium: 12, large: 15)) {
                        
                        let productDetails = purchaseModel.isFetchingProducts ? placeholderProductDetails : purchaseModel.productDetails
                        
                        ForEach(productDetails) { productDetails in
                            
                            Button(action: {
                                self.isUserSelectingProduct = true
                                self.freeTrial = productDetails.hasTrial
                                
                                withAnimation {
                                    selectedProductId = productDetails.productId
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.isUserSelectingProduct = false // Reset after short delay
                                }
                            }) {
                                VStack {
                                    HStack {
                                        // title-price
                                        VStack(alignment: .leading, spacing: UIDevice.responsiveSize(small: 4, medium: 6, large: 8)) {
                                            Text(productDetails.durationPlanName)
                                                .font(.system(size: UIDevice.responsiveSize(small: 14, medium: 15, large: 17), weight: .semibold))
                                                .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText))
                                            if productDetails.hasTrial {
                                                Text("3-days trial,then "+productDetails.price+" per "+productDetails.duration)
                                                    .font(.system(size: UIDevice.responsiveSize(small: 14, medium: 15, large: 17), weight: .regular))
                                                    .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText))
                                            }
                                            else {
                                                HStack (spacing: 0) {
                                                    if let calculateFullPrice = calculateFullPrice, //round down
                                                       let calculateFullPriceLocalCurrency = toLocalCurrencyString(calculateFullPrice, currencyCode: productDetails.currencySymbol),
                                                       calculateFullPrice > 0
                                                    {
                                                        //shows the full price based on weekly calculaation
                                                        if productDetails.duration == "year" {
                                                            Text("\(calculateFullPriceLocalCurrency) ")
                                                                .strikethrough()
                                                                .opacity(0.4)
                                                                .font(.system(size: UIDevice.responsiveSize(small: 14, medium: 15, large: 17), weight: .regular))
                                                                .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText.withAlphaComponent(0.8)))
                                                        }
                                                        
                                                    }
                                                    if productDetails.duration == "lifetime" {
                                                        Text(productDetails.price + " one time")
                                                            .font(.system(size: UIDevice.responsiveSize(small: 14, medium: 15, large: 17), weight: .regular))
                                                            .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText))
                                                    } else {
                                                        Text(productDetails.price + " per " + productDetails.duration)
                                                            .lineLimit(1)
                                                            .font(.system(size: UIDevice.responsiveSize(small: 14, medium: 15, large: 17), weight: .regular))
                                                            .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText))
                                                    }
                                                }
                                                .opacity(0.8)
                                            }
                                        }
                                        Spacer()
                                        if productDetails.hasTrial {
                                            //removed: Some apps were being rejected with this caption present:
//                                            Text("FREE")
//                                                .font(.system(size: 18, weight: .bold))
                                        }
                                        else {
                                            if productDetails.duration == "year" {
                                                VStack {
                                                    Text("SAVE \(calculatePercentageSaved)%")
                                                        .font(.caption.bold())
                                                        .foregroundColor(.white)
                                                        .padding(8)
                                                }
                                                .background(Color(AppTheme.currentPalette.paywallSave))
                                                .cornerRadius(4)
                                            }
                                        }
                                        
                                        ZStack {
                                            Image(systemName: (selectedProductId == productDetails.productId) ? "circle.fill" : "circle")
                                                .foregroundColor((selectedProductId == productDetails.productId) ? selectedBorderColor : borderColor)
                                            
                                            if selectedProductId == productDetails.productId {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(Color.white)
                                                    .scaleEffect(0.7)
                                            }
                                        }
                                        .font(.title3.bold())
                                        
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                }
//                                .background(Color(.red))
                                .cornerRadius(6)
                                
                                .overlay(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke((selectedProductId == productDetails.productId) ? selectedBorderColor : borderColor, lineWidth: 1) // Border color and width
                                    }
                                )
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .foregroundColor((selectedProductId == productDetails.productId) ? Color(AppTheme.currentPalette.paywallSelectedBackground) : Color(AppTheme.currentPalette.paywallBackground))
                                    }
                                )
                            }
                            .accentColor(Color.primary)
                            
                        }
                        
//                        HStack {
//                            Toggle(isOn: $freeTrial) {
//                                Text("Free Trial Enabled")
//                                    .font(.headline.bold())
//                            }
//                            .padding(.horizontal)
//                            .padding(.vertical, 10)
//                            .onChange(of: freeTrial) { newFreeTrial in
//                                if !isUserSelectingProduct { // Prevent override when user is selecting
//                                    if !newFreeTrial, let lifetimeId = self.purchaseModel.productDetails.first(where: { $0.duration == "year" })?.productId {
//                                        withAnimation {
//                                            self.selectedProductId = lifetimeId
//                                        }
//                                    } else if newFreeTrial, let weeklyId = self.purchaseModel.productDetails.first(where: { $0.duration == "week" })?.productId {
//                                        withAnimation {
//                                            self.selectedProductId = weeklyId
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .background(Color(UIColor.paywallTrialContainer))
//                        .cornerRadius(6)
                        
                    }
                    .opacity(purchaseModel.isFetchingProducts ? 0 : 1)
                    .padding(.horizontal, UIDevice.responsiveSize(small: 10, medium: 15, large: 19))
                    
                    VStack (spacing: 25) {
                        
                        ZStack (alignment: .center) {
                            
                            //if purchasedModel.isPurchasing {
                            ProgressView()
                                .opacity(purchaseModel.isPurchasing ? 1 : 0)
                            
                            VStack(spacing: 8) {
                                Text(selectedProductDescription)
                                    .foregroundStyle(Color(.clear))
                                    .font(.sfPro(.regular, size: 12))
                                
                                Button(action: {
                                    //productManager.purchaseProduct()
                                    if !purchaseModel.isPurchasing {
                                        purchaseModel.purchaseSubscription(productId: self.selectedProductId)
                                    }
                                }) {
                                    Text(callToActionText)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: onboardingButtonHeight)
                                        .foregroundColor(Color(AppTheme.currentPalette.ctaButton))
                                        .font(.sfPro(.medium, size: 24))
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(UIColor.buttonGradientStart), Color(UIColor.buttonGradientEnd)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .opacity(purchaseModel.isPurchasing ? 0 : 1)
                                .padding(.bottom, 4)
                            }
                        }
                        .padding(.horizontal, max(CGFloat.zero, onboardingButtonHorizontalInset - 16))
                    }
                    .opacity(purchaseModel.isFetchingProducts ? 0 : 1)
                }
                .padding(.bottom, UIDevice.responsiveSize(small: 10, medium: 15, large: 20))
                .id("view-\(purchaseModel.isFetchingProducts)")
                .background {
                    if purchaseModel.isFetchingProducts {
                        ProgressView()
                    }
                }
                
                VStack (spacing: 5) {
                    
                    HStack (spacing: 10) {
                        
                        Button("Restore") {
                            purchaseModel.restorePurchases()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                if !purchaseModel.isSubscribed {
                                    showNoneRestoredAlert = true
                                }
                            }
                        }
                        .alert(isPresented: $showNoneRestoredAlert) {
                            Alert(title: Text("Restore Purchases"), message: Text("No purchases restored"), dismissButton: .default(Text("OK")))
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray), alignment: .bottom
                        )
                        .font(.footnote)
                        
                        
                        Button("Terms of Use & Privacy Policy") {
                            showTermsActionSheet = true
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray), alignment: .bottom
                        )
                        .actionSheet(isPresented: $showTermsActionSheet) {
                            ActionSheet(title: Text("View Terms & Conditions"), message: nil,
                                        buttons: [
                                            .default(Text("Terms of Use"), action: {
                                                if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }),
                                            .default(Text("Privacy Policy"), action: {
                                                if let url = URL(string: "https://www.myapp.page/privacy-policy") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }),
                                            .cancel()
                                        ])
                        }
                        .font(.footnote)
                        
                        
                    }
                    //.font(.headline)
                    .padding(.bottom, 5)
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            selectedProductId = purchaseModel.productDetails.first(where: { $0.duration == "year" })?.productId ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeIn(duration: allowCloseAfter)) {
                    self.progress = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + allowCloseAfter) {
                    withAnimation {
                        showCloseButton = true
                    }
                }
            }
        }
        .onChange(of: purchaseModel.isSubscribed) { isSubscribed in
            if(isSubscribed) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onDismiss?()
                }
            }
        }
        .onAppear {
            if(purchaseModel.isSubscribed) {
                onDismiss?()
            }
        }
    }
    
    private func startShaking() {
        let totalDuration = 0.7 // Total duration of the shake animation
        let numberOfShakes = 3 // Total number of shakes
        let initialAngle: Double = 10 // Initial rotation angle
        
        withAnimation(.easeInOut(duration: totalDuration / 2)) {
            self.shakeZoom = 0.95
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration / 2) {
                withAnimation(.easeInOut(duration: totalDuration / 2)) {
                    self.shakeZoom = 0.9
                }
            }
        }
        
        for i in 0..<numberOfShakes {
            let delay = (totalDuration / Double(numberOfShakes)) * Double(i)
            let angle = initialAngle - (initialAngle / Double(numberOfShakes)) * Double(i)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeInOut(duration: totalDuration / Double(numberOfShakes * 2))) {
                    self.shakeDegrees = angle
                }
                withAnimation(Animation.easeInOut(duration: totalDuration / Double(numberOfShakes * 2)).delay(totalDuration / Double(numberOfShakes * 2))) {
                    self.shakeDegrees = -angle
                }
            }
        }
        
        // Stop the shaking and reset to 0
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            withAnimation {
                self.shakeDegrees = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                startShaking()
            }
        }
    }
    
    
    struct PurchaseFeatureView: View {
        
        let title: String
        let icon: String
        let color: Color
        
        var body: some View {
            HStack(alignment: .center, spacing: 8) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24, alignment: .center)
                    .clipped()
                    .foregroundColor(color)
                Text(title)
                    .font(.sfPro(.medium, size: UIDevice.responsiveSize(small: 16, medium: 17, large: 19)))
                    .foregroundStyle(Color(AppTheme.currentPalette.appPrimaryText))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    func toLocalCurrencyString(_ value: Double, currencyCode: String) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencyCode
        return formatter.string(from: NSNumber(value: value))
    }
}

//#Preview {
//    PurchaseView(isPresented: .constant(true))
//}

class PurchaseModel: ObservableObject {
    
    @Published var productIds: [String]
    @Published var productDetails: [PurchaseProductDetails] = []
    
    @Published var isSubscribed: Bool = false {
        didSet {
            UserManager.shared.premium = isSubscribed
        }
    }
    @Published var isPurchasing: Bool = false
    @Published var isFetchingProducts: Bool = false
    
    init() {
        let weeklyId = TargetManager.current.weeklyProductId
        let yearlyId = TargetManager.current.yearlyProductId
        let lifetimeId = TargetManager.current.lifetimeProductId
        //initialise your productids and product details
        self.productIds = [weeklyId, yearlyId, lifetimeId]
        self.productDetails = [
            PurchaseProductDetails(price: "$", productId: weeklyId, duration: "week", durationPlanName: "Weekly Plan", hasTrial: false),
            PurchaseProductDetails(price: "$", productId: yearlyId, duration: "year", durationPlanName: "Yearly Plan", hasTrial: false),
            PurchaseProductDetails(price: "$", productId: lifetimeId, duration: "lifetime", durationPlanName: "Lifetime", hasTrial: false),
        ]
        
        // Initialize from UserManager
        self.isSubscribed = UserManager.shared.premium
        
        fetchProducts()
        checkSubscriptionStatus()
    }
    
    func purchaseSubscription(productId: String) {
        isPurchasing = true
        
        // Fetch offerings to get the StoreProduct
        Purchases.shared.getOfferings { offerings, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching offerings: \(error.localizedDescription)")
                    self.isPurchasing = false
                    return
                }
                
                guard let offerings = offerings,
                      let currentOffering = offerings.current,
                      let package = currentOffering.availablePackages.first(where: { $0.storeProduct.productIdentifier == productId }) else {
                    print("Product not found in offerings.")
                    self.isPurchasing = false
                    return
                }
                
                // Initiate the purchase
                Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
                    DispatchQueue.main.async {
                        self.isPurchasing = false

                        if userCancelled == true {
                            print("Purchase cancelled by user")
                            return
                        }
                        if let error = error {
                            print("Purchase failed: \(error.localizedDescription)")
                            return
                        }
                        guard let info = customerInfo else {
                            print("Purchase finished but no CustomerInfo.")
                            return
                        }

                        // Entitlement Check
                        let premiumActive = info.entitlements["Premium"]?.isActive == true

                        // Update Premium Status
                        self.isSubscribed = premiumActive
                        NotificationCenter.default.post(name: .didGoPremiumNotification, object: nil)
                    }
                }
            }
        }
    }
    
    func restorePurchases() {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                print("Restore failed: \(error.localizedDescription)")
                return
            }
            guard let info = customerInfo else {
                print("No purchases to restore")
                return
            }

            let premiumActive = info.entitlements["Premium"]?.isActive == true

            DispatchQueue.main.async {
                self.isSubscribed = premiumActive
                NotificationCenter.default.post(name: .didGoPremiumNotification, object: nil)

                if premiumActive {
                    print("Restore successful! Entitlement active.")
                } else {
                    print("No purchases to restore")
                }
            }
        }
    }
    
    private func fetchProducts() {
        isFetchingProducts = true
        Purchases.shared.getOfferings { offerings, error in
            DispatchQueue.main.async {
                self.isFetchingProducts = false
                if let error = error {
                    print("Error fetching products: \(error.localizedDescription)")
                } else if let offerings = offerings, let currentOffering = offerings.current {
                    // Update only the price of existing products
                    for package in currentOffering.availablePackages {
                        if let index = self.productDetails.firstIndex(where: { $0.productId == package.storeProduct.productIdentifier }) {
                            self.productDetails[index].price = package.storeProduct.localizedPriceString
                            self.productDetails[index].productId = package.storeProduct.productIdentifier
                            self.productDetails[index].currencySymbol = package.storeProduct.priceFormatter?.currencySymbol ?? "$"
                        }
                    }
                }
            }
        }
    }
    
    private func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                print("RC getCustomerInfo error: \(error.localizedDescription)")
            }
            guard let info = customerInfo else { return }

            // Entitlement Check
            let premiumActive = info.entitlements["Premium"]?.isActive == true
            DispatchQueue.main.async {
                self.isSubscribed = premiumActive
            }
        }
    }
}

class PurchaseProductDetails: ObservableObject, Identifiable {
    let id: UUID
    
    @Published var price: String
    @Published var productId: String
    @Published var duration: String
    @Published var durationPlanName: String
    @Published var hasTrial: Bool
    @Published var currencySymbol: String
    
    init(price: String = "", productId: String = "", duration: String = "", durationPlanName: String = "", hasTrial: Bool = false, currencySymbol: String = "") {
        self.id = UUID()
        self.price = price
        self.productId = productId
        self.duration = duration
        self.durationPlanName = durationPlanName
        self.hasTrial = hasTrial
        self.currencySymbol = currencySymbol
    }
    
}

extension UIDevice {
    enum DeviceSizeCategory {
        case small     // e.g. iPhone SE
        case medium    // e.g. iPhone 16 / 16 Pro
        case large     // e.g. iPhone 16 Pro Max / Plus
    }
    
    static var sizeCategory: DeviceSizeCategory {
        let height = UIScreen.main.bounds.height
        
        switch height {
        case ..<700:
            return .small
        case 700..<900:
            return .medium
        default:
            return .large
        }
    }
    
    static func responsiveSize(small: CGFloat, medium: CGFloat, large: CGFloat) -> CGFloat {
            let adjustedLarge = UIDevice.current.userInterfaceIdiom == .pad ? large * 1.1 : large
            
            switch sizeCategory {
            case .small: return small
            case .medium: return medium
            case .large: return adjustedLarge
            }
        }
}

extension Notification.Name {
    static let didGoPremiumNotification =  Notification.Name(rawValue: "DidGoPremiumNotification")
}

extension Color {
    
    /// Creates a Color from a hex string (e.g., "#FF5733" or "FF5733")
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue: Double
        switch hex.count {
        case 3: // RGB (12-bit)
            (red, green, blue) = (
                Double((int >> 8) * 17) / 255.0,
                Double((int >> 4 & 0xF) * 17) / 255.0,
                Double((int & 0xF) * 17) / 255.0
            )
        case 6: // RRGGBB (24-bit)
            (red, green, blue) = (
                Double((int >> 16) & 0xFF) / 255.0,
                Double((int >> 8) & 0xFF) / 255.0,
                Double(int & 0xFF) / 255.0
            )
        case 8: // RRGGBBAA (32-bit)
            (red, green, blue) = (
                Double((int >> 24) & 0xFF) / 255.0,
                Double((int >> 16) & 0xFF) / 255.0,
                Double((int >> 8) & 0xFF) / 255.0
            )
            let alpha = Double(int & 0xFF) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: alpha)
            return
        default:
            (red, green, blue) = (0, 0, 0)
        }
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
