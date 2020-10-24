Pod::Spec.new do |s|
  s.name             = 'SwiftUILazyGridView'
  s.version          = '0.1.0'
  s.summary          = 'Show a grid that lets items be lazily processed before being displayed'

  s.description      = <<-DESC
A pod that acts as an Array datasource and processor for items being displayed. Use this pod
when you need a quick and dirty Grid View with fixed columns and support for different orientations.

The pod is designed using a MVVM approach. This avoids shortcomings of SwiftUI where it is not 
directly possible to perform lazy loading without alot of States and Publishing.

This pod takes care of all that for you. You simply need to provide the Raw and Processed types,
process if needed and provide a view builder closure. You're done!
                       DESC

  s.homepage         = 'https://github.com/Thisura98/swiftui-lazy-gridview'
  s.screenshots      = 'https://raw.githubusercontent.com/Thisura98/swiftui-lazy-gridview/main/Documentation/main.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'thisura1998@gmail.com' => 'thisura@bhasha.lk' }
  s.source           = { :git => 'https://github.com/thisura1998@gmail.com/SwiftUILazyGridView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '4.0'
  s.ios.deployment_target = '13.0'

  s.source_files = 'SwiftUILazyGridView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftUILazyGridView' => ['SwiftUILazyGridView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
