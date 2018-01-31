import UIKit

extension UIAlertController {
    
    /// Add a textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - configuration: textField
    
    public func addColorPicker(color: UIColor = .black, action: ColorPickerViewController.Action?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPickerViewController else { return }
        set(vc: vc)
        vc.set(color: color, action: action)
    }
}

final public class ColorPickerViewController: UIViewController {
    
    public typealias Action = (UIColor) -> Swift.Void
    
    public var action: Action?
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    @IBOutlet weak var hueSlider: GradientSlider!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    public var color: UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    public var hue: CGFloat = 0.5
    public var saturation: CGFloat = 0.5
    public var brightness: CGFloat = 0.5
    public var alpha: CGFloat = 1
    
    fileprivate var preferredHeight: CGFloat = 0
    
    public func set(color: UIColor, action: Action?) {
        let components = color.hsbaComponents
        
        hue = components.hue
        saturation = components.saturation
        brightness = components.brightness
        alpha = components.alpha
        
        let mainColor: UIColor = UIColor(
            hue: hue,
            saturation: 1.0,
            brightness: 1.0,
            alpha: 1.0)
        
        hueSlider.minColor = mainColor
        hueSlider.thumbColor = mainColor
        brightnessSlider.maxColor = mainColor
        saturationSlider.maxColor = mainColor
        
        hueSlider.value = hue
        saturationSlider.value = saturation
        brightnessSlider.value = brightness
        
        updateColorView()
        
        self.action = action
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        Log("preferredHeight = \(preferredHeight)")
        
        saturationSlider.minColor = .white
        brightnessSlider.minColor = .black
        hueSlider.hasRainbow = true
        
        hueSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.hue = newValue
            let mainColor: UIColor = UIColor(
                hue: newValue,
                saturation: 1.0,
                brightness: 1.0,
                alpha: 1.0)
            
            self.hueSlider.thumbColor = mainColor
            self.brightnessSlider.maxColor = mainColor
            self.saturationSlider.maxColor = mainColor
            
            self.updateColorView()
            
            CATransaction.commit()
        }
        
        brightnessSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.brightness = newValue
            self.updateColorView()
            
            CATransaction.commit()
        }
        
        saturationSlider.actionBlock = { [unowned self] slider, newValue in
            CATransaction.begin()
            CATransaction.setValue(true, forKey: kCATransactionDisableActions)
            
            self.saturation = newValue
            self.updateColorView()
            
            CATransaction.commit()
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredHeight = mainStackView.frame.maxY
        Log("preferredHeight = \(preferredHeight)")
        
        ///
        if preferredHeight != 0 {
            //preferredContentSize.height = preferredHeight + 24
        }
        
        /// 
        Log("view bounds = \(view.bounds)")
    }
    
    func updateColorView() {
        colorView.backgroundColor = color
        action?(color)
        Log("set color = \(color.hexString)")
    }
}

