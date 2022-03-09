//
//  NewsArticleData.swift
//  AppleNewsV.1
//
//  Created by Mohammed Qureshi on 2021/06/21.
//

struct NewsArticleData: Codable {
    var title: String? //should be an optional just in case the String might be optional when parsing from the API.
    var description: String?
    var content: String?
    var publishedAt: String? // to get the date... need to use date formatter to reorder the results by the most recent first.
    let url: String? //url might not have any data.
}
 
//solved coding keys error by making the strings optional here should the value not exist, it will only load in the tableview when the value isn't nil.
