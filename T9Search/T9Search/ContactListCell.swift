//
//  ContactListCell.swift
//  T9Search
//
//  Created by George Vashakidze on 3/15/19.
//  Copyright © 2019 Toptal. All rights reserved.
//

import UIKit

final class ContactListCell: UITableViewCell {
    
    @IBOutlet private weak var contactFullName    : UILabel!
    @IBOutlet private weak var contactNumber      : UILabel!
    @IBOutlet weak var contactImage               : UIImageView!
    @IBOutlet weak var separator                  : UIView!
    
    func configureCell(fullName: String,
                       t9String: String,
                       number: String,
                       searchStr: String?,
                       img: UIImage?,
                       t9Search : Bool = true) {
        
        separator.backgroundColor = .gray
        
        guard let _searchStr = searchStr else { return }
        
        self.contactFullName.attributedText = self.getAttributedText(
            fullName: fullName,
            searchStr: _searchStr,
            t9String: t9String,
            isText : true,
            t9Search: t9Search
        )
        
        self.contactNumber.attributedText = self.getAttributedText(
            fullName: number,
            searchStr: _searchStr,
            t9String: t9String,
            t9Search: t9Search
        )
        
        self.contactImage.image = img
    }
    
    private func getAttributedText(fullName: String,
                                   searchStr: String,
                                   t9String: String,
                                   isText: Bool = false,
                                   t9Search : Bool = true) -> NSAttributedString {
        
        let string = t9Search ? t9String : fullName.uppercased()
        var range = (string as NSString).range(of: searchStr.uppercased())
        
        let attrs = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize:self.contactFullName.font.pointSize),
            NSAttributedStringKey.foregroundColor : UIColor.red
        ]
        
        let attributedString = NSMutableAttributedString(string: fullName, attributes: [:])
        
        if isText {
            if range.location + range.length <= fullName.count {
                attributedString.setAttributes(attrs, range: range)
            }
        } else if let sRange = t9String.range(of: fullName) {
            let index: Int = t9String.distance(from: t9String.startIndex, to: sRange.lowerBound)
            
            let newIndex = t9String.count - index
            if newIndex + range.length <= t9String.count {
                range = (fullName as NSString).range(of: searchStr.uppercased())
                attributedString.setAttributes(attrs, range: range)
            }
        }
        
        return attributedString
        
        
    }
    
}
