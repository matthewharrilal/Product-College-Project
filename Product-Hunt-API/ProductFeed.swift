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
    var posts1: [ProductHunt] = [] {
        didSet {
            self.tableView.reloadData()
        }
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: tableCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! tableCell
        let product = posts1[indexPath.row]
        
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = product.tagline
        if let profileImageURL = product.imageURL {
            let url = URL(string: profileImageURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                cell.imageView?.image = UIImage(data: data!)
            }).resume()
        }
        return cell
    }
   
}
