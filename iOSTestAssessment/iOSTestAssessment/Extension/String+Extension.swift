//
//  String+Extension.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 30/05/24.
//

import Foundation
import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var attributedTextWithBlackColor: NSMutableAttributedString {
        let attributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                          NSAttributedString.Key.foregroundColor : UIColor.label]
        if let htmlToAttributedString = htmlToAttributedString {
            return NSMutableAttributedString(string: htmlToAttributedString.string, attributes: attributes)
        } else {
            return NSMutableAttributedString(string: self, attributes: attributes)
        }
    }
}
