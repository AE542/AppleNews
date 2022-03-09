//
//  iPhoneViewNewsControlller.swift
//  AppleNewsV.1
//
//  Created by Mohammed Qureshi on 2022/03/07.
//

import UIKit

class iPhoneTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    let mainVC = APIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        title = "iPhone News"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "DINAlternate-Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        navigationController?.navigationBar.prefersLargeTitles = true
      
        mainVC.refreshControl.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        mainVC.refreshControl.tintColor = .systemBlue
        mainVC.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        //mainVC.refreshControl.backgroundColor = .blue
        self.tableView.addSubview(mainVC.refreshControl)

        navigationItem.searchController = mainVC.searchController
        
        mainVC.searchController.searchResultsUpdater = self //don't forget to call this here! Searchbar doesn't register any text input without it!
        //Use the methods of that protocol to search your content and deliver the results to your search results view controller. The object contained by the searchResultsUpdater property is often the view controller that is set during initialization.
        
        mainVC.searchController.obscuresBackgroundDuringPresentation = false
        mainVC.searchController.searchBar.placeholder = "Search Articles"
        
        
        let networkManager = NetworkManager()
        
        let urlQuery = networkManager.updateDateForAPICall(appleProduct: NetworkManager.queryType.iPhone.rawValue, date: networkManager.currentDate)
        
        let url = URL(string: urlQuery)

        DispatchQueue.global(qos: .userInitiated).async {
        guard url != nil else {
            return
        } //url might be nil so this makes sure if it's nil it stops running the program
            let session = self.mainVC.urlSession //we just need to access the shared urlSession, not necessary to create it. provides a shared singleton session object that gives you a reasonable default behavior for creating tasks. Use the shared session to fetch the contents of a URL to memory with just a few lines of code.
            let request = URLRequest(url: url!)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            //needs a closure to run the code in here to handle the data and check for errors.

            if error == nil && data != nil { //if no errors and data is not equal to nil
                let decoder = JSONDecoder()

                do {
                    let appleNewsFeed = try decoder.decode(NewsArticles.self, from: data!) //decodes data using JSON from the API here

                    self.mainVC.parseJSONData(data!) //this is showing the data but huge errors because parsing is on the wrong thread. Might need to rewrite this as it will crash the app if there's no data.
                    print(appleNewsFeed)
                } catch  {
                    print("Error parsing JSON data \(error)")
                }

            } else {
                let ac = UIAlertController(title: "No Internet Connection", message: "Please connect to WiFi or use mobile data", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                DispatchQueue.main.async {
                    self.present(ac, animated: true, completion: nil)
                    
                }
            }
            DispatchQueue.main.async { //SYNC UI WORK ON THE MAIN THREAD!!
                self.tableView.reloadData()
               // self.mainVC.refreshControl.endRefreshing()
            }

        }
        //make API call
        dataTask.resume()
    }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        
        let urlQuery = mainVC.networkManager.updateDateForAPICall(appleProduct: NetworkManager.queryType.iPhone.rawValue, date: mainVC.networkManager.currentDate)
        
        let url = URL(string: urlQuery)
        
        DispatchQueue.global(qos: .userInitiated).async {
        guard url != nil else {
            return
        } //url might be nil so this makes sure if it's nil it stops running the program
        
            let dataTask = self.mainVC.session.dataTask(with: url!) { (data, response, error) in
            //needs a closure to run the code in here to handle the data and check for errors.
            
            if error == nil && data != nil { //if no errors and data is not equal to nil
                let decoder = JSONDecoder()
                
                do {
                    let appleNewsFeed = try decoder.decode(NewsArticles.self, from: data!) //decodes data using JSON from the API here
                    
                    self.mainVC.parseJSONData(data!) //this is showing the data but huge errors because parsing is on the wrong thread. Might need to rewrite this as it will crash the app if there's no data.
                    print(appleNewsFeed)
                } catch  {
                    print("Error parsing JSON data \(error)")
                }
                
            } else {
                let ac = UIAlertController(title: "No Internet Connection", message: "Please connect to WiFi or use mobile data.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                DispatchQueue.main.async {
                    self.present(ac, animated: true, completion: nil)
                    self.mainVC.refreshControl.endRefreshing()
                }
                //self.mainVC.refreshControl.endRefreshing()
            }
            DispatchQueue.main.async { //SYNC UI WORK ON THE MAIN THREAD!!
                self.tableView.reloadData()
                self.mainVC.refreshControl.endRefreshing()
                //OK Finally refreshing. Needed to make a refresh global variable on the API class and now it gets new articles should there be any. (NEEDS REFACTOR)
                
               // self.refreshControl?.endRefreshing()
            }
            //self.tableView.reloadData()
        }
        //make API call
        dataTask.resume()
        
    }
        
    }

    func filterContentForSearchText(_ searchText: String, category: NewsArticleData? = nil) {
        mainVC.filteredArticles = mainVC.article.filter { (articles: NewsArticleData) -> Bool in
            
            return (articles.title?.lowercased().contains(searchText.lowercased())) ?? false
            
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
        //the above function was crucial to getting this in a working state.
        print(text)
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mainVC.isFiltering {
            return mainVC.filteredArticles.count
        }
        return mainVC.article.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "iPadCell", for: indexPath)
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "iPadCell")
        //don't need to use dequeueReusableCell, the above works just fine to get the data.
        var article = mainVC.article[indexPath.row]
        
        if mainVC.isFiltering {
            article = mainVC.filteredArticles[indexPath.row]
        } else {
            article = mainVC.article[indexPath.row]
        }
        
        //let subTextCell = subText[indexPath.row]
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.description //setting the I.B. tableView cell to subtitle allowed the subtitle description to show up, need to learn the programmatic way too.
  
        cell.imageView?.image = UIImage(systemName: "text.bubble") //don't need UI control state here.
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = mainVC.article[indexPath.row].url else { return }

        if let selectedLink = URL(string: url) {
            UIApplication.shared.open(selectedLink)
            
            tableView.deselectRow(at: indexPath, animated: true)
    }
}
}
