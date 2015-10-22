//
//  3DSWebView.swift
//  JudoKit
//
//  Copyright (c) 2015 Alternative Payments Ltd
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Judo

public class _DSWebView: UIWebView {
    
    // MARK: initialization
    
    public init() {
        super.init(frame: CGRectZero)
        self.setupView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    // MARK: View Setup
    
    public func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alpha = 0.0
    }
    
    // MARK: configuration
    
    public func load3DSWithPayload(payload: [String : AnyObject]) throws -> String {
        let allowedCharacterSet = NSCharacterSet(charactersInString: ":/=,!$&'()*+;[]@#?").invertedSet
        
        guard let urlString = payload["acsUrl"] as? String,
            let acsURL = NSURL(string: urlString),
            let md = payload["md"],
            let receiptID = payload["receiptId"] as? String,
            let paReqString = payload["paReq"],
            let paReqEscapedString = paReqString.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet),
            let termURLString = "judo1234567890://threedsecurecallback".stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) else {
                throw JudoError.Failed3DSError
        }
        
        if let postData = "MD=\(md)&PaReq=\(paReqEscapedString)&TermUrl=\(termURLString)".dataUsingEncoding(NSUTF8StringEncoding) {
            let request = NSMutableURLRequest(URL: acsURL)
            request.HTTPMethod = "POST"
            request.setValue("\(postData.length)", forHTTPHeaderField: "Content-Length")
            request.HTTPBody = postData
            
            self.loadRequest(request)
        } else {
            throw JudoError.Failed3DSError
        }
        
        return receiptID // save it for later
    }
    
}