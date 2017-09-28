//
//  CommentRequest.swift
//  Product-Hunt-API
//
//  Created by Matthew Harrilal on 9/24/17.
//  Copyright © 2017 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit

struct Comments1 {
    var body: String?
    init(body: String?) {
        self.body = body
    }
}
extension Comments1: Decodable {
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
    let comments: [Comments1]
}


