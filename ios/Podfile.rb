# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
# Disable CocoaPods analytics by adding the following line:
# ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# You can uncomment the next line to define a global platform for your project
#platform :ios, '12.0'

# The target is the name of your Flutter project
target 'Runner' do
  # Flutter Pods
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

# Add additional targets or configurations if necessary
# If you have a separate target for tests or other modules, you can add them here.
# For example:
# target 'RunnerTests' do
#   inherit! :search_paths
#   # Add your test dependencies here
# end
