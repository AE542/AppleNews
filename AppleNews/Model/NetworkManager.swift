//
//  NetworkManager.swift
//  AppleNewsV.1
//
//  Created by Mohammed Qureshi on 2021/07/12.
//

//2022/01/16 For some reason this network manager was causing the app to hang when it loaded. some major problem because the app wouldn't load at all.

//import Foundation
import UIKit
////
//////
//protocol URLSessionProtocol {
//    func dataTask(with request: URLRequest, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
//    //remember to decouple the URLSession for testing.
//}

class NetworkManager {

//let mainVC = APIViewController()

let urlString = URL(string: String())
    
let session = URLSession.shared

var currentDate = "2022-02-20"
    
    //var date = Date(timeInterval: <#T##TimeInterval#>, since: <#T##Date#>)

    let constants = Constants()
    
    enum queryType: String {
        //remember to add type
        case all = "iPhone+iPad+Mac"
        case iPhone = "iPhone"
        case iPad = "iPad+Pro+Air"
        case mac = "MacBook+Pro+Air+M1"
        case watch = "Apple+Watch+Series"
    }

    func updateDateForAPICall(appleProduct: String, date: String) -> String {
        let baseURL = "https://newsapi.org/v2/everything?q=\(appleProduct)&from=\(date)&language=en&sortBy=publishedAt&"

        let apiKey = constants.apiKey
        //need APIKey from NewsAPI to run this project if cloning.

        let result = baseURL + apiKey
       // print(result)

        return result
    }

//    func getData(url: URL?) {
//
//guard url != nil else {
//    return
//} //url might be nil so this makes sure if it's nil it stops running the program
//
//
////let session = URLSession.shared //we just need to access the shared urlSession, not necessary to create it.
////        DispatchQueue.main.async {
////            let mainVC = APIViewController()
////        }
//        //let mainVC = APIViewController()
//        let dataTask = session.dataTask(with: url!) { (data, response, error) in
//        //solved the No exact matches in call to instance method 'dataTask' by creating a global let as a URL string and then passing it inside the param above. Still needs testing to see if it makes the right calls on each VC.
//
//    //needs a closure to run the code in here to handle the data and check for errors.
//
//    if error == nil && data != nil { //if no errors and data is not equal to nil
//        let decoder = JSONDecoder()
//
//        do {
//            let appleNewsFeed = try decoder.decode(NewsArticles.self, from: data!) //decodes data using JSON from the API here
//
//            self.mainVC.parseJSONData(data!) //this is showing the data but huge errors because parsing is on the wrong thread. Might need to rewrite this as it will crash the app if there's no data.
//            print(appleNewsFeed)
//        } catch  {
//            print("Error parsing JSON data \(error)")
//        }
//
//    }
//    DispatchQueue.main.async { //SYNC UI WORK ON THE MAIN THREAD!!
//        self.mainVC.tableView.reloadData()
//        self.mainVC.refreshControl.endRefreshing()
//        //OK Finally refreshing. Needed to make a refresh global variable on the API class and now it gets new articles should there be any. (NEEDS REFACTOR)
//
//       // self.refreshControl?.endRefreshing()
//    }
//    //self.tableView.reloadData()
//}
////make API call
//dataTask.resume()
//
//
//}

}
