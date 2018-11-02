//
//  PostsDetailViewController.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2017-05-08.
//  Copyright © 2017 The Diplomacist. All rights reserved.
//

import UIKit

//  MARK: Class Itself

class PostsDetailViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate {
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var contentView: UIView?
    @IBOutlet var featImage: UIImageView?
    @IBOutlet var titleArt: UILabel?
    @IBOutlet var article: UIWebView?
    
    var featImageURL: String?
    //  MARK: Variables
    var post: PostsContainer?
    
    //  MARK: Update functions
    override func viewDidLoad() {
        super.viewDidLoad()
        //  Do any additional setup after loading the view.
        //  Getting the scrollView for easier access
        let scrollView = (self.view.subviews[0] as! UIScrollView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        scrollView.pinchGestureRecognizer?.isEnabled = false
        scrollView.panGestureRecognizer.isEnabled = true
        
        /*contentView = UIView.init(frame: self.view.bounds)
        print(self.view.bounds)
        print(scrollView.bounds)
        scrollView.addSubview(contentView!)
        scrollView.contentSize = (contentView?.frame.size)!*/
        
        //  First the image is given a place holder, otherwise the UIImageView would not load
        //  The image will indicate that the actual image is loading
        let featUIImage = UIImage(named: "photoLoading")
        self.featImage?.image = featUIImage
        self.featImage?.clipsToBounds = true
        self.featImage?.contentMode = UIView.ContentMode.scaleAspectFill
        
        //  Animation will start to stop actual image is loading
        self.featImage?.fadeOut()
        
        //  Now I'll start downloading the actual featured image that is set on the website
        //  The image will be downloaded in a background thread
        let imageURL = URL(string: (post?.featuredImageURL)!)
        //  Sending the request for the image file
        let session = URLSession.shared
        let dataTask = session.dataTask(with: imageURL!) { (data, response, error) -> Void in
            if error == nil {
                //  Now the image has been fetched, updating the UI, using the main queue
                DispatchQueue.main.async(execute: {
                    self.featImage?.layer.removeAllAnimations()
                    self.featImage?.image = UIImage(data: data!)
                })
            }
        }
        dataTask.resume()
        
        //  Now loading the title
        do {
            try self.titleArt?.text = Parse.ParseSingleLine(html: (self.post?.title)!)
        } catch PostsSplitViewControllerExceptions.singleLineParseFailed {
            print("\(PostsSplitViewControllerExceptions.singleLineParseFailed)")
        } catch {
            print("error")
        }
        
        //  Getting the right font for the title and configuring the label
        self.titleArt!.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        self.titleArt!.textColor = Colors.black
        self.titleArt!.textAlignment = NSTextAlignment.center
        self.titleArt!.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleArt!.numberOfLines = 0
        
        //  Adding the constraint to the titleArt, otherwise it collapses
        self.titleArt?.addConstraint(NSLayoutConstraint.init(
            item: self.titleArt!,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1.0,
            constant: (self.titleArt?.sizeThatFits(.zero).height)! + 25))
        
        let fr = CGRect.init(origin: (self.titleArt?.frame.origin)!, size: CGSize.init(width: (self.titleArt?.frame.size.width)!, height: (self.titleArt?.sizeThatFits(.zero).height)! + 25))
        self.titleArt?.frame = fr
        
        self.titleArt?.setNeedsLayout()
        self.titleArt?.setNeedsDisplay()
        
        //  Now loading the content of the article
        self.article?.loadHTMLString((self.post?.content)!, baseURL: nil)
        
        //  Setting the delegate of the webView
        self.article?.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //  Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //  Sizing the article
        self.article?.translatesAutoresizingMaskIntoConstraints = false
        self.article?.scrollView.isScrollEnabled = false
        let height = (self.article?.sizeThatFits(.zero))?.height

        //  Getting the size of the rest of the views on the page
        let heightfeatImage = self.featImage?.frame.size.height
        let heighttitleArt = self.titleArt?.frame.size.height
        let heightArticle = height!
        let heightPage = heightfeatImage! + 8 + heighttitleArt! + 8 + heightArticle - 55
        
        //  Adding a constraint to the contentView so that it is large enough to fit all the views
        self.contentView?.addConstraint(NSLayoutConstraint.init(
            item: self.contentView!,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1.0,
            constant: heightPage))
        
        //  Adding a constraint to the article so that it is large enough
        self.article?.addConstraint(NSLayoutConstraint.init(
            item: self.article!,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1.0,
            constant: heightArticle))
        
        //  Creating the frame to a proper height
        let fr = CGRect.init(origin: (self.article?.frame.origin)!, size: CGSize.init(width: (self.article?.frame.size.width)!, height: heightArticle))
        
        //  Setting the frame
        self.article?.frame = fr
        
        //  Just telling the app that some parts need updating
        self.scrollView?.contentSize.height = heightPage
        self.article?.setNeedsLayout()
        self.article?.setNeedsDisplay()
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    }
    
    /*func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView!
    }*/
}

//  MARK: Class extention
extension PostsDetailViewController: PostsSelectionDelegate {
    func postSelected(_ newPost: PostsContainer) {
        self.post = newPost
    }
}
