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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       
        return cell
    }
   
}
