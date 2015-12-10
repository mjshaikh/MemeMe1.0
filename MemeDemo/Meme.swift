//
//  Meme.swift
//  MemeMe1.0
//
//  Created by Mohammed Shaikh on 2015-12-08.
//  Copyright © 2015 Zaytun Lab. All rights reserved.
//

import Foundation
import UIKit

struct Meme{
    
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
    
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage){
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}