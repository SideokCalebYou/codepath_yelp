//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate {
    
  var businesses: [Business]!
  var searchBar = UISearchBar()
  var filteredData: [Business]!
  
  @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.filteredData = businesses
            self.tableView.reloadData()
          
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                 
                }
            }
            
        }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText != "" {
      filteredData = businesses.filter { String(describing: $0.name).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil}
    } else {
      filteredData = businesses
    }
    tableView.reloadData()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if filteredData != nil{
      return filteredData!.count
    }else{
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell") as! BusinessCell
    cell.business = filteredData[indexPath.row]
    
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let navigationController = segue.destination as! UINavigationController
    
    let filtersViewController = navigationController.topViewController as! FiltersViewController
    
    filtersViewController.delegate = self
  }
  
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    
    if filters["categories"] != nil || filters["sortby"] != nil || filters["deals"] != nil || filters["distance"] != nil{
      let categories = filters["categories"] as? [String]
      let sortBy = filters["sortby"] as? Int
      let distance = filters["distance"] as? String
      let int_distance = Int(distance!)
      let deals = filters["deals"] as? Bool
      
      print("here is the part for applying")
      
      print(filters)
      Business.searchWithTerm(term: "Restaurants", sort: sortBy, radius: int_distance, categories: categories, deals: deals) { (businesses:[Business]!, error: Error!)-> Void in
        self.businesses = businesses
        self.filteredData = businesses
        self.tableView.reloadData()
    }
    
    
    }
   
  }
    
}
