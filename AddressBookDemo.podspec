Pod::Spec.new do |s|

s.name         = 'AddressBookDemo'
s.version      = '0.0.1'
s.summary      = 'AddressBookDemo is a demo frameWork easy to develop iOS'
s.homepage     = 'https://github.com/huangweisheng/AddressBookDemo'
s.platform     = :ios, '9.0'
s.license      = 'MIT'
s.author       = { 'backup' => '946041092@qq.com' }
s.source       = { :git => 'https://github.com/huangweisheng/AddressBookDemo.git',:tag => s.version.to_s }
s.requires_arc          = true
s.source_files = 'AddressBookDemo/*.{h,m}'
s.frameworks   = 'CoreFoundation','Foundation','UIKit'

end
