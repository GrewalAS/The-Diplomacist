//
//  PostsMasterViewController.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2016-07-22.
//  Copyright © 2016 The Diplomacist. All rights reserved.
//

import UIKit
import Foundation
import Kanna

//  MARK: Protocols

protocol PostsSelectionDelegate: class {
    func postSelected(_ newPost: PostsContainer)
}

//  MARK: Class itself

class PostsMasterViewController: UITableViewController {
    //  MARK: Variables declared first
    //  Will hold all the posts fetched from the website
    var allFetchedPosts: Array<PostsContainer> = []
    
    //  MARK: Table View variables/constants
    //  Table View variables/contants declaration
    let postsCellReuseIdentifier = "postsTableCells"
    @IBOutlet var postsTableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        // Placing an image so that an empty table does not appear
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.contentMode = .center
        backgroundImage.image = UIImage(named: "backGroundForTable")
        self.tableView.backgroundView = backgroundImage
        
        // Setting up animation for the background image so it seems like its loading
        self.tableView.backgroundView!.fadeOut()
    }
    
    //  MARK: PostsTableViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table and delegate and data source
        postsTableView.delegate = self
        postsTableView.dataSource = self
        
        // Doing some setup
        // Removing the seperator lines
        self.tableView.separatorStyle = .none
        
        //  Along with auto layout, this will enable variable cell height
        postsTableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        
        //  Running on the non-main queue
        //  This is because I do not want the main queue blocked up by a network process
        //  This could freeze up the UI for long periods of time
        //  It does not matter if the network connection is slow or fast, the user will still lose interactivity with the UI
        DispatchQueue.global(qos: .userInitiated).async(execute: {// A high priority queue is used since the main purpose of the app is to show the articles
            //  Network process begins
            //  Fetching
            let wordPress = WordpressAPI(urlString: "https://public-api.wordpress.com/rest/v1.1/sites/diplomacist.com")
            do{
                try wordPress!.fetchPosts(1, number: 1, completionHandler: { jsonDataDeserialized, error -> Void in
                    if error == WordPressAPIExceptions.noError{
                        DispatchQueue.main.async(execute: {
                            //  After the posts have been fetched, the data in the table is reloaded
                            self.allFetchedPosts = self.allFetchedPosts + jsonDataDeserialized!
                            self.tableView.backgroundView?.layer.removeAllAnimations()
                            self.postsTableView.reloadData()
                        })
                    }
                })
            }
            catch{
                print("error")
            }
        })
        //  Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //  Dispose of any resources that can be recreated.
    }
    
    //  MARK: Table view controller fuctions (delegate and datasource)
    //  Number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //  Short function since the data is being held in an array
        return self.allFetchedPosts.count
    }
    
    //  Create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  Assigning images to PostsContainer.featuredImage, its a network thing, so its still placed in a non-main thread
        //  Other thread will be lauched so the posts appear, even if the image is a loading gif/view
        //  Done here so updating the view is a lot easier, don't have to iterate through it
        let dataToBeUsed = allFetchedPosts[(indexPath as NSIndexPath).row]
        //  Just to make sure that the cell is the right type
        let cell: PostsTableCell = (self.postsTableView.dequeueReusableCell(withIdentifier: postsCellReuseIdentifier) as? PostsTableCell)!
        
        //  Setting up the views
        //  The following gets the image async
        
        //  First the image is given a place holder, otherwise the UIImageView would not load
        //  The image will indicate that the actual image is loading
        cell.featuredImage?.image = UIImage(named: "photoLoading")
        //  Animation will start to stop actual image is loading
        cell.featuredImage!.fadeOut()
        
        cell.setNeedsLayout()
        cell.setNeedsDisplay()
        //  Downloading the image
        //  Performing in a background thread
        let imageURL = URL(string: dataToBeUsed.featuredImageURL)
        //  Sending the request
        let session = URLSession.shared
        let dataTask = session.dataTask(with: imageURL!, completionHandler: { (data, response, error) -> Void in
            if error == nil {
                // Now the process to update the UI, using the main queue will be started
                DispatchQueue.main.async(execute: {
                    if let cellToUpdate: PostsTableCell = tableView.cellForRow(at: indexPath) as! PostsTableCell?{
                        //  The following lines existed because I had created a bug, I was assigning the newImage to cellToUpdate.imageView, not featuredImage
                        //  let newImage = UIImage(data: data!)
                        //  let resizedImage = newImage!.resizedImageByRatio(image: newImage!, ratio: UIScreen.main.bounds.width / newImage!.size.width)
                        //  let croppedImage = newImage!.cropByAspectRatio();
                        
                        //  Removing all animation
                        cellToUpdate.featuredImage?.layer.removeAllAnimations()
                        
                        //  Setting the image after the image has been fetched
                        cellToUpdate.featuredImage?.contentMode = UIView.ContentMode.scaleAspectFill
                        cellToUpdate.featuredImage?.image = UIImage(data: data!)
                        cellToUpdate.featuredImage?.clipsToBounds = true;
                        
                        cellToUpdate.setNeedsLayout()
                        cellToUpdate.setNeedsDisplay()
                    }
                })
            } else {
                print("ERROR: \(error!.localizedDescription)")
            }
        })
        dataTask.resume()
        
        //  Now the rest of the data will be set
        cell.title?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.title?.numberOfLines = 0
        cell.title?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        cell.excerpt?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.excerpt?.numberOfLines = 0
        cell.excerpt?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        
        do {
            try cell.title?.text = Parse.ParseSingleLine(html: dataToBeUsed.title)
            try cell.excerpt?.text = Parse.ParseSingleLine(html: dataToBeUsed.excerpt)
        } catch PostsSplitViewControllerExceptions.singleLineParseFailed {
            print("\(PostsSplitViewControllerExceptions.singleLineParseFailed)")
        } catch {
            print("error")
        }
        
        //  Calculating days passed
        let calendar: Calendar = Calendar.current
        let date = dataToBeUsed.date
        let currentDate = Date()
        
        let flags = NSCalendar.Unit.day
        let components = (calendar as NSCalendar).components(flags, from: date as Date, to: currentDate, options: [])
        
        //  Setting days
        if components.day! <= 1{
            cell.timeStamp?.text = String(describing: components.day!) + " day ago"
        }else{
            cell.timeStamp?.text = String(describing: components.day!) + " days ago"
        }
        return cell
    }
    
    // MARK: - Navigation
     
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  The segue is first triggered so that we load the detail view before deselecting the row
        self.performSegue(withIdentifier: "showDetail", sender: self)
        //  Deselecting the row after the segue is triggered
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //  Checking if the right segue is being customized
        if segue.identifier == "showDetail" {
            //  Setting all the information for the detail view
            let detailVC = (segue.destination.children[0] as! PostsDetailViewController)
            let indexPath = self.tableView.indexPathForSelectedRow
            detailVC.post = allFetchedPosts[(indexPath?.row)!]
        }
    }
}
