//
//  RCHProductCollectionViewCell.swift
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 9/20/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

import UIKit

class RCHProductCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
