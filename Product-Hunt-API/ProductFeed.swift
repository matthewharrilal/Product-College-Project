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
        Network.networking { (gatheredPosts) in
            self.posts1 = gatheredPosts
            self.tableView.reloadData()
        }
       
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts1.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            var commentsViewController = segue.destination as? Comments
            //products?.name = commentsViewController?.commentsLabel.text
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: tableCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! tableCell
        let product = posts1[indexPath.row]
        
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
