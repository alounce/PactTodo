platform :ios, '11.0'

# Pods for PactTodo
def appPods
  use_frameworks!
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git'
  pod 'OHHTTPStubs/Swift', '6.1.0'
end

target 'Todo' do
  appPods
  
  target 'TodoUnitTests' do
    inherit! :search_paths
    appPods
  end
  
  target 'TodoPactTests' do
      inherit! :search_paths
      appPods
      pod 'PactConsumerSwift', :git => 'https://github.com/DiUS/pact-consumer-swift', :branch => 'master'
  end

# Disable Code Coverage for Pods projects
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end

end
