//
//  ViewController.swift
//  Product-Hunt-API
//
//  Created by Matthew Harrilal on 9/20/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

struct ProductHunt {
    // Modeling the properties we want back from the JSON Data
    var name: String?
    var tagline: String?
    var votesCount: Int?
    var imageURL: String?
    var day: String?
    var body: String?
    var createdAt: String?
    // What is the point of initalizing the data?
    init(name: String?, tagline: String?, votesCount: Int?, imageURL: String?, day: String?, body: String?, createdAt: String?) {
        self.name = name
        self.tagline = tagline
        self.votesCount = votesCount
        self.imageURL = imageURL
        self.day = day
        self.body = body
        self.createdAt = createdAt
    }
}

extension ProductHunt: Decodable {
    // Creating  our case statements to iterate over the data in the JSON File
    enum additionalKeys: String, CodingKey {
        // Creating case statements that are nested within the posts list embedded with dictionaries
        case name
        case tagline
        case votesCount = "votes_count"
        case day
        case thumbnail
    }
    
    enum comments: String, CodingKey {
        case body
        case createdAt = "created_at"
    }
    
    enum thumbnailImage: String, CodingKey {
        // Creating a case statement for the image url nested in within the thumbnail dictionary
        case imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: additionalKeys.self)
        let commentsContainer = try decoder.container(keyedBy: comments.self)
        let body = try commentsContainer.decodeIfPresent(String.self, forKey: .body) ?? "There are no comments for this product"
        let createdAt = try commentsContainer.decodeIfPresent(String.self, forKey: .createdAt) ?? "The date of creating for these comments is unavailable"
        let thumbnailContainer = try container.nestedContainer(keyedBy: thumbnailImage.self, forKey: .thumbnail )
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? "The name of this product is not available"
        let tagline = try container.decodeIfPresent(String.self, forKey: .tagline) ?? "The tagline for this product is not available"
        let votesCount = try container.decodeIfPresent(Int.self, forKey: .votesCount) ?? Int("The number of votes for this product is not available")
        let day = try container.decodeIfPresent(String.self, forKey: .day) ?? "The day this product was created on is not available"
        
        let imageUrl = try thumbnailContainer.decodeIfPresent(String.self, forKey: .imageURL)
        self.init(name: name, tagline: tagline, votesCount: votesCount, imageURL: imageUrl, day: day, body: body, createdAt: createdAt)
    }
}

struct Producthunt: Decodable {
    let posts: [ProductHunt]
}

struct CommentsHunt: Decodable {
    let comments: [ProductHunt]
}
class Network {
    static func networking(completion: @escaping ([ProductHunt])-> Void) {
        
        let session = URLSession.shared
        var customizableParamters = "posts"
        let dg = DispatchGroup()
        var url = URL(string: "https://api.producthunt.com/v1/posts")
        var commentsURL = URL(string: "https://api.producthunt.com/v1/comments")
        
        let urlParams = ["search[featured]": "true",
                         "scope": "public"]
        url = url?.appendingQueryParameters(urlParams)
        commentsURL = commentsURL?.appendingQueryParameters(urlParams)
         var commentsRequest = URLRequest(url: commentsURL!)
        commentsRequest.httpMethod = "GET"
        commentsRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b ", forHTTPHeaderField: "Authorization")
        commentsRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        commentsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        commentsRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        var getRequest = URLRequest(url: url!)
        getRequest.httpMethod = "GET"
        getRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b ", forHTTPHeaderField: "Authorization")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        // Formatting the network request with the neccesary headers by using the set value methods
        
        // And we had to structure the url request such as that in order to be able to use the formatting parameters function as well as desired protocols
        var posts = [ProductHunt]()
        var postsz = [ProductHunt]()
        dg.enter()
        session.dataTask(with: getRequest) { (data, response, error) in
            guard error == nil else{return}
            if let data = data {
                let producthunt = try? JSONDecoder().decode(Producthunt.self, from: data)
                let commentsHunt = try? JSONDecoder().decode(CommentsHunt.self, from: data)
                guard let newPosts = producthunt?.posts else{return}
                guard let newPosts1 = commentsHunt?.comments else{return}
                postsz = newPosts1
                posts = newPosts
                print(producthunt)
                print(commentsHunt)
                dg.leave()
            } else {
                dg.leave()
            }
            }.resume()
        dg.notify(queue: .main, execute:
            {
                completion(posts)
                
        })
    }
}


// We are essentially giving the ability to implement parameters in the dictionary succesfully

extension URL {
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
    // This is formatting the query parameters with an ascii table reference therefore we can be returned a json file
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}


extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}



