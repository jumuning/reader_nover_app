#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint rust_lib_reader_nover.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'rust_lib_reader_nover'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  s.swift_version = '5.0'

  s.vendored_frameworks = 'Frameworks/RustCore.xcframework'
  # flutter_rust_bridge opens rust_lib_reader_nover.framework on iOS. Force
  # the static archive into that framework rather than the Runner executable.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Flutter.framework does not contain a i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -force_load ${PODS_TARGET_SRCROOT}/Frameworks/RustCore.xcframework/ios-arm64/librust_lib_reader_nover.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -force_load ${PODS_TARGET_SRCROOT}/Frameworks/RustCore.xcframework/ios-arm64-simulator/librust_lib_reader_nover.a',
  }
end
