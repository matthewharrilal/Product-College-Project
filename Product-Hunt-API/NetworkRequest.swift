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
    var body: String?
    var name: String?
    var tagline: String?
    var votes: Int?
    var imageURL: String?
    var day: String?
    var url:String?
    
    // What is the point of initalizing the data?
    init(body: String?,name: String?, tagline: String?, votesCount: Int?, imageURL: String?, day: String?, url:String?) {
        self.body = body
        self.name = name
        self.tagline = tagline
        self.votes = votesCount
        self.imageURL = imageURL
        self.day = day
        self.url = url
        
       
    }
}

extension ProductHunt: Decodable {
    // Creating  our case statements to iterate over the data in the JSON File
    
    enum additionalKeys: String, CodingKey {
        // Creating case statements that are nested within the posts list embedded with dictionaries
        case body
        case post
        case name
        case tagline
        case votes = "votes"
        case day
        case thumbnail
        case url
    }
    
    enum Posts: String, CodingKey {
        case post
    }
   
    enum  thubnailImage: String, CodingKey {
        case imageURL = "image_url"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: additionalKeys.self)
        let body = try container.decodeIfPresent(String.self, forKey: .body) ?? "The comments for this porduct are nil"
        let votes = try container.decodeIfPresent(Int.self, forKey: .votes) ?? 0
        let postContainer = try container.nestedContainer(keyedBy: additionalKeys.self, forKey: .post)
        let name = try postContainer.decodeIfPresent(String.self, forKey: .name)
        let url = try container.decodeIfPresent(String.self, forKey: .url) ?? "NO COMMENTS AVAILABLE"
        let tagline = try postContainer.decodeIfPresent(String.self, forKey: .tagline)
        let day = try postContainer.decodeIfPresent(String.self, forKey: .day) ?? "The day is not here"
         let thumbnailContainer = try? postContainer.nestedContainer(keyedBy: thubnailImage.self, forKey: .thumbnail)
       if let _ = thumbnailContainer {
        let imageURL = try thumbnailContainer?.decodeIfPresent(String.self, forKey: .imageURL) ?? "No Image"
        self.init(body: body, name: name, tagline: tagline, votesCount: votes, imageURL: imageURL, day: day, url:url)
        return
        }
        self.init(body: body, name: name, tagline: tagline, votesCount: votes, imageURL: "image", day: day, url:url)
    }
}

struct Producthunt: Decodable {
    let comments: [ProductHunt]
}

struct CommentsHunt: Decodable {
    let comments: [ProductHunt]
}
class Network {
    static func networking(completion: @escaping ([ProductHunt])-> Void) {
        
        let session = URLSession.shared
        var customizableParamters = "posts"
        let dg = DispatchGroup()
        var url = URL(string: "https://api.producthunt.com/v1/comments")
      
        let date = Date()
//        guard let currentDate = date else {
//            return
//        }
        
        let urlParams = ["search[featured]": "true",
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
        var posts = [ProductHunt]()
        
        dg.enter()
        session.dataTask(with: getRequest) { (data, response, error) in
            guard error == nil else{return}
            if let data = data {
                let producthunt = try? JSONDecoder().decode(Producthunt.self, from: data)
                
                guard let newPosts = producthunt?.comments else{return}
              
                posts = newPosts
                print(producthunt)
                print(urlParams["created_at"])
               
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



