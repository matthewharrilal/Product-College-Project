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
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareSwipe()
      //  let network1 = CommentsRequest()
//        network1.commentsRequest(postID: postID) { (allComments) in
//            self.commentsArray = allComments
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//
//        }
//
        let networkingInstance = Networking()
        networkingInstance.fetch(route: Route.comments(postID: postID)) { (allComments) in
            let commentsHunt = try? JSONDecoder().decode(ProductHunt1.self, from: allComments)
            guard let newComments = commentsHunt?.comments else{return}
            self.commentsArray = newComments
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func prepareSwipe()
    {
        let swipeFromBottom = UISwipeGestureRecognizer(target: self, action: #selector(Comments.leftSwiping(_:)))
        swipeFromBottom.direction = .right
        view.addGestureRecognizer(swipeFromBottom)
        
    }
    
    @objc func leftSwiping(_ gesture:UIGestureRecognizer)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let commentsPath = commentsArray[indexPath.row]
        cell.textLabel?.text =  commentsPath.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
}
