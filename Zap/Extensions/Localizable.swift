//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Foundation

protocol Localizable {
    var localized: String { get }
}

extension UILabel {
    func setLocalizable(_ localizable: Localizable) {
        text = localizable.localized
    }
}