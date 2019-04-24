//
//  PhoneContactsStore.swift
//  T9Search
//
//  Created by George Vashakidze on 3/1/19.
//  Copyright © 2019 Toptal. All rights reserved.
//

import Contacts
import UIKit

fileprivate let T9Map = [
    " " : "0",
    "a" : "2",
    "b" : "2",
    "c" : "2",
    "d" : "3",
    "e" : "3",
    "f" : "3",
    "g" : "4",
    "h" : "4",
    "i" : "4",
    "j" : "5",
    "k" : "5",
    "l" : "5",
    "m" : "6",
    "n" : "6",
    "o" : "6",
    "p" : "7",
    "q" : "7",
    "r" : "7",
    "s" : "7",
    "t" : "8",
    "u" : "8",
    "v" : "8",
    "w" : "9",
    "x" : "9",
    "y" : "9",
    "z" : "9",
    "0" : "0",
    "1" : "1",
    "2" : "2",
    "3" : "3",
    "4" : "4",
    "5" : "5",
    "6" : "6",
    "7" : "7",
    "8" : "8",
    "9" : "9"
]

final class PhoneContact: NSObject {
    
    private let regex = try! NSRegularExpression(pattern: "[^ a-z()0-9+]", options: .caseInsensitive)
    
    var firstName    : String!
    var lastName     : String!
    var phoneNumber  : String!
    var t9String     : String = ""
    var image        : UIImage?
    
    var fullName: String! {
        get {
            return String(format: "%@ %@", self.firstName, self.lastName)
        }
    }
    
    override var hash: Int {
        get {
            return self.phoneNumber.hash
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? PhoneContact {
            return obj.phoneNumber == self.phoneNumber
        }
        
        return false
    }
    
    private func replace(str : String) -> String {
        let range = NSMakeRange(0, str.count)
        return self.regex.stringByReplacingMatches(in: str,
                                                   options: [],
                                                   range: range,
                                                   withTemplate: "")
    }
    
    func calculateT9() {
        
        for c in self.replace(str: self.fullName) {
            t9String.append(T9Map[String(c).localizedLowercase] ?? String(c))
        }
        
        for c in self.replace(str: self.phoneNumber) {
            t9String.append(T9Map[String(c).localizedLowercase] ?? String(c))
        }
    }
    
}

final class PhoneContactStore {
    
    fileprivate let contactsStore   = CNContactStore()
    fileprivate lazy var dataSource = Set<PhoneContact>()
    
    static let instance : PhoneContactStore = {
        let instance = PhoneContactStore()
        return instance
    }()
    
    class func hasAccess() -> Bool {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        return authorizationStatus == .authorized
    }
    
    class func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool, _ error : CustomError?) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            self.instance.loadAllContacts()
            completionHandler(true, nil)
        case .denied, .notDetermined:
            weak var wSelf = self.instance
            self.instance.contactsStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                var err: CustomError?
                if let e = accessError {
                    err = CustomError(description: e.localizedDescription, code: 0)
                } else {
                    wSelf?.loadAllContacts()
                }
                completionHandler(access, err)
            })
        default:
            completionHandler(false, CustomError(description: "Common Error", code: 100))
        }
    }
    
    fileprivate func loadAllContacts() {
        if self.dataSource.count == 0 {
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey, CNContactPhoneNumbersKey]
            do {
                
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                request.sortOrder = .givenName
                request.unifyResults = true
                if #available(iOS 10.0, *) {
                    request.mutableObjects = false
                } else {} // Fallback on earlier versions
                
                try self.contactsStore.enumerateContacts(with: request, usingBlock: {(contact, ok) in
                    DispatchQueue.main.async {
                        for phone in contact.phoneNumbers {
                            let local = PhoneContact()
                            local.firstName = contact.givenName
                            local.lastName = contact.familyName
                            if let data = contact.thumbnailImageData {
                                local.image = UIImage(data: data)
                            }
                            var phoneNum = phone.value.stringValue
                            if phoneNum.contains("+995") {
                                phoneNum = phoneNum.substring(from: "+995".count)
                            } else if phoneNum.hasPrefix("995") {
                                phoneNum = phoneNum.substring(from: "995".count)
                            }
                            let strArr = phoneNum.components(separatedBy: CharacterSet.decimalDigits.inverted)
                            phoneNum = NSArray(array: strArr).componentsJoined(by: "")
                            local.phoneNumber = phoneNum
                            local.calculateT9()
                            self.dataSource.insert(local)
                        }
                    }
                })
            } catch {}
        }
    }
    
    class func findWith(t9String: String) -> [PhoneContact] {
        return PhoneContactStore.instance.dataSource.filter({ $0.t9String.contains(t9String) })
    }
    
    class func findWith(str: String) -> [PhoneContact] {
        return PhoneContactStore.instance.dataSource.filter({ $0.fullName.lowercased().contains(str.lowercased()) })
    }
    
    class func count() -> Int {
        
        let request = CNContactFetchRequest(keysToFetch: [])
        var count = 0;
        do {
            try self.instance.contactsStore.enumerateContacts(with: request, usingBlock: {(contact, ok) in
                count += 1;
            })
        } catch {}
        
        return count
    }
}
