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
    //    var posts: String!
    
    var products: ProductHunt?
    
    var posts1: [ProductHunt] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
 
    override func viewDidLoad() {
        //        Network.networking { (postz) in
        //            for post in postz {
        //                print(post)
        //            }
        //        }
        
//
//        Network.networking { (gatheredPosts) in
//            self.posts1 = gatheredPosts
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
        
   let network1 = Networking()
        network1.fetch(route: Route.posts) { (allPosts) in
            
            let producthunt = try? JSONDecoder().decode(Producthunt.self, from: allPosts)
            print(producthunt)
            
            guard let newPosts = producthunt?.posts else{return}
            self.posts1 = newPosts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
     
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts1.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let commentsTVC = storyboard.instantiateViewController(withIdentifier: "Comments") as! Comments
        let post = posts1[indexPath.row]
        commentsTVC.postID = post.postID
        navigationController?.pushViewController(commentsTVC, animated: true)
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
            print(product.name)
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = product.tagline
        }
        if let profileImageURL = product.imageURL {
            
            DispatchQueue.main.async {
                
                cell.imageView?.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                cell.layoutIfNeeded()
            }
            
        }
        
        //self.tableView.reloadData()
        return cell
    }
    
}
