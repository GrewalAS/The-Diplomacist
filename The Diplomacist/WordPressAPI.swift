//
//  WordpressAPI.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2016-07-14.
//  Copyright © 2016 The Diplomacist. All rights reserved.
//

import Foundation
import Darwin
import UIKit

///////////////////////////////////////////////
//DO NOT FORGET EXCEPTION HANDLING UP THE ROW//
///////////////////////////////////////////////

//  MARK: Constants defined for keys, so mistakes don't fuck up the whole program

struct WordPressConstants {
    static let id = "ID"
    static let title = "title"
    static let date = "date"
    static let img = "featured_image"
    static let sum = "excerpt"
    static let cont = "content"
}

//  MARK: Exception handling for WordpressAPI class

enum WordPressAPIExceptions: Error{
    case noError
    case internetNotAvailable
    case errorFetchingMultiplePosts
    case jsonSerializationForMultiplePostsFailed
    case cannotGetJSONDataAsArray
}

extension WordPressAPIExceptions: CustomStringConvertible{
    //  Just defining the meaning of exceptions
    var description: String {
        switch self{
            case .noError:
                return "No Error"
            case .internetNotAvailable:
                return "No network data or Wi-Fi is available"
            case .errorFetchingMultiplePosts:
                return "An error occured while trying to fetch multiple posts from WordPress"
            case .jsonSerializationForMultiplePostsFailed:
                return "An error occured while trying to deserialize the JSON data for multiple posts"
            case .cannotGetJSONDataAsArray:
                return "Cannot convert JSON using SJSONSerialization.JSONObjectWithData(...)"
        }
    }
}

//  MARK: Class itself

class WordpressAPI: NSObject {
    //  Will be set on intialization to make the class more general
    var strURL:String
    
    init?(urlString: String){
        //  Nothing else needs to be initialized, designated
        //  Only initializer
        
        //  create NSURL instance
        if URL(string: urlString) != nil {
            //  check if your application can open the NSURL instance
            self.strURL = urlString
            super.init()
        } else{
            return nil
        }
    }
    
    func fetchPosts(_ page: Int, number: Int, completionHandler: @escaping (Array<PostsContainer>?, WordPressAPIExceptions) -> Void) throws {
        //  Fetches posts from the website
        
        //  First uses reachability to check if the device is connected to the internet
        if !Reachability.isConnectedToNetwork() {
            throw WordPressAPIExceptions.internetNotAvailable
        } else {
            //  If it is, it continues its execution
            let reqURL = strURL + "/posts/?page=\(page)&fields=ID,title,date,featured_image,excerpt,content"
            //  For specific post
            //  let reqURL = strURL + "/posts/?page=\(page)&number=\(number)&fields=ID,title,date,excerpt,summary,content"
            let actualURL = URL(string: reqURL)
            let session = URLSession.shared
        
            var JSONData: [String: AnyObject]!
            var postsRequested = Array<PostsContainer>()
        
            //  Fetching data and processing it
            let dataTask = session.dataTask(with: actualURL!, completionHandler: { (data, response, error) -> Void in
                do {
                    if error != nil {
                        throw WordPressAPIExceptions.errorFetchingMultiplePosts
                    } else {
                        do {
                            JSONData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                        } catch {
                            throw WordPressAPIExceptions.cannotGetJSONDataAsArray
                        }
                        postsRequested = try self.JSONDictToArrayOfPosts(JSONData)
                        completionHandler(postsRequested, WordPressAPIExceptions.noError)
                    }
                } catch {
                    print("ERROR: \(error)")
                    completionHandler(postsRequested, (error as? WordPressAPIExceptions)!)
                }
                /*for post in postsRequested {
                    print("\(post.content)")
                }*/
                //print("\(postsRequested[1].content)");
            })
        
            dataTask.resume()
        }
    }
    
    func JSONDictToArrayOfPosts (_ JSONData: [String: AnyObject]) throws -> Array<PostsContainer>{
        //  Converts JSON dict to an Array of Posts
        //  A lot of instances where an exception can be thrown if JSONData is not deserialized properly
        var postsFetched = Array<PostsContainer>()
        
        guard let postsFet = JSONData["posts"] as? [[String: AnyObject]] else {//   posts is an Array of Dicts, or it should be, otherwise an exception will be thrown
            throw WordPressAPIExceptions.jsonSerializationForMultiplePostsFailed
        }
        
        for post in postsFet{
            //  Each post is processed
            //  JSON data is properly converted into the right type of var
            //  Then sent for initialization
            let ID = post[WordPressConstants.id] as? Int
            let title = post[WordPressConstants.title] as? String
            let date = post[WordPressConstants.date] as? String
            let img = post[WordPressConstants.img] as? String
            let sum = post[WordPressConstants.sum] as? String
            let cont = post[WordPressConstants.cont] as? String
            
            //  Appending it to the array which will be returned to the View Controller
            postsFetched.append(PostsContainer(postID: ID!, postTitle: title!, postDate: date!, postExcerpt: sum!, postContent: cont!, postFeaturedImage: img!))
        }
        return postsFetched
    }
}
