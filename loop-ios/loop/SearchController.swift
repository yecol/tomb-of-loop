//
//  SearchController.swift
//  loop
//
//  Created by Yecol Hsu on 14/02/2017.
//  Copyright © 2017 Jingbo. All rights reserved.
//

import UIKit

fileprivate let kHeaderCell = "kHeaderCell"
fileprivate let kPostCell = "kPostCell"
fileprivate let kPeopleCell = "kPeopleCell"

class SearchController: UITableViewController, UISearchResultsUpdating,
        UISearchBarDelegate, UISearchControllerDelegate {


    var resultsTableController: SearchResultsController!
    var searchController: UISearchController!


    override func viewDidLoad() {
        super.viewDidLoad();
//        self.view.addSubview(self.tableView);
        self.tableView.estimatedRowHeight = 60;
        self.navBarBgAlpha = 1
        self.navBarTintColor = .white
        configureSearchController();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func loadSearchResults() {
        //load search results;
    }

    func configureSearchController() {


        resultsTableController = SearchResultsController(style: .grouped);
        resultsTableController.delegate = self;

        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "kSearchHint".localized
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false;
        
        UITextField.appearance(whenContainedInInstancesOf: [type(of: searchController.searchBar)]).tintColor = CL_GREY_FONT;


        searchController.delegate = self
        searchController.searchBar.delegate = self

        self.navigationItem.titleView = searchController.searchBar;
        self.definesPresentationContext = true;
    }


    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.resultsTableController.clearResults();
        self.resultsTableController.tableView.reloadData();
    }


    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
        let key = searchBar.text!;
        print("now I am begin to search with key = ", key);
        if (key != "") {
            DataModelManager.sharedInstance.cloudPerformSearch(key, block: { (result: Any?, error: Error?) in
                if (self.filterError(error)) {
                    self.resultsTableController.bindSearchResult(dict: result! as! NSDictionary);
                }
            })
        }
    }


    func updateSearchResults(for: UISearchController) {
    }


}
