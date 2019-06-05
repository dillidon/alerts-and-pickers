import UIKit

public struct LocaleInfo {
    
    public var locale: Locale?
    
    public var id: String? {
        return locale?.identifier
    }
    
    public var country: String
    public var code: String
    public var phoneCode: String
    
    public var flag: UIImage? {
        return UIImage(named: "Countries.bundle/Images/\(code.uppercased())", in: Bundle.main, compatibleWith: nil)
    }
    
    public var currencyCode: String? {
        return locale?.currencyCode
    }
    
    public var currencySymbol: String? {
        return locale?.currencySymbol
    }
    
    public var currencyName: String? {
        guard let currencyCode = currencyCode else { return nil }
        return locale?.localizedString(forCurrencyCode: currencyCode)
    }
    
    init(country: String, code: String, phoneCode: String) {
        self.country = country
        self.code = code
        self.phoneCode = phoneCode
        
        self.locale = Locale.availableIdentifiers.map { Locale(identifier: $0) }.first(where: { $0.regionCode == code })
    }
}
