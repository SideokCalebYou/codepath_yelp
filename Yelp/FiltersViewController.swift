//
//  FiltersViewController.swift
//  Yelp
//
//  Created by sideok you on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate{
  @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

  @IBOutlet weak var tableView: UITableView!
  
  var offeringadeal: String!
  var distances: [[String:String]]!
  var sortBy: [[String:String]]!
  var categories: [[String:String]]!
  
  
  var offeringADealFilter: Bool = false
  var distanceFilter:String? = nil
  var sortByFilter:String? = "Auto"
  
  
  var switchStates = [Int:Bool]()
  var distanceStates = [Int:Bool]()
  var sortByStates = [Int:Bool]()
  
  
  weak var delegate: FiltersViewControllerDelegate?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableView.dataSource = self
        tableView.delegate = self
      
        self.categories = yelpCategories()
        self.offeringadeal = yelpOfferingADeal()
        self.distances = yelpDistance()
        self.sortBy = yelpSortBy()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0{
      return 1
    }else if section == 1{
      return distances.count
    }else if section == 2{
      return sortBy.count
    }else if section == 3{
      return categories.count
    }else{
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    if section == 0 {
      return ""
    } else if section == 1{
      return  "Distance"
    } else if section == 2{
      return  "Sort By"
    }  else if section == 3{
      return  "Category"
    }
    else {
      return  nil
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
    
    if indexPath.section == 0{
      cell.switchLabel.text = offeringadeal
      cell.onSwitch.isOn = offeringADealFilter
    }else if indexPath.section == 1{
      cell.switchLabel.text = distances[indexPath.row]["name"]
      cell.onSwitch.isOn = distanceStates[indexPath.row] ?? false
    }else if indexPath.section == 2{
      cell.switchLabel.text = sortBy[indexPath.row]["name"]
      cell.onSwitch.isOn = sortByStates[indexPath.row] ?? false
    }else if indexPath.section == 3{
      cell.switchLabel.text = categories[indexPath.row]["name"]
      cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
    }else{
      print("Couldn't find the section")
    }
    cell.delegate = self
    
//    if switchStates[indexPath.row] != nil{
//      cell.onSwitch.isOn = switchStates[indexPath.row]!
//    }else{
//      cell.onSwitch.isOn = false
//    }
// 위의 것을 아래와 같이 할 수 있다.
    
    
    return cell
  }
  
  func switchCell(switchCell: SwitchCell, didChangedValue value: Bool) {
    let indexPath = tableView.indexPath(for: switchCell)!
    
    let section = indexPath.section
    
    if section == 0{
      offeringADealFilter = value
      print("deal")
    }else if section == 1{
      if value == true{
        distanceFilter = switchCell.switchLabel.text!
        distanceStates.keys.forEach({ (distanceStates[$0] = false)})
      }else{
        distanceFilter = nil;
      }
      distanceStates[indexPath.row] = value
      print("distance")
    }else if section == 2{
      if value == true{
        sortByFilter = switchCell.switchLabel.text!
        sortByStates.keys.forEach({ (sortByStates[$0] = false)})
      }else{
        sortByFilter = "Auto"
      }
      sortByStates[indexPath.row] = value
      print("sortby")
    }else if section == 3{
      switchStates[indexPath.row] = value
      
    }else{
      print("couldn't find switch action")
    }
    
    print("filters view controller got the switch event")
    
    self.tableView.reloadData()
  }
    
  @IBAction func onCancelButton(_ sender: Any) {
    dismiss(animated: true, completion:nil)
  }

  @IBAction func onSearchButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    
    var filters = [String:AnyObject]()
    
    var selectedCategories = [String]()
    
    for(row, isSelected) in switchStates {
      if isSelected {
        selectedCategories.append(categories[row]["code"]!)
      }
    }
    
    var selectedDistance = String()
    for(row, isSelected) in distanceStates{
      if isSelected{
        selectedDistance = distances[row]["value"]!
      }
    }
    
    var selectedSortBy = String()
    for(row, isSelected) in sortByStates{
      if isSelected{
        selectedSortBy = sortBy[row]["value"]!
      }
    }
    
    if selectedCategories.count > 0 {
      filters["categories"] = selectedCategories as AnyObject
    }
    
    if offeringADealFilter == true{
      filters["deals"] = offeringADealFilter as AnyObject
    }
    
    if !selectedDistance.isEmpty{
      filters["distance"] = selectedDistance as AnyObject
    }else{
      filters["distance"] = "0" as AnyObject
    }
    
    if !selectedSortBy.isEmpty{
      
      if selectedSortBy == "distance"{
        filters["sortby"] = 1 as AnyObject
      }else if selectedSortBy == "highestRated"{
        filters["sortby"] = 2 as AnyObject
      }else{
        filters["sortby"] = 0 as AnyObject
      }
      
    }else{
      filters["sortby"] = 0 as AnyObject
    }
    
    delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
  }
  
  func yelpDistance() -> [[String:String]]{
    return [["name": "Auto", "value":"0"],
            ["name": "0.3 miles", "value":"483"],
            ["name": "1 miles", "value":"1609"],
            ["name": "5 miles", "value":"8047"],
            ["name": "20 miles", "value":"32187"],
    ]
  }
  
  func yelpSortBy() -> [[String:String]]{
    return [["name":"Best Match", "value":"bestMatched"],
            ["name":"Distance", "value":"distance"],
            ["name":"Highest Rated", "value":"highestRated"],
    
    ]
  }
  
  func yelpOfferingADeal() -> String{
    return "Offering a Deal"
  }
  
  func yelpCategories() -> [[String:String]]{
    return [["name" : "Afghan", "code": "afghani"],
                      ["name" : "African", "code": "african"],
                      ["name" : "American, New", "code": "newamerican"],
                      ["name" : "American, Traditional", "code": "tradamerican"],
                      ["name" : "Arabian", "code": "arabian"],
                      ["name" : "Argentine", "code": "argentine"],
                      ["name" : "Armenian", "code": "armenian"],
                      ["name" : "Asian Fusion", "code": "asianfusion"],
                      ["name" : "Asturian", "code": "asturian"],
                      ["name" : "Australian", "code": "australian"],
                      ["name" : "Austrian", "code": "austrian"],
                      ["name" : "Baguettes", "code": "baguettes"],
                      ["name" : "Bangladeshi", "code": "bangladeshi"],
                      ["name" : "Barbeque", "code": "bbq"],
                      ["name" : "Basque", "code": "basque"],
                      ["name" : "Bavarian", "code": "bavarian"],
                      ["name" : "Beer Garden", "code": "beergarden"],
                      ["name" : "Beer Hall", "code": "beerhall"],
                      ["name" : "Beisl", "code": "beisl"],
                      ["name" : "Belgian", "code": "belgian"],
                      ["name" : "Bistros", "code": "bistros"],
                      ["name" : "Black Sea", "code": "blacksea"],
                      ["name" : "Brasseries", "code": "brasseries"],
                      ["name" : "Brazilian", "code": "brazilian"],
                      ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                      ["name" : "British", "code": "british"],
                      ["name" : "Buffets", "code": "buffets"],
                      ["name" : "Bulgarian", "code": "bulgarian"],
                      ["name" : "Burgers", "code": "burgers"],
                      ["name" : "Burmese", "code": "burmese"],
                      ["name" : "Cafes", "code": "cafes"],
                      ["name" : "Cafeteria", "code": "cafeteria"],
                      ["name" : "Cajun/Creole", "code": "cajun"],
                      ["name" : "Cambodian", "code": "cambodian"],
                      ["name" : "Canadian", "code": "New)"],
                      ["name" : "Canteen", "code": "canteen"],
                      ["name" : "Caribbean", "code": "caribbean"],
                      ["name" : "Catalan", "code": "catalan"],
                      ["name" : "Chech", "code": "chech"],
                      ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                      ["name" : "Chicken Shop", "code": "chickenshop"],
                      ["name" : "Chicken Wings", "code": "chicken_wings"],
                      ["name" : "Chilean", "code": "chilean"],
                      ["name" : "Chinese", "code": "chinese"],
                      ["name" : "Comfort Food", "code": "comfortfood"],
                      ["name" : "Corsican", "code": "corsican"],
                      ["name" : "Creperies", "code": "creperies"],
                      ["name" : "Cuban", "code": "cuban"],
                      ["name" : "Curry Sausage", "code": "currysausage"],
                      ["name" : "Cypriot", "code": "cypriot"],
                      ["name" : "Czech", "code": "czech"],
                      ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                      ["name" : "Danish", "code": "danish"],
                      ["name" : "Delis", "code": "delis"],
                      ["name" : "Diners", "code": "diners"],
                      ["name" : "Dumplings", "code": "dumplings"],
                      ["name" : "Eastern European", "code": "eastern_european"],
                      ["name" : "Ethiopian", "code": "ethiopian"],
                      ["name" : "Fast Food", "code": "hotdogs"],
                      ["name" : "Filipino", "code": "filipino"],
                      ["name" : "Fish & Chips", "code": "fishnchips"],
                      ["name" : "Fondue", "code": "fondue"],
                      ["name" : "Food Court", "code": "food_court"],
                      ["name" : "Food Stands", "code": "foodstands"],
                      ["name" : "French", "code": "french"],
                      ["name" : "French Southwest", "code": "sud_ouest"],
                      ["name" : "Galician", "code": "galician"],
                      ["name" : "Gastropubs", "code": "gastropubs"],
                      ["name" : "Georgian", "code": "georgian"],
                      ["name" : "German", "code": "german"],
                      ["name" : "Giblets", "code": "giblets"],
                      ["name" : "Gluten-Free", "code": "gluten_free"],
                      ["name" : "Greek", "code": "greek"],
                      ["name" : "Halal", "code": "halal"],
                      ["name" : "Hawaiian", "code": "hawaiian"],
                      ["name" : "Heuriger", "code": "heuriger"],
                      ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                      ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                      ["name" : "Hot Dogs", "code": "hotdog"],
                      ["name" : "Hot Pot", "code": "hotpot"],
                      ["name" : "Hungarian", "code": "hungarian"],
                      ["name" : "Iberian", "code": "iberian"],
                      ["name" : "Indian", "code": "indpak"],
                      ["name" : "Indonesian", "code": "indonesian"],
                      ["name" : "International", "code": "international"],
                      ["name" : "Irish", "code": "irish"],
                      ["name" : "Island Pub", "code": "island_pub"],
                      ["name" : "Israeli", "code": "israeli"],
                      ["name" : "Italian", "code": "italian"],
                      ["name" : "Japanese", "code": "japanese"],
                      ["name" : "Jewish", "code": "jewish"],
                      ["name" : "Kebab", "code": "kebab"],
                      ["name" : "Korean", "code": "korean"],
                      ["name" : "Kosher", "code": "kosher"],
                      ["name" : "Kurdish", "code": "kurdish"],
                      ["name" : "Laos", "code": "laos"],
                      ["name" : "Laotian", "code": "laotian"],
                      ["name" : "Latin American", "code": "latin"],
                      ["name" : "Live/Raw Food", "code": "raw_food"],
                      ["name" : "Lyonnais", "code": "lyonnais"],
                      ["name" : "Malaysian", "code": "malaysian"],
                      ["name" : "Meatballs", "code": "meatballs"],
                      ["name" : "Mediterranean", "code": "mediterranean"],
                      ["name" : "Mexican", "code": "mexican"],
                      ["name" : "Middle Eastern", "code": "mideastern"],
                      ["name" : "Milk Bars", "code": "milkbars"],
                      ["name" : "Modern Australian", "code": "modern_australian"],
                      ["name" : "Modern European", "code": "modern_european"],
                      ["name" : "Mongolian", "code": "mongolian"],
                      ["name" : "Moroccan", "code": "moroccan"],
                      ["name" : "New Zealand", "code": "newzealand"],
                      ["name" : "Night Food", "code": "nightfood"],
                      ["name" : "Norcinerie", "code": "norcinerie"],
                      ["name" : "Open Sandwiches", "code": "opensandwiches"],
                      ["name" : "Oriental", "code": "oriental"],
                      ["name" : "Pakistani", "code": "pakistani"],
                      ["name" : "Parent Cafes", "code": "eltern_cafes"],
                      ["name" : "Parma", "code": "parma"],
                      ["name" : "Persian/Iranian", "code": "persian"],
                      ["name" : "Peruvian", "code": "peruvian"],
                      ["name" : "Pita", "code": "pita"],
                      ["name" : "Pizza", "code": "pizza"],
                      ["name" : "Polish", "code": "polish"],
                      ["name" : "Portuguese", "code": "portuguese"],
                      ["name" : "Potatoes", "code": "potatoes"],
                      ["name" : "Poutineries", "code": "poutineries"],
                      ["name" : "Pub Food", "code": "pubfood"],
                      ["name" : "Rice", "code": "riceshop"],
                      ["name" : "Romanian", "code": "romanian"],
                      ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                      ["name" : "Rumanian", "code": "rumanian"],
                      ["name" : "Russian", "code": "russian"],
                      ["name" : "Salad", "code": "salad"],
                      ["name" : "Sandwiches", "code": "sandwiches"],
                      ["name" : "Scandinavian", "code": "scandinavian"],
                      ["name" : "Scottish", "code": "scottish"],
                      ["name" : "Seafood", "code": "seafood"],
                      ["name" : "Serbo Croatian", "code": "serbocroatian"],
                      ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                      ["name" : "Singaporean", "code": "singaporean"],
                      ["name" : "Slovakian", "code": "slovakian"],
                      ["name" : "Soul Food", "code": "soulfood"],
                      ["name" : "Soup", "code": "soup"],
                      ["name" : "Southern", "code": "southern"],
                      ["name" : "Spanish", "code": "spanish"],
                      ["name" : "Steakhouses", "code": "steak"],
                      ["name" : "Sushi Bars", "code": "sushi"],
                      ["name" : "Swabian", "code": "swabian"],
                      ["name" : "Swedish", "code": "swedish"],
                      ["name" : "Swiss Food", "code": "swissfood"],
                      ["name" : "Tabernas", "code": "tabernas"],
                      ["name" : "Taiwanese", "code": "taiwanese"],
                      ["name" : "Tapas Bars", "code": "tapas"],
                      ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                      ["name" : "Tex-Mex", "code": "tex-mex"],
                      ["name" : "Thai", "code": "thai"],
                      ["name" : "Traditional Norwegian", "code": "norwegian"],
                      ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                      ["name" : "Trattorie", "code": "trattorie"],
                      ["name" : "Turkish", "code": "turkish"],
                      ["name" : "Ukrainian", "code": "ukrainian"],
                      ["name" : "Uzbek", "code": "uzbek"],
                      ["name" : "Vegan", "code": "vegan"],
                      ["name" : "Vegetarian", "code": "vegetarian"],
                      ["name" : "Venison", "code": "venison"],
                      ["name" : "Vietnamese", "code": "vietnamese"],
                      ["name" : "Wok", "code": "wok"],
                      ["name" : "Wraps", "code": "wraps"],
                      ["name" : "Yugoslav", "code": "yugoslav"]]
  }
  
    
}
