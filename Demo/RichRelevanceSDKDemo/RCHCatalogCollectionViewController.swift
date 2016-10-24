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

private let reuseIdentifier = "productCell"

class RCHCatalogCollectionViewController: UICollectionViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var productArray: [RCHRecommendedProduct] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(UINib(nibName: "RCHProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        navigationItem.title = UserDefaults.standard.string(forKey: kRCHUserDefaultKeyClientName)
        
        spinner.startAnimating()
        spinner.isHidden = false
        let strategyBuilder: RCHStrategyRecsBuilder = RCHSDK.builderForRecs(with: .siteWideBestSellers)
        
        RCHSDK.defaultClient().sendRequest(strategyBuilder.build(), success: { (responseObject) in
            
            guard let strategyResponse = responseObject as? RCHStrategyResult else {
                print("Result Error")
                return
            }
            
            guard let productArray = strategyResponse.recommendedProducts else {
                print("Recommended Products Error")
                return
            }
            self.productArray = productArray
            
            self.collectionView?.reloadData()
            self.spinner.stopAnimating()
        }) { (responseObject, error) in
            self.spinner.stopAnimating()
            print(error)
        }
    }
    
    @IBAction func menuSelected(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RCHProductCollectionViewCell
        let product = productArray[indexPath.row]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let priceCentsToDollars = (product.priceCents?.intValue)! / 100 as NSNumber
        
        cell.priceLabel.text = numberFormatter.string(from: priceCentsToDollars)
        cell.productImage.sd_setImage(with: URL(string: product.imageURL!))
        cell.brandLabel.text = product.brand?.uppercased()
        cell.titleLabel.text = product.name
        
        return cell
    }
}
