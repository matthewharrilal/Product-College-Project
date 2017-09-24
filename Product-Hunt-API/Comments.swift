//
//  Comments.swift
//  Product-Hunt-API
//
//  Created by Matthew Harrilal on 9/22/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit

class Comments: UITableViewController {
    
    var postID : Int = 0
    
    var commentsArray: [Comments1] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    let network1 = CommentsRequest()
        network1.commentsRequest(postID: postID) { (allComments) in
            self.commentsArray = allComments
        }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let commentsPath = commentsArray[indexPath.row]
        cell.textLabel?.text = String(describing: commentsPath.body)
        return cell
    }
    

}
