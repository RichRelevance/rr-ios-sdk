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
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchProductsView: UIView!
    @IBOutlet weak var searchResultsCollectionView: UICollectionView!
    @IBOutlet weak var searchProductsLabel: UILabel!
    @IBOutlet weak var searchProductsImageView: UIImageView!
    @IBOutlet weak var autocompleteTableView: UITableView!
    @IBOutlet weak var sortFilterView: UIView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    var nextButton = UIButton()
    var previousButton = UIButton()
    var sortPicker = UIPickerView()
    var pickerView = UIView()
    
    weak var timer = Timer()
    var currentSort: SortingOptions = .relevance
    
    var pageCount = 0 {
        didSet {
            if pageCount > 0 {
                previousButton.isEnabled = true
            } else {
                previousButton.isEnabled = false
            }
        }
    }
    
    var pageStart = 0 {
        didSet {
           searchForProducts()
        }
    }

    var products: [RCHSearchProduct]  = [] {
        didSet {
            searchResultsCollectionView.reloadData()
            if products.isEmpty {
                searchResultsCollectionView.isHidden = true
                searchProductsView.isHidden = false
                searchProductsLabel.text = "No Results"
                searchProductsImageView.image = UIImage(named: "img-noresults.pdf")
            } else {
                searchResultsCollectionView.isHidden = false
                searchProductsView.isHidden = true
//                sortFilterView.isHidden = false
            }
        }
    }
    var autocompleteSuggestions: [String] = [] {
        didSet {
            autocompleteTableView.reloadData()
            if autocompleteSuggestions.isEmpty {
                autocompleteTableView.isHidden = true
            } else {
                autocompleteTableView.isHidden = false
//                sortFilterView.isHidden = true
            }
        }
    }
    var searchTerm = "" {
        didSet {
            if searchTerm.isEmpty {
                products.removeAll()
                autocompleteSuggestions.removeAll()
//                sortFilterView.isHidden = true
            }
            else {
                searchBar.text = searchTerm
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.searchForProducts), userInfo: nil, repeats: false)
            }
        }
    }
    
    enum SortingOptions: String {
        case priceLowest = "Price Low to High"
        case priceHighest = "Price High to Low"
        case newest = "Newest"
        case relevance = "Relevance"
        case rating = "Rating"
        
        static let allValues = [priceLowest, priceHighest,newest, relevance, rating]
    }
}
    
extension RCHSearchViewController: UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        configureAPI()
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
        
        pickerView.frame = CGRect(x: 0, y: view.frame.height - 300, width: view.frame.width, height: 300)
        sortPicker.dataSource = self
        sortPicker.delegate = self
        sortPicker.frame = CGRect(x: 0, y: 30, width: view.frame.width, height: 270)
        sortPicker.backgroundColor = UIColor.lightGray
        sortPicker.showsSelectionIndicator = true
        
        searchResultsCollectionView!.register(UINib(nibName: "RCHProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.blue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.sortPickerDoneSelected))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.sortPickerCancelSelected))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        sortFilterView.isHidden = true
        pickerView.addSubview(sortPicker)
        pickerView.addSubview(toolBar)
        view.addSubview(pickerView)
        pickerView.isHidden = true
        
        previousButton.isEnabled = false
        nextButton.isEnabled = false
    }
    
    func dismissSearch() {
        view.endEditing(true)
        autocompleteSuggestions.removeAll()
        if products.isEmpty {
            sortFilterView.isHidden = true
            searchProductsLabel.text = "Search Products"
            searchProductsImageView.image = UIImage(named: "img-search.pdf")
        } else {
            sortFilterView.isHidden = false
        }
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
        searchBuilder.setPageStart(pageStart)
        
        RCHSDK.defaultClient().sendRequest(searchBuilder.build(), success: { (responseObject) in
            
            guard let searchResult = responseObject as? RCHSearchResult else {
                return
            }
            
            self.products = searchResult.products!
            if searchResult.count > 20 {
                self.nextButton.isEnabled = true
            } else {
                self.nextButton.isEnabled = false
            }

        }) { (responseObject, error) in
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
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
    
    func sortProducts(selection: SortingOptions) {
        let placement: RCHRequestPlacement = RCHRequestPlacement.init(pageType: .search, name: "find")
        let searchBuilder: RCHSearchBuilder = RCHSDK.builder(forSearch: placement, withQuery: searchTerm)
        searchBuilder.setPageStart(pageStart)

        var sortString = ""
        var orderASC = true
        
        switch selection {
        case .priceLowest:
            sortString = "product_pricecents"
            orderASC = true
            break
        case .priceHighest:
            sortString = "product_pricecents"
            orderASC = false
            break
        case .newest:
            sortString = "product_release_date"
            orderASC = false
            break
        case .rating:
            sortString = "product_rating"
            orderASC = false
            break
        case .relevance:
            sortString = "product_relevance"
            orderASC = true
        }
        
        searchBuilder.addSortOrder(sortString, ascending: orderASC)
        
        RCHSDK.defaultClient().sendRequest(searchBuilder.build(), success: { (responseObject) in
            
            guard let searchResult = responseObject as? RCHSearchResult else {
                return
            }
            
            self.products = searchResult.products!
            
        }) { (responseObject, error) in
            print(error)
        }
        print(selection)
    }
    
    // MARK: IBActions
    
    @IBAction func handleTapOnFooter(sender: UITapGestureRecognizer) {
        dismissSearch()
    }
    
    @IBAction func sortSelected(_ sender: AnyObject) {
        pickerView.isHidden = false
    }
    
    @IBAction func filterSelected(_ sender: AnyObject) {
        
    }
    
    @IBAction func sortPickerDoneSelected(_ sender: AnyObject) {
        pickerView.isHidden = true
        print(SortingOptions.allValues[sortPicker.selectedRow(inComponent: 0)])
        let sortOption: SortingOptions = SortingOptions.allValues[sortPicker.selectedRow(inComponent: 0)]
        sortProducts(selection: sortOption)
        let titleString = "Sort: \(sortOption.rawValue)"
        sortButton.setTitle(titleString, for: .normal)
    }
    
    @IBAction func sortPickerCancelSelected(_ sender: AnyObject) {
        pickerView.isHidden = true
    }
    
    @IBAction func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        dismissSearch()
    }
    
    @IBAction func footerButtonSelected(_ sender: AnyObject) {
        if sender.tag == 2 {
            pageStart += 20
            pageCount += 1
            print("next")
        } else if sender.tag == 3 {
            pageStart -= 20
            pageCount -= 1
            print("previous")
        }
        
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
        sortFilterView.isHidden = true
        if !searchTerm.isEmpty {
            autocomplete(withQuery: searchText)
        } else {
            searchProductsView.isHidden = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissSearch()
        
        searchProductsLabel.text = "Search Products"
        searchProductsImageView.image = UIImage(named: "img-search.pdf")
        searchProductsView.isHidden = false
        sortFilterView.isHidden = true
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath) as! RCHSearchResultsCollectionReusableView
        previousButton = headerView.previousButton
        nextButton = headerView.nextButton
        return headerView
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
    
    // MARK: UIPickerViewDelegate
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SortingOptions.allValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SortingOptions.allValues[row].rawValue
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
