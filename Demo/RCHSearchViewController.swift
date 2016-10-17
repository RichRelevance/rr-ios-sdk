//
//  RCHSearchViewController.swift
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "productCell"

class RCHSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchProductsView: UIView!
    @IBOutlet weak var searchResultsCollectionView: UICollectionView!
    @IBOutlet weak var searchProductsLabel: UILabel!
    @IBOutlet weak var searchProductsImageView: UIImageView!
    @IBOutlet weak var autocompleteTableView: UITableView!
    
    weak var timer = Timer()
    
    var products: [RCHSearchProduct]  = [] {
        didSet {
            searchResultsCollectionView.reloadData()
            if products.isEmpty {
                searchResultsCollectionView.isHidden = true
                searchProductsView.isHidden = false
                searchProductsLabel.text = "No Results"
                searchProductsImageView.image = UIImage(named: "icn-tabbar-shop.pdf")
            } else {
                searchResultsCollectionView.isHidden = false
                searchProductsView.isHidden = true
            }
        }
    }
    var autocompleteSuggestions: [String] = [] {
        didSet {
            autocompleteTableView.reloadData()
            if autocompleteSuggestions.isEmpty {
                autocompleteTableView.isHidden = true
                searchProductsLabel.text = "Search Products"
                searchProductsImageView.image = UIImage(named: "icn-tabbar-search.pdf")
                searchProductsView.isHidden = false
            } else {
                autocompleteTableView.isHidden = false
            }
        }
    }
    var searchTerm = "" {
        didSet {
            if searchTerm.isEmpty {
                products.removeAll()
                autocompleteSuggestions.removeAll()
            }
            else {
                searchBar.text = searchTerm
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.searchForProducts), userInfo: nil, repeats: false)
            }
        }
    }
}
    
extension RCHSearchViewController: UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        setupView()
    }
    
    func setupView() {
        searchResultsCollectionView.isHidden = true
        searchProductsView.isHidden = false

        let footerViewFrame = CGRect(x: 0, y: 0, width: autocompleteTableView.frame.width, height: autocompleteTableView.frame.height)
        let footerView = UIView(frame: footerViewFrame)
        footerView.backgroundColor = UIColor.clear
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(RCHSearchViewController.handleTapOnFooter))
        tapRecognizer.numberOfTapsRequired = 1
        footerView.addGestureRecognizer(tapRecognizer)
        autocompleteTableView.tableFooterView = footerView
        
        searchResultsCollectionView!.register(UINib(nibName: "RCHProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        configureAPI()
    }
    
    func dismissSearch() {
        view.endEditing(true)
        autocompleteSuggestions.removeAll()
    }
    
    // MARK: API
    
    func configureAPI() {
        // Temp: Config API for usable API key
        
        guard let currentUserID = UserDefaults.standard.string(forKey: kRCHUserDefaultKeyCurrentUser) else {
            fatalError()
        }
        
        let config = RCHAPIClientConfig(apiKey: "showcaseparent", apiClientKey: "199c81c05e473265", endpoint: RCHEndpointProduction, useHTTPS: false)
        config.apiClientSecret = "r5j50mlag06593401nd4kt734i"
        config.userID = currentUserID
        config.sessionID = UUID().uuidString
        
        RCHSDK.defaultClient().configure(config)
    }

    func searchForProducts() {
        let placement: RCHRequestPlacement = RCHRequestPlacement.init(pageType: .search, name: "find")
        let searchBuilder: RCHSearchBuilder = RCHSDK.builder(forSearch: placement, withQuery: searchTerm)
        
        RCHSDK.defaultClient().sendRequest(searchBuilder.build(), success: { (responseObject) in
            
            guard let searchResult = responseObject as? RCHSearchResult else {
                return
            }
            
            self.products = searchResult.products!

        }) { (responseObject, error) in
            print(error)
        }
    }
    
    func autocomplete(withQuery text: String) {
        let autocompleteBuilder: RCHAutocompleteBuilder = RCHSDK.builderForAutocomplete(withQuery: text)
        
        RCHSDK.defaultClient().sendRequest(autocompleteBuilder.build(), success: { (responseObject) in
            
            guard let responseAutocompleteSuggestions = responseObject as? [RCHAutocompleteSuggestion] else {
                print("Result Error")
                return
            }
            
            self.autocompleteSuggestions = responseAutocompleteSuggestions.map({$0.text!})
        }) { (responseObject, error) in
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            print(error)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func handleTapOnFooter(sender: UITapGestureRecognizer) {
        dismissSearch()
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchProductsView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText
        autocomplete(withQuery: searchText)
    }
 
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RCHProductCollectionViewCell
        let product = products[indexPath.row]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let priceCentsToDollars = (product.priceCents?.intValue)! / 100 as NSNumber
        
        cell.priceLabel.text = numberFormatter.string(from: priceCentsToDollars)
        cell.productImage.sd_setImage(with: URL(string: product.imageURL!))
        cell.brandLabel.text = product.brand?.uppercased()
        cell.titleLabel.text = product.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "productDetailSegue", sender: self)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "autocompleteCell", for: indexPath)
        cell.textLabel?.attributedText = attributedText(for: indexPath.row)
        
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        cell.backgroundView = effectView
        
        return cell
    }
    
    func attributedText(for row: Int) -> NSAttributedString {
        let autocompleteString = autocompleteSuggestions[row]

        let attributedString = NSMutableAttributedString(string: autocompleteString)
        
        if !searchTerm.isEmpty && autocompleteSuggestions.count > 0 {
            let searchString = searchTerm.lowercased()
            let highlightColor = UIColor(red: 0, green: 121/255, blue: 253/255, alpha: 1)
            let blueAttribute = [NSBackgroundColorAttributeName : highlightColor]
            
            if let range: Range<String.Index> = autocompleteString.range(of: searchString) {
                let index: Int = autocompleteString.distance(from: autocompleteString.startIndex, to: range.lowerBound)
                let nsRange = NSMakeRange(index, searchString.characters.count)
                attributedString.addAttributes(blueAttribute, range: nsRange)
            }
        }
        return attributedString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTerm = autocompleteSuggestions[indexPath.row]
        dismissSearch()
    }
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productDetailSegue" {
            if let destinationViewControler = segue.destination as? RCHProductDetailViewController {
                guard let selectedIndexPath = searchResultsCollectionView.indexPathsForSelectedItems else {
                    return
                }
                let selectedProduct = products[selectedIndexPath[0].row]
                destinationViewControler.product = selectedProduct
            }
        }
    }
}
