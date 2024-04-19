//
//  LocationPickerViewController.swift
//  CalPals
//
//  Created by Emily Erwin on 3/18/24.
//
// followed this tutorial for locations - https://www.jeffedmondson.dev/swift_location_search/

import UIKit
import MapKit
import CoreLocationUI

class LocationPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate , MKLocalSearchCompleterDelegate  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTable: UITableView!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        searchBar?.delegate = self
        searchResultsTable?.delegate = self
        searchResultsTable?.dataSource = self
    }
    
    // Handles input text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
        
    // whenever there is new search results
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTable.reloadData()
    }
        
    // TODO: fix error handling
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Error handling
    }
    
    // MARK: - table handling
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }

    // upon selecting an item in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)

        let search = MKLocalSearch(request: searchRequest)
        
        // set location on previous VC and return
        let otherVC = delegate as! LocationChanger
        otherVC.changeLocation(newLoc: result.title)
        self.dismiss(animated: true, completion: nil)
    }
    

}
