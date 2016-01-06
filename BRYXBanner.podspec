Pod::Spec.new do |s|
  s.name             = "BRYXBanner"
  s.version          = "0.5.1"
  s.summary          = "A lightweight dropdown notification for iOS 7+, in Swift."
  s.homepage         = "https://github.com/bryx-inc/BRYXBanner"
  s.license          = 'MIT'
  s.author           = { "Harlan Haskins" => "harlan@harlanhaskins.com" }
  s.source           = { :git => "https://github.com/bryx-inc/BRYXBanner.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |sp|
    sp.source_files = 'Pod/Classes/**/*'
   sp.resource_bundles = {
     'BRYXBanner' => ['Pod/Assets/*.png']
   }
  end

  s.subspec "TestHelpers" do |sp|
    sp.source_files = 'Pod/Test Helpers/**/*'
    sp.dependency 'BRYXBanner/Core'
  end

end
