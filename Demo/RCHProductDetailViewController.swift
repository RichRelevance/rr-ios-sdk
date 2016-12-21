//
//  Copyright (c) 2016 Rich Relevance Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit

class RCHProductDetailViewController: UIViewController {

    @IBOutlet weak var cartBarButton: UIBarButtonItem!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    var product: RCHSearchProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor.white
        
        addToCartButton.layer.cornerRadius = 4
        
        brandLabel.text = product?.brand?.uppercased()
        descriptionLabel.text = product?.name
        productImageView.sd_setImage(with: URL(string: (product?.imageURL)!))
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let priceCentsToDollars = (product?.priceCents?.intValue)! / 100 as NSNumber
        priceLabel.text = numberFormatter.string(from: priceCentsToDollars)
    }
    
    @IBAction func addToCartSelected(_ sender: AnyObject) {
        let placement = RCHRequestPlacement(pageType: .addToCart, name: "prod1")
        let builder = RCHSDK.builderForRecs(with: placement)
        RCHSDK.defaultClient().sendRequest(builder.build(), success: { (result) in
            self.cartBarButton.image = UIImage(named:"icn-cart-item.pdf")
            self.addToCartButton.setTitle("Added to Cart", for: .normal)
        }) { (responseObject, error) in
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            print(error)
        }
    }
}
