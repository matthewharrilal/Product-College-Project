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

let session = URLSession.shared

struct ProductHunt {
    // Modeling the properties we want back from the JSON Data
    var name: String?
    var tagline: String?
    var votes: Int?
    var imageURL: String?
    var day: String?
    var postID: Int
    
    // What is the point of initalizing the data?
    init(name: String?, tagline: String?, votesCount: Int?, imageURL: String?, day: String?, postID: Int) {
        
        self.name = name
        self.tagline = tagline
        self.votes = votesCount
        self.imageURL = imageURL
        self.day = day
        self.postID = postID
    }
}

extension ProductHunt: Decodable {
    enum postsLayer: String, CodingKey {
        case posts
    }
    
    enum additionalKeys: String, CodingKey {
        // Creating case statements that are nested within the posts list embedded with dictionaries
        
        
        case name
        case tagline
        case votes = "votes"
        case day
        case thumbnail
        case postID = "id"
    }
    
    enum Thumbnail: String, CodingKey {
        case imageURL = "image_url"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: additionalKeys.self)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let tagline = try container.decodeIfPresent(String.self, forKey: .tagline)
        let votes = try container.decodeIfPresent(Int.self, forKey: .votes) ?? 0
        let day  = try container.decodeIfPresent(String.self, forKey: .day)
        let postID = try container.decode(Int.self, forKey: .postID)
        let thumbnailContainer = try? container.nestedContainer(keyedBy: Thumbnail.self, forKey: .thumbnail)
        if let _ = thumbnailContainer {
            let imageURL = try thumbnailContainer?.decodeIfPresent(String.self, forKey: .imageURL) ?? "No image"
            self.init(name: name, tagline: tagline, votesCount: votes, imageURL: imageURL, day: day, postID: postID)
            return
            
        }
        self.init(name: name, tagline: tagline, votesCount: votes, imageURL: "image", day: day, postID: postID)
        
    }
}
struct Producthunt: Decodable {
    let posts: [ProductHunt]
}

struct CommentsHunt: Decodable {
    let comments: [ProductHunt]
}

class Singleton {
    static let sharedSession = URLSession.shared
    private init() {}
}

//protocol  NetworkProtocol {
//    func go(decodableObjectEntry: Decodable ,urlParameters: [String: String], completionHandler: (NetworkResponse) -> ())
//}
//
//enum NetworkResponse {
//    case Success(response: String)
//    case Failure(error: Error)
//    // Implementing the case statements for the response of the network when we make our network calls
//}
//
//enum Network: NetworkProtocol {
//    case GET(url: URL)
//    func go(decodableObjectEntry: Decodable, urlParameters: [String : String], completionHandler: (NetworkResponse) -> ()) {
//        switch self {
//        case .GET(let url):
//            url.appendingQueryParameters(urlParameters)
//            var getRequest = URLRequest(url: url)
//            getRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b ", forHTTPHeaderField: "Authorization")
//            getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//            getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            getRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
//            Singleton.sharedSession.dataTask(with: getRequest, completionHandler: { (data, response, error) in
//                guard error == nil else{return}
//                if let data = data {
//                    let producthunt = try? JSONDecoder().decode(decodableObjectEntry, from: data)
//                }
//            })
//        }
//
//    }
//
//}

// This is how we should start structuring our networking layer from now on it is cleaner and easier for others that are new to your code to read


enum Route {
    // So essentially what we are doing here is declaring the possible routes that can be taken while making these network requests
    case posts
    case comments(postID: Int)
    
    // Now that we have the endpoints we are going to use a function to iterate over the posssible endpoints that can be taken therefore the ones we have already declared
    
    // and the reason we have to use a switch statement is because we you cant actually implement cases until they are in a switch statement
    func path() -> String {
        switch self {
        case .posts:
            return "/posts"
            
        // Since these are the endpoints of the full url that are attached to the base url we do not have to give the case the specific post id because during this point in time what we are essentially doing is that we are just attaching these endpoints to the base url and not getting the specific post
        case .comments:
            return "/comments"
        }
    }
    
    // But see the reason we are using an enum because we are representing a finite amount of data as well as it contributes to a cleaner network abstraction layer therefore it is better to use
    func urlHeaders() -> [String: String] {
        var urlHeaders = ["Authorization": "Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b",
                          "Accept": "application/json",
                          "Content-Type": "application,json",
                          "Host": "api.producthunt.com"]
        return urlHeaders
        
        // The reason this function differs from our url parameter functions is due to the simple reason no matter what endpoint the user decides to see the headers are always the same therefore we can disregard it
    }
    
    func urlParams() -> [String: String] {
         let date = Date()
        switch self {
        case .posts:
            var postParameters = ["search[featured]": "true",
                                  "scope": "public",
                                  "created_at": String(describing: date),
                                  "per_page": "20"]
            return postParameters
            
    // And the reason that here we have to implement the post id for this comments case is due to we are not concerned with something as benign as the endpoints this is actually when the user decides to go on a specific route and the user is going to need specific parameters to get there
        case .comments(let postID):
            var commentsParameters = ["search[post_id]": "\(postID)",
                                      "scope": "public",
                                      "created_at": String(describing: date),
                                      "per_page": "20"]
            return commentsParameters
        }
    }
}

// In this class this is essentially where we put our network requests and since
class Networking {
    
    static let instance = Networking()
    // We are always just have to call never create an object off of this class therefore
    
    var baseURL: String = "https://api.producthunt.com/v1"
    
    // This is the function that determines the path that we are going to be taking of course depending on where the function will be called
    func fetch(route: Route, completionHandler: @escaping (Data) -> Void) {
        var fullUrlString = URL(string: baseURL.appending(route.path()))
        fullUrlString = fullUrlString?.appendingQueryParameters(route.urlParams())
        
        // Urls have parameters while url requests have header methods as well as in general https methods
        
        var getReuqest = URLRequest(url: fullUrlString!)
        getReuqest.allHTTPHeaderFields = route.urlHeaders()
        
        
        Singleton.sharedSession.dataTask(with: getReuqest) { (data, response, error) in
            if let data = data {
                completionHandler(data)
            }
        }
        
    }
 
}



class Network {
    
    static func networking(completion: @escaping ([ProductHunt])-> Void) {
        
        
        let session = URLSession.shared
        var customizableParamters = "posts"
        let dg = DispatchGroup()
        var url = URL(string: "https://api.producthunt.com/v1/posts")
        
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
        
        
        Singleton.sharedSession.dataTask(with: getRequest) { (data, response, error) in
            guard error == nil else{return}
            if let data = data {
                let producthunt = try? JSONDecoder().decode(Producthunt.self, from: data)
                
                guard let newPosts = producthunt?.posts else{return}
                
                posts = newPosts
                // print(producthunt)
                completion(posts)
            }
            }.resume()
        
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



