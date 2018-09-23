import UIKit
import Contacts

public struct Contact {
    
    var value: CNContact
    
    var firstName: String
    var lastName: String
    var company: String
    var image: UIImage?
    var thumbnail: UIImage?
    var birthday: Date?
    var id: String?
    var phones: [(number: String, label: String)] = []
    var emails: [(email: String, label: String )] = []
    
    public init(contact: CNContact) {
        value = contact
        firstName = contact.givenName
        lastName = contact.familyName
        company = contact.organizationName
        id = contact.identifier
        
        if let thumbnailImageData = contact.thumbnailImageData {
            thumbnail = UIImage(data: thumbnailImageData)
        }
        
        if let imageData = contact.imageData {
            image = UIImage(data: imageData)
        }
        
        if let birthdayDate = contact.birthday {
            birthday = Calendar(identifier: Calendar.Identifier.gregorian).date(from: birthdayDate)
        }
        
        for phoneNumber in contact.phoneNumbers {
            let label = phoneNumber.label ?? "phone"
            let phone = phoneNumber.value.stringValue
            phones.append((phone, label))
        }
        
        for emailAddress in contact.emailAddresses {
            guard let label = emailAddress.label else { continue }
            let email = emailAddress.value as String
            emails.append((email, label))
        }
    }
    
    var displayName:  String {
        return firstName + " " + lastName
    }
    
    var initials: String {
        var initials = String()
        if let first = firstName.first { initials.append(first) }
        if let second = lastName.first { initials.append(second) }
        return initials
    }
}
