//
//  CommentRequest.swift
//  Product-Hunt-API
//
//  Created by Matthew Harrilal on 9/24/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit

struct Comments1 {
    var body: String?
    init(body: String?) {
        self.body = body
    }
}
extension Comments1: Decodable {
    enum keys: String, CodingKey {
        case body
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: keys.self)
        let body = try container.decodeIfPresent(String.self, forKey: .body) ?? "Sorry no comments"
        self.init(body: body)
    }
}
struct ProductHunt1: Decodable {
    let comments: [Comments1]
}
class CommentsRequest {
   
  
    func commentsRequest(postID: Int, completion: @escaping ([Comments1]) -> Void) {
        let session = URLSession.shared
        var customizableParamters = "posts"
        let dg = DispatchGroup()
        var url = URL(string: "https://api.producthunt.com/v1/comments")
        
        let date = Date()
        //        guard let currentDate = date else {
        //            return
        //        }
        
        let urlParams = ["search[post_id]": String(describing: postID),
                         "scope": "public",
                         "created_at": String(describing: date),
                         "per_page": "20"]
        url = url?.appendingQueryParameters(urlParams)
        
        var getRequest = URLRequest(url: url!)
        getRequest.httpMethod = "GET"
        getRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b ", forHTTPHeaderField: "Authorization")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        // Formatting the network request with the neccesary headers by using the set value methods
        
        // And we had to structure the url request such as that in order to be able to use the formatting parameters function as well as desired protocols
        var posts = [Comments1]()
        
       
        Singleton.sharedSession.dataTask(with: getRequest) { (data, response, error) in
            guard error == nil else{return}
            if let data = data {
                let producthunt = try? JSONDecoder().decode(ProductHunt1.self, from: data)
                
                guard let newPosts = producthunt?.comments else{return}
                
                posts = newPosts
                // print(producthunt)
               completion(posts)
            } else {
                
            }
            }.resume()
       
    }
       
    }

