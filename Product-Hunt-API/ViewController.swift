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
        let network1 = Network()
        print(network1.networking())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

struct ProductHunt {
    // Modeling the properties we want back from the JSON Data
    let name: String?
    let tagline: String?
    let votesCount: Int?
    let imageURL: String?
    // What is the point of initalizing the data?
    init(name: String?, tagline: String?, votesCount: Int?, imageURL: String?) {
        self.name = name
        self.tagline = tagline
        self.votesCount = votesCount
        self.imageURL = imageURL
    }
}

extension ProductHunt: Decodable {
    // Creating  our case statements to iterate over the data in the JSON File
    enum additionalKeys: String, CodingKey {
        // Creating case statements that are nested within the posts list embedded with dictionaries
        case name
        case tagline
        case votesCount = "votes_count"
        case thumbnail
    }
    
    
    enum thumbnailImage: String, CodingKey {
        // Creating a case statement for the image url nested in within the thumbnail dictionary
        case imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: additionalKeys.self)
        let thumbnailContainer = try container.nestedContainer(keyedBy: thumbnailImage.self, forKey: .thumbnail )
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? "The name of this product is not available"
        let tagline = try container.decodeIfPresent(String.self, forKey: .tagline) ?? "The tagline for this product is not available"
        let votesCount = try container.decodeIfPresent(Int.self, forKey: .votesCount) ?? Int("The number of votes for this product is not available")
        
        let imageUrl = try thumbnailContainer.decodeIfPresent(String.self, forKey: .imageURL)
        self.init(name: name, tagline: tagline, votesCount: votesCount, imageURL: imageUrl)
    }
}

struct Producthunt: Decodable {
    let posts: [ProductHunt]
}

class Network {
    
    
    func networking() {
        let session = URLSession.shared
        var url = URL(string: "https://api.producthunt.com/v1/posts")
        let urlParams = ["search[featured]": "true",
                         "scope": "public"]
        url = url?.appendingQueryParameters(urlParams)
        var getRequest = URLRequest(url: url!)
        getRequest.httpMethod = "GET"
        getRequest.setValue("Bearer affc40d00605f0df370dbd473350db649b0c88a5747a2474736d81309c7d5f7b ", forHTTPHeaderField: "Authorization")
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        getRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        getRequest.setValue("api.producthunt.com", forHTTPHeaderField: "Host")
        
        
        session.dataTask(with: getRequest) { (data, response, error) in
            if let data = data {
                let producthunt = try? JSONDecoder().decode(Producthunt.self, from: data)
                print(producthunt)
            }
            }.resume()
    }
}

extension URL {
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
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

