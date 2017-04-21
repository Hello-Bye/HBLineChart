
Pod::Spec.new do |s|

  s.name         = "HBLineChart"
  s.version      = "0.0.2"
  s.summary      = "drawing line chart tool of HBLineChart."

  s.description  = "A drawing line chart tool of HBLineChart."

  s.homepage     = "https://github.com/Hello-Bye/HBLineChart"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Chenzuliang" => "chenzuliang@geek-zoo.com" }
  # Or just: s.author    = "Chenzuliang"
  # s.authors            = { "Chenzuliang" => "chenzuliang@geek-zoo.com" }
  # s.social_media_url   = "http://twitter.com/Chenzuliang"

  # s.platform     = :ios
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Hello-Bye/HBLineChart.git", :tag => s.version }

  s.source_files  = "HBLineChart/**/*"
  s.exclude_files = "HBLineChart/UIView+TPAdditions.{h,m}"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
