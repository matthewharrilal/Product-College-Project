//
//  ProductFeed.swift
//  Product-Hunt-API
//
//  Created by Matthew Harrilal on 9/21/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit

class ProductHuntFeed: UITableViewController {
    var posts: String!
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
                for comment in self.posts1 {
                    print(comment.body)
                }
                self.posts1 = gatheredPosts
                self.tableView.reloadData()
            }
        }
      
       
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts1.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentProduct = posts1[indexPath.row]
        openURL(url: currentProduct.url)
        
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
        print(posts1[indexPath.row])
        if product.name != nil {
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = product.tagline
        }
        if let profileImageURL = product.imageURL {
            
                DispatchQueue.main.async {
                    
                      cell.imageView?.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                    self.tableView.reloadData()
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
