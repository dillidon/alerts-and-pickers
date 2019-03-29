Pod::Spec.new do |s|
s.name         = "Alerts&Pickers"
s.version      = "1.0.0"
s.summary      = "Advanced usage of native UIAlertController with TextField, TextView, DatePicker, PickerView, TableView, CollectionView and MapView."
s.homepage     = "https://github.com/dongdongpc/alerts-and-pickers.git"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Yuji Hato" => "1192490197@qq.com" }
s.platform     = :ios
s.ios.deployment_target = "9.0"
s.source       = { :git => "https://github.com/dongdongpc/alerts-and-pickers.git", :tag => s.version }
s.source_files  = "Source/"
s.requires_arc = true
end
