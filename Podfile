# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'STAR' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for STAR

  # Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'GoogleSignIn'

  # Realm
  pod 'RealmSwift'
  
  # UI Constraints
  pod 'SnapKit', '~> 3.0'
  
  # Image Caching
  pod 'Haneke', '~> 1.0'
  
  
  # Required by Realm to accomadate xcode 8.0
  post_install do |installer|
	  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
		config.build_settings['SWIFT_VERSION'] = '3.0' # or '3.0'
	end
	  end
  end

end
