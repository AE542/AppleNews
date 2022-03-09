//
//  AppleNewsGeneralViewController.swift
//  AppleNewsV.1
//
//  Created by Mohammed Qureshi on 2022/03/07.
//

import UIKit

class AppleNewsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
  //  let refreshControl = UIRefreshControl() //Users/srx/Documents/Projects/AppleNewsV.1/AppleNewsV.1/APIViewController.swift:221:13: Cannot override mutable property 'refreshControl' of type 'UIRefreshControl?' with covariant type 'UIRefreshControl' = solved by putting in main class above.
    
    let mainVC = APIViewController()
    
    let webView = WebViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Apple News"
        navigationController?.navigationBar.prefersLargeTitles = true
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "DINAlternate-Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]
        
        
        mainVC.refreshControl.attributedTitle = NSAttributedString(string: "Pull Down to Refresh")
        mainVC.refreshControl.tintColor = .systemBlue
        mainVC.refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        //self.mainVC.navigationItem.titleView?.addSubview(mainVC.refreshControl)
        self.tableView.addSubview(mainVC.refreshControl)
        
//        mainVC.activityIndicator.color = .blue
//        mainVC.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        mainVC.activityIndicator = UIActivityIndicatorView(frame: mainVC.refreshControl.bounds, type(of: UIActivityIndicatorType ))
//        mainVC.refreshControl.addSubview(mainVC.activityIndicator)
        //don't need to invoke activity indicator just use tintColor.
        
    
        //view.addSubview(mainVC.searchBar) //this was the solution to get the search bar to show up below the title.
        
        //didn't need to create the search bar above. Just creating a search controller like below is much more simple.
        
        navigationItem.searchController = mainVC.searchController
        mainVC.searchController.searchResultsUpdater = self //The object responsible for updating the contents of the search results controller.
//THIS WAS CRUCIAL TO GETTING THE TEXT FIELD TO REGISTER TEXT!
        mainVC.searchController.obscuresBackgroundDuringPresentation = false
        mainVC.searchController.searchBar.placeholder = "Search Articles"
        definesPresentationContext = true //prevents the search bar being on screen if the user goes to another vc.
        
        let urlTest = mainVC.networkManager.updateDateForAPICall(appleProduct: NetworkManager.queryType.all.rawValue, date: mainVC.networkManager.currentDate)
        
        let url = URL(string: urlTest)
        
        let refreshControlMainVC = mainVC.refreshControl
        
        DispatchQueue.global(qos: .userInitiated).async {
        guard url != nil else {
            return
        } //url might be nil so this makes sure if it's nil it stops running the program
        //let session = URLSession.shared //we just need to access the shared urlSession, not necessary to create it.
        
            let dataTask = self.mainVC.session.dataTask(with: url!) { (data, response, error) in
            //needs a closure to run the code in here to handle the data and check for errors.
            var errorMessage: String?
            
            if error == nil && data != nil { //if no errors and data is not equal to nil
                
                errorMessage = error?.localizedDescription
                
                let decoder = JSONDecoder()
                
                do {
                    let appleNewsFeed = try decoder.decode(NewsArticles.self, from: data!) //decodes data using JSON from the API here
                    
                    self.mainVC.parseJSONData(data!) //this is showing the data but huge errors because parsing is on the wrong thread. Might need to rewrite this as it will crash the app if there's no data.
                    print(appleNewsFeed)
                } catch  {
                    print("Error parsing JSON data \(error)")
                    
                    errorMessage = error.localizedDescription
                }
                
            } else {
                
                let ac = UIAlertController(title: "No Internet Connection", message: "Please connect to WiFi or use mobile data", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                DispatchQueue.main.async {
                    self.present(ac, animated: true, completion: nil)
                }
                //isn't triggering...A FEW MONTHS LATER NOW IT IS!! Make sure the presentation is on the main thread.
            }
            DispatchQueue.main.async { //SYNC UI WORK ON THE MAIN THREAD!!
                [weak self] in
                guard let self = self else { return }
                
                if let errorMessage = errorMessage {
                    self.showError(errorMessage)
                }
                
                self.tableView.reloadData()
                refreshControlMainVC.endRefreshing()
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

    
    private func showError(_ message: String) {
        let title = "Network Error"
        print("\(title): \(message)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okButton)
        alert.preferredAction = okButton
        present(alert, animated: true)
    }
   
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "No Results")
        //the above function was crucial to getting this in a working state.
        print(text)
        
    } //this is refreshing the data at too fast a rate. Because it's making calls everytime you stop typing! Not what I wanted...
    
    @objc func refresh(_ sender: AnyObject) {
        
        let urlCall = mainVC.networkManager.updateDateForAPICall(appleProduct: NetworkManager.queryType.all.rawValue, date: mainVC.networkManager.currentDate)
        
        let url = URL(string: urlCall)
        
        DispatchQueue.global(qos: .userInitiated).async {
        guard url != nil else {
            return
        } //url might be nil so this makes sure if it's nil it stops running the program
       //let session = URLSession.shared //we just need to access the shared urlSession, not necessary to create it.
        
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
                
                let ac = UIAlertController(title: "No Internet Connection", message: "Please connect to WiFi or use mobile data", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                DispatchQueue.main.async {
                    self.present(ac, animated: true, completion: nil)
                }
                //isn't triggering...A FEW MONTHS LATER NOW IT IS!! Make sure the presentation is on the main thread.
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
        //present(WebViewController as?, animated: true, completion: nil)
        
        
        guard let url = mainVC.article[indexPath.row].url else { return }
        
        if let selectedLink = URL(string: url) {
            UIApplication.shared.open(selectedLink)
            //present(webView, animated: true, completion: nil) //this is showing the webView but nothing in it
            
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
