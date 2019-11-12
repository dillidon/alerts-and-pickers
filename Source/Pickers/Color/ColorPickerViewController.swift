import UIKit

extension UIAlertController {
    
    /// Add a Color Picker
    ///
    /// - Parameters:
    ///   - color: input color
    ///   - action: for selected color
    
    public func addColorPicker(color: UIColor = .black, selection: ColorPickerViewController.Selection?) {
        let selection: ColorPickerViewController.Selection? = selection
        var color: UIColor = color
        
        let buttonSelection = UIAlertAction(title: "Select", style: .default) { action in
            selection?(color)
        }
        buttonSelection.isEnabled = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPickerViewController else { return }
        set(vc: vc)
        
        set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
        vc.set(color: color) { new in
            color = new
            self.set(title: color.hexString, font: .systemFont(ofSize: 17), color: color)
        }
        addAction(buttonSelection)
    }
}

public class ColorPickerViewController: UIViewController {
    
    public typealias Selection = (UIColor) -> Swift.Void
    
    fileprivate var selection: Selection?
    
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
    
    func set(color: UIColor, selection: Selection?) {
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
        
        self.selection = selection
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
    }
    
    func updateColorView() {
        colorView.backgroundColor = color
        selection?(color)
        Log("set color = \(color.hexString)")
    }
}

