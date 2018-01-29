import Foundation
import Contacts
import UIKit
import CoreTelephony

/// https://github.com/satishbabariya/SwiftyContacts

public struct Contacts {
    
    /// Result Enum
    ///
    /// - Success: Returns Array of Contacts
    /// - Error: Returns error
    public enum FetchResults {
        case success(response: [CNContact])
        case error(error: Error)
    }
    
    /// Result Enum
    ///
    /// - Success: Returns Contact
    /// - Error: Returns error
    public enum FetchResult {
        case success(response: CNContact)
        case error(error: Error)
    }
    
    /// Result Enum
    ///
    /// - Success: Returns Grouped By Alphabets Contacts
    /// - Error: Returns error
    public enum GroupedByAlphabetsFetchResults {
        case success(response: [String: [CNContact]])
        case error(error: Error)
    }
    
    /// Requests access to the user's contacts
    ///
    /// - Parameter requestGranted: Result as Bool
    public static func requestAccess(_ requestGranted: @escaping (Bool, Error?) -> ()) {
        CNContactStore().requestAccess(for: .contacts) { grandted, error in
            requestGranted(grandted, error)
        }
    }
    
    /// Returns the current authorization status to access the contact data.
    ///
    /// - Parameter requestStatus: Result as CNAuthorizationStatus
    public static func authorizationStatus(_ requestStatus: @escaping (CNAuthorizationStatus) -> ()) {
        requestStatus(CNContactStore.authorizationStatus(for: .contacts))
    }
    
    // MARK: - Fetch Contacts -
    
    /// Fetching Contacts from phone
    ///
    /// - Parameter completionHandler: Returns Either [CNContact] or Error.
    public static func fetchContacts(completionHandler: @escaping (_ result: FetchResults) -> ()) {
        
        let contactStore: CNContactStore = CNContactStore()
        var contacts: [CNContact] = [CNContact]()
        let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                contact, _ in
                contacts.append(contact) })
            completionHandler(FetchResults.success(response: contacts))
        } catch {
            completionHandler(FetchResults.error(error: error))
        }
    }
    
    /// Fetching Contacts from phone with specific sort order.
    ///
    /// - Parameters:
    ///   - sortOrder: To return contacts in a specific sort order.
    ///   - completionHandler: Result Handler
    @available(iOS 10.0, *)
    public static func fetchContacts(ContactsSortorder sortOrder: CNContactSortOrder, completionHandler: @escaping (_ result: FetchResults) -> ()) {
        
        let contactStore: CNContactStore = CNContactStore()
        var contacts: [CNContact] = [CNContact]()
        let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = sortOrder
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {
                contact, _ in
                contacts.append(contact) })
            completionHandler(FetchResults.success(response: contacts))
        } catch {
            completionHandler(FetchResults.error(error: error))
        }
    }
    
    /// etching Contacts from phone with Grouped By Alphabet
    ///
    /// - Parameter completionHandler: It will return Dictonary of Alphabets with Their Sorted Respective Contacts.
     @available(iOS 10.0, *)
     public static func fetchContactsGroupedByAlphabets(completionHandler: @escaping (GroupedByAlphabetsFetchResults) -> ()) {
        
        let contactStore: CNContactStore = CNContactStore()
        let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
        var orderedContacts: [String: [CNContact]] = [String: [CNContact]]()
        CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .givenName
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (contact, _) -> Void in
                // Ordering contacts based on alphabets in firstname
                var key: String = "#"
                // If ordering has to be happening via family name change it here.
                let firstLetter = contact.givenName[0..<1]
                if firstLetter.containsAlphabets {
                    key = firstLetter.uppercased()
                }
                var contacts = [CNContact]()
                if let segregatedContact = orderedContacts[key] {
                    contacts = segregatedContact
                }
                contacts.append(contact)
                orderedContacts[key] = contacts
            })
        } catch {
            completionHandler(GroupedByAlphabetsFetchResults.error(error: error))
        }
        completionHandler(GroupedByAlphabetsFetchResults.success(response: orderedContacts))
     }
    
    /// Fetching Contacts from phone
    /// - parameter completionHandler: Returns Either [CNContact] or Error.
    public static func fetchContactsOnBackgroundThread(completionHandler: @escaping (_ result: FetchResults) -> ()) {
        
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> () in
            let fetchRequest: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
            var contacts = [CNContact]()
            CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone)
            if #available(iOS 10.0, *) {
                fetchRequest.mutableObjects = false
            } else {
                // Fallback on earlier versions
            }
            fetchRequest.unifyResults = true
            fetchRequest.sortOrder = .userDefault
            do {
                try CNContactStore().enumerateContacts(with: fetchRequest) { (contact, _) -> () in
                    contacts.append(contact)
                }
                DispatchQueue.main.async(execute: { () -> () in
                    completionHandler(FetchResults.success(response: contacts))
                })
            } catch let error as NSError {
                completionHandler(FetchResults.error(error: error))
            }
            
        })
        
    }
    
    // MARK: - Search Contacts -
    
    /// Search Contact from phone
    /// - parameter string: Search String.
    /// - parameter completionHandler: Returns Either [CNContact] or Error.
    public static func searchContact(searchString string: String, completionHandler: @escaping (_ result: FetchResults) -> ()) {
        
        let contactStore: CNContactStore = CNContactStore()
        var contacts: [CNContact] = [CNContact]()
        let predicate: NSPredicate

        if string.endIndex.encodedOffset > 0 {
            predicate = CNContact.predicateForContacts(matchingName: string)
        } else {
            predicate = CNContact.predicateForContactsInContainer(withIdentifier: CNContactStore().defaultContainerIdentifier())
        }
        
        do {
            contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
            contacts = contacts.sorted { $0.givenName < $1.givenName }
            completionHandler(FetchResults.success(response: contacts))
        } catch {
            completionHandler(FetchResults.error(error: error))
        }
    }
    
    // Get CNContact From Identifier
    /// Get CNContact From Identifier
    /// - parameter identifier: A value that uniquely identifies a contact on the device.
    /// - parameter completionHandler: Returns Either CNContact or Error.
    public static func getContactFromID(Identifires identifiers: [String], completionHandler: @escaping (_ result: FetchResults) -> ()) {
        
        let contactStore: CNContactStore = CNContactStore()
        var contacts: [CNContact] = [CNContact]()
        let predicate: NSPredicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
        do {
            contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [CNContactVCardSerialization.descriptorForRequiredKeys()])
            completionHandler(FetchResults.success(response: contacts))
        } catch {
            completionHandler(FetchResults.error(error: error))
        }
    }
}


public struct Telephone {
    
    // PRAGMA MARK: - CoreTelephonyCheck
    
    /// Check if iOS Device supports phone calls
    /// - parameter completionHandler: Returns Bool.
    public static func isCapableToCall(completionHandler: @escaping (_ result: Bool) -> ()) {
        if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
            // Check if iOS Device supports phone calls
            // User will get an alert error when they will try to make a phone call in airplane mode
            if let mnc: String = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode, !mnc.isEmpty {
                // iOS Device is capable for making calls
                completionHandler(true)
            } else {
                // Device cannot place a call at this time. SIM might be removed
                completionHandler(false)
            }
        } else {
            // iOS Device is not capable for making calls
            completionHandler(false)
        }
        
    }
    
    /// Check if iOS Device supports sms
    /// - parameter completionHandler: Returns Bool.
    public static func isCapableToSMS(completionHandler: @escaping (_ result: Bool) -> ()) {
        if UIApplication.shared.canOpenURL(NSURL(string: "sms:")! as URL) {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
        
    }
    
    /// Convert CNPhoneNumber To digits
    /// - parameter CNPhoneNumber: Phone number.
    public static func CNPhoneNumberToString(CNPhoneNumber: CNPhoneNumber) -> String {
        if let result: String = CNPhoneNumber.value(forKey: "digits") as? String {
            return result
        }
        return ""
    }
    
    /// Make call to given number.
    /// - parameter CNPhoneNumber: Phone number.
    public static func makeCall(CNPhoneNumber: CNPhoneNumber) {
        if let phoneNumber: String = CNPhoneNumber.value(forKey: "digits") as? String {
            guard let url: URL = URL(string: "tel://" + "\(phoneNumber)") else {
                print("Error in Making Call")
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }
}
