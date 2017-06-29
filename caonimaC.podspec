
Pod::Spec.new do |s|

s.name         = "caonimaC"
s.version      = "0.0.1"
s.summary      = "A marquee view used on iOS."
s.description  = <<-DESC
It is a marquee view used on iOS, which implement by Objective-C.
DESC

s.homepage     = "https://github.com/fangtianfu/caonimaC"
# s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

s.license          = { :type => "MIT", :file => "LICENSE" }

s.author       = { "方天福" => "fangtianfu@adsmart.com.cn" }

s.source       = { :git => "https://github.com/fangtianfu/caonimaC.git", :tag => "#{s.version}" }


s.platform     = :ios, '8.0'
# s.ios.deployment_target = '5.0'
# s.osx.deployment_target = '10.7'
s.requires_arc = true

s.source_files  = 'ADSSmartConfig/ADSSmartConfig/ESP_File/**/*.{h,m}'

# s.resources = 'Assets'

# s.ios.exclude_files = 'Classes/osx'
# s.osx.exclude_files = 'Classes/ios'
# s.public_header_files = 'Classes/**/*.h'
s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit'

end
