//
//  Parse.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2017-06-09.
//  Copyright © 2017 The Diplomacist. All rights reserved.
//

import UIKit
import Kanna

class Parse: NSObject {
    //  Parses single line of HTML
    class func ParseSingleLine(html: String) throws -> String {
        //  To check for error if nothing is processed from the HTML
        var processedExcerpt: String = "ERROR"
        //  Loading the HTML
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            //  Getting the body of the document to process
            let bodyNode = doc.body
            
            //  Getting all paragraphs
            if let inputNodes = bodyNode?.css("p") {
                processedExcerpt = (inputNodes.first?.content)!
            }
        }
        
        //  Checkign if everything was done successfully
        if processedExcerpt == "ERROR" {
            throw PostsSplitViewControllerExceptions.singleLineParseFailed
        }
        return processedExcerpt
    }
}
