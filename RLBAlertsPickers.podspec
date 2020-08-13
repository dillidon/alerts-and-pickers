Pod::Spec.new do |s|

  s.name         = 'RLBAlertsPickers'
  s.version      = '1.1.1'
  s.summary      = 'Advanced usage of UIAlertController with TextField, DatePicker, PickerView, TableView and CollectionView adapted for using in DialogSDK'
  s.homepage     = 'https://github.com/loicgriffie/Alerts-Pickers'
  s.license      = 'MIT'
  s.author       = { 'dillidon' => 'dillidon@gmail.com' }
  s.platform     = :ios, '11.4'
  s.swift_version = '4.2'
  s.source       = { :git => 'https://github.com/loicgriffie/Alerts-Pickers.git', :tag => s.version }
  s.source_files  = 'Source/**/*.{swift}'
  s.resource_bundles  = {
    'Countries' => 'Source/Pickers/Locale/Countries.bundle/**'
  }
  s.resources = 'Example/Resources/*.xcassets'

end
