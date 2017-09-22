//
//  ProductFeed.swift
//  Product-Hunt-API
//
//  Created by Matthew Harrilal on 9/21/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit

struct Products {
    var body: String?
    init(body: String?) {
        self.body = body
    }
}
extension Products: Decodable {
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
    let comments: [Products]
}

class ProductHuntFeed: UITableViewController {
//    var posts: String!
    
    var products: ProductHunt?
    var posts1: [ProductHunt] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        //        Network.networking { (postz) in
        //            for post in postz {
        //                print(post)
        //            }
        //        }
        DispatchQueue.main.async {
            Network.networking { (gatheredPosts) in
               
                self.posts1 = gatheredPosts
                self.tableView.reloadData()
            }
        }
        
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts1.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let currentProduct = posts1[indexPath.row]
        //        openURL(url: currentProduct.url)
        Network.networking { (gatheredPosts) in
            let indexPath = tableView.indexPathForSelectedRow!
            let currentCell = tableView.cellForRow(at: indexPath)! as! UITableViewCell
            let product = self.posts1[indexPath.row]
            print(product)
            let postId = product.postID
           let session = URLSession.shared
            var url = URL(string: "https://api.producthunt.com/v1/comments")
            
            let date = Date()
            //        guard let currentDate = date else {
            //            return
            //        }
            
            let urlParams = ["search[post_id]": "\(postId)",
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
            
            session.dataTask(with: getRequest, completionHandler: { (data, response, error) in
                if let data = data {
                    let productHunt = try? JSONDecoder().decode(ProductHunt1.self, from: data)
                    print(productHunt)
                }
            }).resume()
        }
        

        
    }
    
    func openURL(url: String!) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let product = posts1[indexPath.row]
        print(product)
        //        print(posts1[indexPath.row])
        if product.name != nil {
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = product.tagline
        }
        if let profileImageURL = product.imageURL {
            
            DispatchQueue.main.async {
                
                cell.imageView?.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                
            }
            
            
            
            
            //            let url = URL(string: profileImageURL)
            //            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            //                if error != nil {
            //                    print(error)
            //                    return
            //                }
            //                DispatchQueue.main.async {
            //                    cell.imageView?.image = UIImage(data: data!)
            //
            ////                    self.tableView.reloadData()
            ////                    print(response)
            //                }
            //            }).resume()
        }
        
        //self.tableView.reloadData()
        return cell
    }
    
}
