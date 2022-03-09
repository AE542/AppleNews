//
//  NewsArticles.swift
//  AppleNewsV.1
//
//  Created by Mohammed Qureshi on 2021/06/21.
//
import Foundation
//import UIKit

struct NewsArticles: Codable { //type that can convert itself in and out of external representation.
    var status = "" //all articles have a status string but it could be nil.
    
    var totalResults: Int = 0 // prints the number of results returned by the API.
  
    //var description = ""
    
   //var publishedAt: String
    
    var articles: [NewsArticleData] //Article could be nil on the site so needs to be an optional.
    //don't forget vars are supposed to be the same as that of the JSON data's vars on the newsAPI site.
    //NewsArticles(status: "ok", totalResults: 2481, results: nil) printed... because it was optional...
    
//    enum CodingKeys: String, CodingKey {
//        case totalResults = "totalResults"
//    }
}
