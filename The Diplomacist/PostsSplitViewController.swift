//
//  PostsSplitViewController.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2017-05-06.
//  Copyright © 2017 The Diplomacist. All rights reserved.
//

import UIKit

//  MARK: Exception handling for PostsSplitViewController

enum PostsSplitViewControllerExceptions: Error {
    case singleLineParseFailed
}

extension PostsSplitViewControllerExceptions: CustomStringConvertible{
    // Just defining the meaning of exceptions
    var description: String {
        switch self {
        case .singleLineParseFailed:
            return "An error occured while trying to parse single line HTML"
        }
    }
}

//  MARK: Class Itself

class PostsSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    //  MARK: Variables
    var labelView: UILabel!
    var scrollView: UIScrollView!
    //  MARK: PostsSplitViewController functions
    override func viewDidLoad() {
        //  Done to start with master view not table view
        self.delegate = self
        self.preferredDisplayMode = .allVisible
        
        //  Edits to the appearance of the navigation bar
        let navigationBarAppearance = UINavigationBar.appearance()
        //  Just setting the colors
        //  The following lene sets the colors of "< back" to red
        navigationBarAppearance.tintColor = Colors.white
        //  The following line sets the background of the bar to red
        navigationBarAppearance.barTintColor = Colors.dipRed
        let titleDict = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): Colors.white, convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)]
        navigationBarAppearance.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(titleDict)
    }
    
    //  This function will return true so that it UIKIT does not go to the detail view
    //  It goes to the master view
    //  Return true to prevent UIKit from applying its default behavior
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
