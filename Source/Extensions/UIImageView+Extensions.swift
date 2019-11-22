import UIKit

extension UIImageView {
    
    /// Sets the image property of the view based on initial text, a specified background color, custom text attributes, and a circular clipping
    ///
    /// - Parameters:
    ///   - string: The string used to generate the initials. This should be a user's full name if available.
    ///   - color: This optional paramter sets the background of the image. By default, a random color will be generated.
    ///   - circular: This boolean will determine if the image view will be clipped to a circular shape.
    ///   - textAttributes: This dictionary allows you to specify font, text color, shadow properties, etc.
    open func setImage(string: String?, color: UIColor? = nil, circular: Bool = false, textAttributes: [NSAttributedString.Key: Any]? = nil) {
        
        let image = imageSnap(text: string != nil ? string?.initials : "", color: color ?? UIColor.random, circular: circular, textAttributes: textAttributes)
        
        if let newImage = image {
            self.image = newImage
        }
    }
    
    private func imageSnap(text: String?, color: UIColor, circular: Bool, textAttributes: [NSAttributedString.Key: Any]?) -> UIImage? {
        
        let scale = Float(UIScreen.main.scale)
        var size = bounds.size
        if contentMode == .scaleToFill || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        let context = UIGraphicsGetCurrentContext()
        if circular {
            let path = CGPath(ellipseIn: bounds, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        // Fill
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Text
        if let text = text {
            let attributes: [NSAttributedString.Key: Any] = textAttributes ?? [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 15.0)]
            
            let textSize = text.size(withAttributes: attributes)
            let bounds = self.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: String Helper
extension String {
    
    public var initials: String {
        var finalString = String()
        var words = components(separatedBy: .whitespacesAndNewlines)
        
        if let firstCharacter = words.first?.first {
            finalString.append(String(firstCharacter))
            words.removeFirst()
        }
        
        if let lastCharacter = words.last?.first {
            finalString.append(String(lastCharacter))
        }
        
        return finalString.uppercased()
        
        //return self.components(separatedBy: .whitespacesAndNewlines).reduce("") { ($0.isEmpty ? "" : "\($0.uppercased().first!)") + ($1.isEmpty ? "" : "\($1.uppercased().first!)") }
    }
}

let kFontResizingProportion: CGFloat = 0.4
let kColorMinComponent: Int = 30
let kColorMaxComponent: Int = 214

public typealias GradientColors = (top: UIColor, bottom: UIColor)

typealias HSVOffset = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
let kGradientTopOffset: HSVOffset = (hue: -0.025, saturation: 0.05, brightness: 0, alpha: 0)
let kGradientBotomOffset: HSVOffset = (hue: 0.025, saturation: -0.05, brightness: 0, alpha: 0)

extension UIImageView {
    
    public func setImageForName(string: String, backgroundColor: UIColor? = nil, circular: Bool, textAttributes: [NSAttributedString.Key: AnyObject]?, gradient: Bool = false) {
        
        setImageForName(string: string, backgroundColor: backgroundColor, circular: circular, textAttributes: textAttributes, gradient: gradient, gradientColors: nil)
    }
    
    public func setImageForName(string: String, gradientColors: GradientColors? = nil, circular: Bool = true, textAttributes: [NSAttributedString.Key: AnyObject]? = nil) {
        
        setImageForName(string: string, backgroundColor: nil, circular: circular, textAttributes: textAttributes, gradient: true, gradientColors: gradientColors)
    }
    
    public func setImageForName(string: String, backgroundColor: UIColor? = nil, circular: Bool, textAttributes: [NSAttributedString.Key: AnyObject]? = nil, gradient: Bool = false, gradientColors: GradientColors? = nil) {
        
        let initials: String = initialsFromString(string: string)
        let color: UIColor = (backgroundColor != nil) ? backgroundColor! : randomColor(for: string)
        let gradientColors = gradientColors ?? topAndBottomColors(for: color)
        let attributes: [NSAttributedString.Key: AnyObject] = (textAttributes != nil) ? textAttributes! : [
            NSAttributedString.Key.font: self.fontForFontName(name: nil),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        self.image = imageSnapshot(text: initials, backgroundColor: color, circular: circular, textAttributes: attributes, gradient: gradient, gradientColors: gradientColors)
    }
    
    private func fontForFontName(name: String?) -> UIFont {
        
        let fontSize = self.bounds.width * kFontResizingProportion;
        if name != nil {
            return UIFont(name: name!, size: fontSize)!
        }
        else {
            return UIFont.systemFont(ofSize: fontSize)
        }
        
    }
    
    private func imageSnapshot(text imageText: String, backgroundColor: UIColor, circular: Bool, textAttributes: [NSAttributedString.Key : AnyObject], gradient: Bool, gradientColors: GradientColors) -> UIImage {
        
        let scale: CGFloat = UIScreen.main.scale
        
        var size: CGSize = self.bounds.size
        if (self.contentMode == .scaleToFill ||
            self.contentMode == .scaleAspectFill ||
            self.contentMode == .scaleAspectFit ||
            self.contentMode == .redraw) {
            
            size.width = (size.width * scale) / scale
            size.height = (size.height * scale) / scale
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        if circular {
            // Clip context to a circle
            let path: CGPath = CGPath(ellipseIn: self.bounds, transform: nil)
            context.addPath(path)
            context.clip()
        }
        
        if gradient {
            // Draw a gradient from the top to the bottom
            let baseSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [gradientColors.top.cgColor, gradientColors.bottom.cgColor]
            let gradient = CGGradient(colorsSpace: baseSpace, colors: colors as CFArray, locations: nil)!
            
            let startPoint = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
            let endPoint = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
            
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        } else {
            // Fill background of context
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        
        // Draw text in the context
        let textSize: CGSize = imageText.size(withAttributes: textAttributes)
        let bounds: CGRect = self.bounds
        
        imageText.draw(in: CGRect(x: bounds.midX - textSize.width / 2,
                                  y: bounds.midY - textSize.height / 2,
                                  width: textSize.width,
                                  height: textSize.height),
                       withAttributes: textAttributes)
        
        let snapshot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return snapshot;
    }
}

private func randomColorComponent() -> Int {
    let limit = kColorMaxComponent - kColorMinComponent
    return kColorMinComponent + Int(drand48() * Double(limit))
}

private func randomColor(for string: String) -> UIColor {
    srand48(string.hashValue)
    
    let red = CGFloat(randomColorComponent()) / 255.0
    let green = CGFloat(randomColorComponent()) / 255.0
    let blue = CGFloat(randomColorComponent()) / 255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

private func initialsFromString(string: String) -> String {
    return string.components(separatedBy: .whitespacesAndNewlines).reduce("") {
        ($0.isEmpty ? "" : "\($0.uppercased().first!)") + ($1.isEmpty ? "" : "\($1.uppercased().first!)")
    }
}

private func clampColorComponent(_ value: CGFloat) -> CGFloat {
    return min(max(value, 0), 1)
}

private func correctColorComponents(of color: UIColor, withHSVOffset offset: HSVOffset) -> UIColor {
    
    var hue = CGFloat(0)
    var saturation = CGFloat(0)
    var brightness = CGFloat(0)
    var alpha = CGFloat(0)
    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        hue = clampColorComponent(hue + offset.hue)
        saturation = clampColorComponent(saturation + offset.saturation)
        brightness = clampColorComponent(brightness + offset.brightness)
        alpha = clampColorComponent(alpha + offset.alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    return color
}

private func topAndBottomColors(for color: UIColor, withTopHSVOffset topHSVOffset: HSVOffset = kGradientTopOffset, withBottomHSVOffset bottomHSVOffset: HSVOffset = kGradientBotomOffset) -> GradientColors {
    let topColor = correctColorComponents(of: color, withHSVOffset: topHSVOffset)
    let bottomColor = correctColorComponents(of: color, withHSVOffset: bottomHSVOffset)
    return (top: topColor, bottom: bottomColor)
}
