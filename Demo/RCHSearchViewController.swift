//
//  RCHSearchViewController.swift
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "productCell"

class RCHSearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchProductsView: UIView!
    @IBOutlet weak var searchResultsCollectionView: UICollectionView!
    @IBOutlet weak var searchProductsLabel: UILabel!
    @IBOutlet weak var searchProductsImageView: UIImageView!
    
    var productArray: [RCHRecommendedProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchResultsCollectionView.isHidden = true
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
        
        searchResultsCollectionView!.register(UINib(nibName: "RCHProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }

    func searchForProducts(withTerm: String) {
        
        // TODO: Replace with search call when ready
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
            
            if self.productArray.count == 0 {
                self.showNoResults()
            } else {
                self.searchResultsCollectionView.isHidden = false
                self.searchResultsCollectionView?.reloadData()

            }
 
        }) { (responseObject, error) in
            print(error)
        }
    }
    
    func showNoResults() {
        searchResultsCollectionView.isHidden = true
        searchProductsView.isHidden = false
        searchProductsLabel.text = "No Results"
        searchProductsImageView.image = UIImage(named: "icn-tabbar-shop.pdf")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchProductsView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchForProducts(withTerm: "boots")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RCHProductCollectionViewCell
        let product = productArray[indexPath.row]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.string(from: product.priceCents!)
        
        cell.productImage.sd_setImage(with: URL(string: product.imageURL!))
        cell.brandLabel.text = product.brand?.uppercased()
        cell.titleLabel.text = product.name
        
        return cell
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
