//
//  PostsContainer.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2016-07-21.
//  Copyright © 2016 The Diplomacist. All rights reserved.
//

import UIKit
import Foundation

//  MARK: Exception handing for PostsContainer

//  MARK: Class itself

class PostsContainer: NSObject {
    //  This class just holds the posts, there isn't a lot of other stuff that happens
    var ID: Int
    var title: String
    var date: Date
    var excerpt: String
    var content: String
    var featuredImageURL: String
    
    init(postID: Int, postTitle: String, postDate: String, postExcerpt: String, postContent: String, postFeaturedImage: String) {
        //  Just assigns the data
        //  No other processing done here
        self.ID = postID
        self.title = postTitle
        self.excerpt = postExcerpt
        self.content = postContent
        self.featuredImageURL = postFeaturedImage
        
        //  Date dealt with in the end because some processing is needed
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sszz"
        self.date = dateFormatter.date(from: postDate)!
        //  Date from here is converted from -04:00(EST) to +00:00(GMT)
    }
    
    override var description: String{
        return "ID: \(self.ID) \ntitle: \(self.title) \ndate: \(self.date) \nexcerpt: \(self.excerpt) \ncontent: \(self.content) \nfeaturedImageURL: \(self.featuredImageURL)"
    }
}
