//
//  Zap
//
//  Created by Otto Suess on 18.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

final class DetailTableViewCell: UITableViewCell {
    struct Info {
        let title: String
        let data: String
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dataLabel: UILabel!
    
    var info: Info? {
        didSet {
            titleLabel.text = info?.title.appending(":")
            dataLabel.text = info?.data
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        DetailCellType.dataFontStyle.apply(to: dataLabel)
        DetailCellType.titleFontStyle.apply(to: titleLabel)
        backgroundColor = .clear
    }
}
