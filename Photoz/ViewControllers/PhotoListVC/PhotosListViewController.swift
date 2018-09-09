//
//  ViewController.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/08/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import UIKit

fileprivate enum ItemsPerRow:Int {
    case two
    case three
    case four
    
    func getSize() -> CGSize{
        let size = UIScreen.main.bounds
        switch self {
        case .two:
            let width = (size.width - 30)/2
            return CGSize(width: width, height: width)
        case .three:
            let width = (size.width - 40)/3
            return CGSize(width: width, height: width)
        case .four:
            let width = (size.width - 50)/4
            return CGSize(width: width, height: width)
        }
    }
}

class PhotosListViewController: ParentViewController {
    // Outlets **********************************************
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    
    // Properties *******************************************
    
    /** SearchViewModel which holds all data manipulation/show logic.
     */
    var searchViewModel:PhotoListViewModel!
    
    fileprivate var itemsPerRow:ItemsPerRow = .two {
        didSet {
            self.photoCollectionView.reloadData()
        }
    }
    
    /** Search Controller which is used for searching.
     */
    fileprivate lazy var searchController = { () -> UISearchController in
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = Constants.searchPlaceHolder
        sc.searchBar.barTintColor = .black
        sc.searchBar.barStyle = .default
        sc.searchBar.delegate = self
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialConfigs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /**
     All intitlization which are required at controller loading.
     */
    func initialConfigs() {
        initNBindViewModel()
        //Setup Collection view.
        func setupCollectionView() {
            photoCollectionView.delegate = self
            photoCollectionView.dataSource = self
        }
        // Setup Search Bar.
        func setupSearchBar() {
            definesPresentationContext = true
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
        //Setup Navigation Bar.
        func setupNavBar() {
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.topItem?.title = Constants.searchControllerNavigationTitle
        }
        setupSearchBar()
        setupNavBar()
        setupCollectionView()
    }
    
    /**
     Bind View Model to Controller to receive callbacks.
     */
    func initNBindViewModel () {
        searchViewModel = PhotoListViewModel()
        
        // Called when search results are fetched
        searchViewModel.searchCompletionBlock = {[weak self] success,errorText in
            self?.photoCollectionView.reloadData()
            self?.searchController.searchBar.isUserInteractionEnabled = true
            if success {
            } else {
                self?.showAlert(with: errorText)
            }
        }
        
        // Called when UI needs to be refreshed
        searchViewModel.refreshCallback = { [weak self] in
            self?.photoCollectionView.reloadData()
        }
    }
    

    
    @IBAction func didTappedRightActionItem(_ sender: UIBarButtonItem) {
        let rowsAlert = UIAlertController(title: nil, message: Constants.Alert.itemPerRows, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let twoRowAction = UIAlertAction(title: "Two", style: .default) { _ in
            self.itemsPerRow = .two
        }
        let threeRowAction = UIAlertAction(title: "Three", style: .default) { _ in
            self.itemsPerRow = .three
        }
        let fourRowAction = UIAlertAction(title: "Four", style: .default) { _ in
            self.itemsPerRow = .four
        }
        
        let dismiss = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        rowsAlert.addAction(twoRowAction)
        rowsAlert.addAction(threeRowAction)
        rowsAlert.addAction(fourRowAction)
        rowsAlert.addAction(dismiss)
        
        present(rowsAlert, animated: true, completion: nil)
    }
}


extension PhotosListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.numberOfCells()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        searchViewModel.shouldFetchMorePages(with: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = searchViewModel.cellItems(indexPath: indexPath) else {
            fatalError("DataSource Mismatch")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        cell.config(dataSource: data)

        if !collectionView.isDecelerating && !collectionView.isDragging {
            cell.downloadImage()
        } else {
            cell.showDownloadedImage()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemsPerRow.getSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
    }
    
    func loadImagesForOnscreenCells()  {
        let cells = photoCollectionView.visibleCells
        cells.forEach {
            ($0 as? PhotoCell)?.downloadImage()
        }
    }
}


//MARK: SEARCH BAR DELEGATE
extension PhotosListViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
        let searchText = searchBar.text
        getDataFromSearchTerm(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
    }
    
    private func getDataFromSearchTerm(text:String?) {
        self.searchController.searchBar.isUserInteractionEnabled = false
        searchViewModel.fetchPhotosResults(with: text)
        searchController.isActive = false
    }
}


