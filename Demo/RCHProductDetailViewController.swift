//
//  RCHProductDetailViewController.swift
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 10/4/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

import UIKit

class RCHProductDetailViewController: UIViewController {

    @IBOutlet weak var cartBarButton: UIBarButtonItem!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    var product: RCHRecommendedProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor.white
        
        brandLabel.text = product?.brand?.uppercased()
        descriptionLabel.text = product?.name
        productImageView.sd_setImage(with: URL(string: (product?.imageURL)!))
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let priceCentsToDollars = (product?.priceCents?.intValue)! / 100 as NSNumber
        priceLabel.text = numberFormatter.string(from: priceCentsToDollars)
    }
    
    @IBAction func addToCartSelected(_ sender: AnyObject) {
        cartBarButton.image = UIImage(named:"icn-cart-item.pdf")
        addToCartButton.setTitle("Added to Cart", for: .normal)
    }
}
