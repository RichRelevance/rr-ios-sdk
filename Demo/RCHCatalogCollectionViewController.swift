//
//  RCHCatalogCollectionViewController.swift
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 9/20/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "productCell"

class RCHCatalogCollectionViewController: UICollectionViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var productArray: [RCHRecommendedProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()

       collectionView!.register(UINib(nibName: "RCHProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        
        // TODO: Set title to selected client
        //self.title = ""
        
        spinner.startAnimating()
        spinner.isHidden = false
        let strategyBuilder: RCHStrategyRecsBuilder = RCHSDK.builderForRecs(with: .siteWideBestSellers)
        
        RCHSDK.defaultClient().sendRequest(strategyBuilder.build(), success: { (responseObject) in
            
            let strategyResponse: RCHStrategyResult = responseObject as! RCHStrategyResult
            self.productArray = strategyResponse.recommendedProducts!
            
            self.collectionView?.reloadData()
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
            
        }) { (responseObject, error) in
            print(error)
        }
    }
    
    @IBAction func menuSelected(sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        self.present(storyboard.instantiateViewController(withIdentifier: "rootMenu"), animated: true, completion: nil)
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
        let product: RCHRecommendedProduct = productArray[indexPath.row]

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.string(from: product.priceCents!)
        
        cell.productImage.sd_setImage(with: URL(string: product.imageURL!))
        cell.brandLabel.text = product.brand?.uppercased()
        cell.titleLabel.text = product.name
        
        return cell
    }
}
