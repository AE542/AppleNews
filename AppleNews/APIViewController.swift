//
//  ViewController.swift
//  AppleNewsV.1
//
//  Created by Mohammed Qureshi on 2021/06/21.
//

//2021/06/22
//Data is now loading in Tab Bar as I wanted. Adding the parse func to the FirstVC allowed the data to populate the tableView. GOOD! Now need to add each collections of news articles to each tableView.
//The problem is that this method is very crude and this code is all in need of a refactor. Look into class inheritance seperate the classes into their own class, write a NetworkManager class to handle JSON data. Needs updated number of articles in badge. Perhaps a search function for articles (Need UISearchBar). Also need to learn how to load the data in a WebView instead of using shared application to load in Safari (WebView). Need to also handle app and prevent crashes when there is no network connection.
//2021/06/23 Data still loading surprisingly but needs refactor. Watch Table not loading data but fixed problem where it was showing a blank vc instead of a tableVC. Possibly a problem with reloading the tableViewData in viewDidLoad. OK now Watch tableView is loading, because the class was set to type UIVIEWCONTROLLER not tableView which it should have been.
//2021/06/25 OK time to try and get the webView to load the urls when the tableViewCell is selected. Also try and see if you can add the drag down to refresh function on the table view.
//Not able to load the webview...missing URL but don't want to load it as a HTML text file with just the body.
//2021/06/27 Attempting to put pull to refresh on the tableView. Is coming up was missing tableView.addSubView but crashed because unrecognized selector sent to instance. Need to get the parse code into its own function and return the tableview data from the API.
//2021/06/30 Ok today need to add UIsearchbar to go through each news item and return only the selected instances in the tableview. Also still need to add the WebView so do some reading/YouTube to find out how to do it properly. Need's to change text colour in dark mode for the navigation title. Also get badges to show number of articles.
//2021/07/02 UISearchBar is added but need to make the filter work for the JSON titles of the articles and return them. Also webView is showing...but with no webpages!(Least its not coming back nil) -> You needed to add the configuration and preferences to get it to show correctly. Now need to get the actual window to show up in the webview. Making a private let in the WKWebView class to handle initialising the webview was the missing piece.
//2021/07/10 Still having trouble loading websites in WKWebView. After doing some reading, might be able to refactor all the other view controllers down to something really simple using class inheritance. Attempting to do so with the iPhone VC.

//2021/07/25 FINALLY figured out why I was getting a totalResults Int value = nil error Using the NewsAPI website {
//"status": "error",
//"code": "parameterInvalid",
//"message": "You are trying to request results too far in the past. Your plan permits you to request articles as far back as 2021-06-24, but you have requested 2021-06-15. You may need to upgrade to a paid plan."

//and this error: Error parsing JSON data keyNotFound(CodingKeys(stringValue: "totalResults", intValue: nil), Swift.DecodingError.Context(codingPath: [], debugDescription: "No value associated with key CodingKeys(stringValue: \"totalResults\", intValue: nil) (\"totalResults\").", underlyingError: nil)

//to solve this it was simply changing the date in the URL to something more current. changed to this month and now the data loads exactly as I want it. CHECK THE URL THROUGH THE NEWSAPI APP TO SEE THE JSON FILE ON THE NET! IT WILL TELL YOU IF THERE IS AN ERROR!

//2021/11/08 Ok so this app is in desperate need of refactoring and testing also. It still works despite a few problems. So will refactor network calls and create a fake network model to test from. Remember, its better to make a fake model to test as trying to test the original model is a difficult dependency to test. You also really need to make a network manager class to make this work better.

//2021/11/15 Added some code to get calls from the search bar when it has text input, but it is making too many API calls. Need another approach.

//2022/01/17 Ok managed to get the ac to show up when there's no internet connection! Check out the debug navigator when thread crashes happen and make sure that presentation is on the main thread using GCD.

//2022/02/03 FINALLY! You can now search through each article and filter by article name!! YES!!!! UISearchResultsUpdating was the key to get this working!

import UIKit
import WebKit

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    //remember to decouple the URLSession for testing.
}

class APIViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WKUIDelegate  {
 
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "iPadCell")
        return table
    }()
    
   let searchController = UISearchController()
   var searchBar: UISearchBar = UISearchBar()
    //create lazy var (only called when initialised)
    
    var urlSession: URLSessionProtocol = URLSession.shared //create a singleton for testing...also good for refactoring in this app.
    
    var article = [NewsArticleData]()
 
    var filteredArticles: [NewsArticleData] = [] //create an empty instance of newsArticle data
    
    //practice with a computed property here
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true //returns true if the text bar is empty. If not returns false
    } //computed property
    
    //let newsArticle = [NewsArticle]()
    
    var searchArticles = [NewsArticles].init()
    
    var newsArticles = [NewsArticles]()
    
    
    //var networkManager = NetworkManager() // THIS WAS CAUSING THE APP TO HANG DON'T CALL THIS HERE!

    //need to do some more reading about best practices with handling API keys. Maybe making it a private static let or making it its own file in an enum and give it a coding key?
    //have to set it to private but can use set and make it a var to test with the apiKey.
    
    let session = URLSession.shared
    
    let networkManager = NetworkManager()
    
    let refreshControl = UIRefreshControl()
    
    let activityIndicator = UIActivityIndicatorView()
    
    //let webView = UIWebView() //init webview
    
    var progressView: UIProgressView! //we need this to tell the user that a window is actually loading.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        //searchController.delegate = self
        view.addSubview(tableView)
      
            title = "Apple News"
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "DINAlternate-Bold", size: 20)!]
            navigationController?.navigationBar.titleTextAttributes = textAttributes as [NSAttributedString.Key : Any]

        
        let urlCall = networkManager.updateDateForAPICall(appleProduct: NetworkManager.queryType.all.rawValue, date: networkManager.currentDate)
        
            
        _ = URL(string: urlCall)
            
            DispatchQueue.global(qos: .userInitiated).async {
                
               
//            guard url != nil else {
//                return
//            } //url might be nil so this makes sure if it's nil it stops running the program
//                let session = self.urlSession //we just need to access the shared urlSession, not necessary to create it. //provides a shared singleton session object that gives you a reasonable default behavior for creating tasks. Use the shared session to fetch the contents of a URL to memory with just a few lines of code.
//                let request = URLRequest(url: url!)
//
//            let dataTask = session.dataTask(with: request) { (data, response, error) in
//                //needs a closure to run the code in here to handle the data and check for errors.
//
//                if error == nil && data != nil { //if no errors and data is not equal to nil
//                    let decoder = JSONDecoder()
//
//                    do {
//                        let appleNewsFeed = try decoder.decode(NewsArticles.self, from: data!) //decodes data using JSON from the API here
//
//                        self.parseJSONData(data!) //this is showing the data but huge errors because parsing is on the wrong thread. Might need to rewrite this as it will crash the app if there's no data.
//                        print(appleNewsFeed)
//                    } catch  {
//                        print("Error parsing JSON data \(error)")
//
//                    }
//
//                } else {
//
//                    let ac = UIAlertController(title: "No Internet Connection", message: "Please connect to WiFi or use mobile data", preferredStyle: .alert)
//                    ac.addAction(UIAlertAction(title: "OK", style: .default))
//
//                    DispatchQueue.main.async {
//                        self.present(ac, animated: true, completion: nil)
//                    }
//                    //isn't triggering...A FEW MONTHS LATER NOW IT IS!! Make sure the presentation is on the main thread.
//                }
//                DispatchQueue.main.async { //SYNC UI WORK ON THE MAIN THREAD!!
//                    self.tableView.reloadData()
//                }
//                //self.tableView.reloadData()
//            }
//            //make API call
//                dataTask.resume() // you MUST add resume otherwise the dataTask won't run a new task as they start by default in a suspended state.
            
           // self.tableView.reloadData()

                DispatchQueue.main.async {

                let tabBarVC = UITabBarController() //init here
                
                let vc1 = UINavigationController(rootViewController: AppleNewsTableViewController()) //need to set the vc as the root vc.
//                vc1.title = "Apple News"
                let vc2 = UINavigationController(rootViewController: iPhoneTableViewController())
                vc2.title = "iPhone News"
                let vc3 = UINavigationController(rootViewController: iPadTableViewController())
                vc3.title = "iPad News"
                let vc4 = UINavigationController(rootViewController: MacTableViewController())
                vc4.title = "Mac News"
                let vc5 = UINavigationController(rootViewController: WatchTableViewController())
                vc5.title = "Watch News"
                //init the vc's in did tap button add to array below
                tabBarVC.setViewControllers([vc1, vc2, vc3, vc4, vc5], animated: false) //sets root vcs of tabbar controller use empty array so we can set all the vcs
                
                //To get the tab bar items to show in the vc, we can create the items here unwrap them in a guard let as they're optionals, then create an array to init each item.
                
                    //tabBarVC.setViewControllers([vc1], animated: false)
                    
                    //Thread 1: "adding a root view controller <AppleNewsV_1.ViewController: 0x7ff8fe507480> as a child of view controller:<UINavigationController: 0x7ff900846400>"
                    
                guard let items = tabBarVC.tabBar.items else {
                    return
                }
                
                let images = ["applelogo", "iphone", "ipad", "desktopcomputer", "applewatch.watchface"]
                //should just be the system names as an array of strings.
                //we can loop through all the images in items to find the ones we want. a little complicated but you needed to have i as a placeholder then loop through all of the images with 0 up to items.count to find the right ones then create an items array with all the images.
                
                for i in 0 ..< items.count {
                    
                    //you can even set up badges like with notifications to show new entries in a JSON feed for example
                    
                    //items[i].badgeValue = "\(self.newsArticles.count)" newsarticles is an optional here so is just returning a number.
                    //need to return total results as a number for the badge.
                    items[i].badgeColor = .blue
                    //why was this in an array? because items is an array of UITabBar items
                    items[i].image = UIImage(systemName: images[i]) //No exact matches in call to initializer  = here it means missing systemName.
                }
                
                tabBarVC.modalPresentationStyle = .fullScreen
                //modal vc just like in storyboards
                
                self.present(tabBarVC, animated: true) //just like when declaring alert controllers.
            }
                
            }
        
        
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds //goes to edges of screen
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return article.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "iPadCell")
        //don't need to use dequeueReusableCell, the above works just fine to get the data.
        let article = article[indexPath.row]
        
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.description //setting the I.B. tableView  cell to subtitle allowed the subtitle description to show up, need to learn the programmatic way too.
  
        cell.imageView?.image = UIImage(systemName: "text.bubble") //don't need UI control state here.
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = article[indexPath.row].url else { return }
        if let selectedLink = URL(string: url) {
            UIApplication.shared.open(selectedLink)

            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    }

   func parseJSONData(_ data: Data) {
        let decoder = JSONDecoder()
     
        if let decodedData = try?decoder.decode(NewsArticles.self, from: data) { //decode throws needs to be in a do catch block
            
            //let articleTitle = decodedData.title
            self.article = decodedData.articles
            
            DispatchQueue.main.async {
            self.tableView.reloadData()
            }

        }
        
    }
    
    func loadWebView(url: URL) {
        let myWebView: WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        myWebView.uiDelegate = self
        self.view.addSubview(myWebView)
        
    }
    
    
//    class AppleNewsTableViewController: UITableViewController, WKUIDelegate, UISearchBarDelegate, UISearchResultsUpdating
    //used to be nested class. Now giving it its own class.
}

class WebViewController: UIViewController, WKNavigationDelegate {
    //Methods for accepting or rejecting navigation changes, and for tracking the progress of navigation requests.
    
    private let webView: WKWebView = { //circular reference error = can't make the var name the same as the class name here. Optional as there might not be a webview.
        //use a private let in this class so it can only be accessed here.
   // var newsArticleView = NewsArticleData.self
   // let mainVC = APIViewController()
    let webPreferences = WKWebpagePreferences() //should be WKPreferences and not WKWebPreferences
        webPreferences.allowsContentJavaScript = true
        //WKPreferences was deprecated so have to use WKWebpage instead.
        let configuration = WKWebViewConfiguration()
        //configuration.preferences = webPreferences
        configuration.defaultWebpagePreferences = webPreferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    
    }()
    
    
    //this was the correct way to get init the webview. Small thing missing was the let webView = WebView with config. This is why you were getting a nil error below.
    
    let mainVC = APIViewController()
    let newsArticle = NewsArticleData(url: "www.google.com")
    
    var newsArticleItem: NewsArticleData?
    
//    override func loadView() {
//        //view.addSubview(webView)
//        view = webView
//        title = "Current Article"
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Current Article"
        view = webView
        webView.navigationDelegate = self //The object you use to manage navigation behavior for the web view. We need this to restrict any navigation of the webview and have it only show the article selected.

        guard let newsArticleURL = newsArticleItem?.url else { return }
       // webView.loadURL(newsArticleURL)
        print(newsArticleURL)
        if let url = URL(string: newsArticleURL) {
            //string: newsArticle.url ?? "www.apple.com" not loading anything
                let request = URLRequest(url: url)
            webView.load(request)

        }
        
        //webView.loadURL(newsArticle.url ?? "https://www.google.com") //we can create an extension to handle this instead.
        
        //just nothing...its not loading at all even when the optionals are unwrapped...
        
        
        //creating newsArticlData inside the view did load found the url value...had this problem before when trying to access structs.
//            let url = URL(string: newsArticleData)
//            webView.load(URLRequest(url: url!))
        //found nil because there's no WKWebView.
       // guard let url = URL(string: article.)
        //let tableView = UITableView()
        //guard let url = mainVC.article else { return }
        
        //let indexPath =
        //guard let url = mainVC.article.url else { return }
      // guard let url = URL(string: newsArticles.url) else { return }
        // guard let url = URL(string: mainVC.baseURL + mainVC.apiKey) else { return }
        //LOADS THE JSON DATA NOT WHAT YOU WANT!!! USE YOUR BRAIN!
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
}


//MARK: - AppleNewsVC


//MARK: - iPhone News Controller

//Moved its own Swift file.

//MARK: - iPad Table View Controller

//MARK: - Mac TableView Controller

//MARK: - Watch News TableViewController


extension URLSession: URLSessionProtocol { } //define the extension here.

extension WKWebView {
    func loadURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            //string: newsArticle.url ?? "www.apple.com" not loading anything
                let request = URLRequest(url: url)
            load(request)
            
        }
    }
}


//extension UISearchController: UISearchBarDelegate {
//    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let searchBar = searchBar.text else { return
//
//            print(searchBar.text ?? "Not Printing") //bp not triggering
//        }
//        print(searchBar)
//    }
//
//}

