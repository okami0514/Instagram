# Uncomment the next line to define a global platform for your project
platform :ios, '16.1'

target 'Instagram' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Instagram
  pod 'FirebaseAnalytics', '10.3.0'
  pod 'FirebaseAuth', '10.3.0'
  pod 'FirebaseFirestore', '10.3.0'
  pod 'FirebaseStorage', '10.3.0'
  pod 'FirebaseStorageUI', '12.3.0'
  pod 'SVProgressHUD', '2.2.5'
  pod 'CLImageEditor/AllTools', '0.2.4'
end
post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end









