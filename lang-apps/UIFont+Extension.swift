//
//  UIFont+Extension.swift
//  lang-apps
//
//  Created by Atech on 10.02.2026.
//

import Foundation
import UIKit
import SwiftUI

enum FontType {
    case light
    case regular
    case medium
    case semiBold
    case bold
    case black
}

extension UIFont {
    
    static func sfPro(_ type: FontType, size: CGFloat) -> UIFont? {
        switch type {
        case .light:
            return UIFont(name: "SFProDisplay-Light", size: size)
        case .regular:
            return UIFont(name: "SFProDisplay-Regular", size: size)
        case .medium:
            return UIFont(name: "SFProDisplay-Medium", size: size)
        case .semiBold:
            return UIFont(name: "SFProDisplay-Semibold", size: size)
        case .bold:
            return UIFont(name: "SFProDisplay-Bold", size: size)
        case .black:
            return UIFont(name: "SFProDisplay-Heavy", size: size)
        }
    }
    
}

extension Font {
    static func sfPro(_ type: FontType, size: CGFloat) -> Font {
        // UIKit UIFont → SwiftUI Font dönüştürme
        if let uiFont = UIFont.sfPro(type, size: size) {
            return Font(uiFont)
        } else {
            // Fallback
            return .system(size: size)
        }
    }
}
