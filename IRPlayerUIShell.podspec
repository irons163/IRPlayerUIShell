Pod::Spec.new do |spec|
  spec.name         = "IRPlayerUIShell"
  spec.version      = "1.0.0"
  spec.summary      = "IRPlayerUIShell is a powerful UI Shell framework for the video player(IRPlayer) for iOS."
  spec.description  = "IRPlayerUIShell is a powerful UI Shell framework for the video player(IRPlayer) for iOS."
  spec.homepage     = "https://github.com/irons163/IRPlayerUIShell.git"
  spec.license      = "MIT"
  spec.author       = "irons163"
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/irons163/IRPlayerUIShell.git", :tag => spec.version.to_s }
  spec.source_files  = "IRPlayerUIShell/**/*.{h,m,xib}"
  spec.resources = ["IRPlayerUIShell/**/*.xcassets"]
end
