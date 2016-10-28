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

extension UIAlertController {
    static func createFacetActionSheet(withTitle titles: [String?], onSelected: @escaping ((Int) -> ())) -> UIAlertController {
        
        let filterAlertController = UIAlertController(title: nil, message: "Choose Filter", preferredStyle: .actionSheet)
        
        for (index, title) in titles.enumerated() {
            
            let facetAction = UIAlertAction(title: title, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                onSelected(index)
            })
            filterAlertController.addAction(facetAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        filterAlertController.addAction(cancelAction)
        
        return filterAlertController
    }
}

enum SortingOptions: String {
    case priceLowest = "Price Low to High"
    case priceHighest = "Price High to Low"
    case newest = "Newest"
    case relevance = "Relevance"
    
    static let allValues = [priceLowest, priceHighest, newest, relevance]
}

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
    var searchFacets: [String: [RCHSearchFacet]] = [:]
    
    var currentFilter: RCHSearchFacet? = nil {
        didSet {
            var titleString = ""
            if currentFilter != nil {
                guard let currentTitle = currentFilter?.title else {
                    return
                }
                titleString = "Filter: \(currentTitle)"
                filterButton.setTitle(titleString, for: .normal)
            } else {
                titleString = "Filter"
            }
            filterButton.setTitle(titleString, for: .normal)
        }
    }
    var currentSort: SortingOptions = .relevance {
        didSet {
            pickerView.isHidden = true
            let titleString = "Sort: \(currentSort.rawValue)"
            sortButton.setTitle(titleString, for: .normal)
        }
    }
    
    var pageCount = 0 {
        didSet {
            if pageCount > 0 {
                previousButton.isEnabled = true
                previousButton.setTitleColor(.blue, for: .normal)
            } else {
                previousButton.isEnabled = false
                previousButton.setTitleColor(.gray, for: .normal)
            }
        }
    }

    var products: [RCHSearchProduct]  = [] {
        didSet {
            searchResultsCollectionView.reloadData()
            if products.isEmpty {
                searchResultsCollectionView.isHidden = true
            } else {
                searchResultsCollectionView.isHidden = false
            }
            updateSearchProductsView()
            updateSortFilterHiddentState()
        }
    }
    var autocompleteSuggestions: [String] = [] {
        didSet {
            autocompleteTableView.reloadData()
            if autocompleteSuggestions.isEmpty {
                autocompleteTableView.isHidden = true
            } else {
                autocompleteTableView.isHidden = false
            }
            updateSortFilterHiddentState()
        }
    }

    var searchTerm = "" {
        didSet {
            if searchTerm.isEmpty {
                products.removeAll()
                autocompleteSuggestions.removeAll()
                pageCount = 0
            }
            else {
                searchBar.text = searchTerm
                searchProductsView.isHidden = true
            }
        }
    }

    func updateSortFilterHiddentState() {
        sortFilterView.isHidden = products.isEmpty || autocompleteTableView.isHidden == false
    }

    func updateSearchProductsView() {
        searchProductsView.isHidden = !products.isEmpty
        searchProductsLabel.text = searchTerm.isEmpty ? "Search Products" : "No Results"
        searchProductsImageView.image = UIImage(named: searchTerm.isEmpty ? "img-search.pdf" : "img-noresults.pdf")
    }
}

extension SortingOptions: CustomStringConvertible {
    var description: String {
        switch self {
        case .relevance: return ""
        case .newest: return "product_release_date"
        case .priceLowest: return "product_pricecents"
        case .priceHighest: return "product_pricecents"
        }
    }
    var order: Bool {
        switch self {
        case .relevance: return true
        case .newest: return false
        case .priceLowest: return true
        case .priceHighest: return false
        }
    }
}

extension RCHSearchViewController: UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
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
        sortButton.setTitle("Sort", for: .normal)
        updateSearchProductsView()
    }
    
    // MARK: API

    func searchForProducts() {
        let placement: RCHRequestPlacement = RCHRequestPlacement.init(pageType: .search, name: "find")
        let searchBuilder: RCHSearchBuilder = RCHSDK.builder(forSearch: placement, withQuery: searchTerm)
        searchBuilder.setPageStart(pageCount * 20)
        if let searchFilter = currentFilter {
            searchBuilder.addFilter(from: searchFilter)
        }
        
        let sortString = currentSort.description
        let orderASC = currentSort.order
        
        if currentSort != .relevance {
            searchBuilder.addSortOrder(sortString, ascending: orderASC)
        }

        RCHSDK.defaultClient().sendRequest(searchBuilder.build(), success: { (responseObject) in
            guard let searchResult = responseObject as? RCHSearchResult else { return }
            // If the search term has been emptied, ignore this response since there will not be another request to update it.
            guard !self.searchTerm.isEmpty else { return }

            self.products = searchResult.products!
            self.searchFacets = searchResult.facets!
            
            if searchResult.count > 20 && self.products.count >= 20 {
                self.nextButton.isEnabled = true
                self.nextButton.setTitleColor(.blue, for: .normal)
            } else {
                self.nextButton.isEnabled = false
                self.nextButton.setTitleColor(.gray, for: .normal)
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
    
    // MARK: IBActions
    
    @IBAction func handleTapOnFooter(sender: UITapGestureRecognizer) {
        dismissSearch()
    }
    
    @IBAction func filterSelected(_ sender: AnyObject) {
        
        let titles = searchFacets.map({ $0.key })
        
        let alertController = UIAlertController.createFacetActionSheet(withTitle: titles) { index in
            guard let facetSelected = self.searchFacets[titles[index]] else {
                return
            }
            self.showSubFilter(withFacets: facetSelected)
        }
        
        if currentFilter != nil {
            let removeFilterAction = UIAlertAction(title: "Remove Filter", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                self.currentFilter = nil
                self.searchForProducts()
            })
            alertController.addAction(removeFilterAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSubFilter(withFacets facets: [RCHSearchFacet]) {
        
        let titles = facets.map( { $0.title })
        
        let alertController = UIAlertController.createFacetActionSheet(withTitle: titles) { index in
            let facetSelected = facets[index]
            self.currentFilter = facetSelected
            self.searchForProducts()
        }
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func sortSelected(_ sender: AnyObject) {
        pickerView.isHidden = false
    }

    @IBAction func sortPickerDoneSelected(_ sender: AnyObject) {
        currentSort = SortingOptions.allValues[sortPicker.selectedRow(inComponent: 0)]
        searchForProducts()
    }
    
    @IBAction func sortPickerCancelSelected(_ sender: AnyObject) {
        pickerView.isHidden = true
    }
    
    @IBAction func footerButtonSelected(_ sender: AnyObject) {
        searchResultsCollectionView.setContentOffset(CGPoint.zero, animated: false)
        if sender.tag == 2 {
            pageCount += 1
        } else if sender.tag == 3 {
            pageCount -= 1
        }
        searchForProducts()
    }

    // MARK: UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchProductsView.isHidden = true
        currentFilter = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = searchText.replacingOccurrences(of: " ", with: "")
        timer?.invalidate()
        if !searchTerm.isEmpty {
            autocomplete(withQuery: searchText)
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.searchForProducts), userInfo: nil, repeats: false)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissSearch()
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
        searchForProducts()
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
