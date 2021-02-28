Pod::Spec.new do |s|

  s.name                = "Atomicable"
  s.version             = "1.0.0"
  s.summary             = "Atomic property wrappers for thread-safety and peace of mind"
  s.screenshot          = "https://github.com/BellAppLab/Atomicable/raw/master/Images/Atomicable.png"

  s.description         = <<-DESC
Atomicable is a handy property wrapper that makes modifying properties an atomic operation via the use of locks.

Adapted from and inspired by [Mattt](https://github.com/mattgallagher/CwlUtils).
                   DESC

  s.homepage            = "https://github.com/BellAppLab/Atomicable"

  s.license             = { :type => "MIT", :file => "LICENSE" }

  s.author              = { "Bell App Lab" => "apps@bellapplab.com" }
  s.social_media_url    = "https://twitter.com/BellAppLab"

  s.ios.deployment_target       = "10.0"
  s.tvos.deployment_target      = "10.0"
  s.watchos.deployment_target   = "3.0"
  s.osx.deployment_target       = "10.12"

  s.swift_versions      = ['4.2', '5.0', '5.1', '5.2', '5.3']

  s.module_name         = 'Atomicable'

  s.source              = { :git => "https://github.com/BellAppLab/Atomicable.git", :tag => "#{s.version}" }

  s.source_files        = "Sources/Atomicable"
end
