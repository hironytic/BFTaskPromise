Pod::Spec.new do |s|
  s.name         = "BFTaskPromise"
  s.version      = "2.2.0"
  s.summary      = "An Objective-C category for BFTask class in Bolts-iOS."

  s.description  = <<-DESC
                   An Objective-C category for BFTask class in Bolts-iOS.
                   
                   With this category, you can:
                   
                   * chain tasks with dot-notation as JavaScript Promise-like syntax. (no more counting brackets!)
                   * write a catch block which will be called in error case only.
                   * write a finally block which will not change the result value unless the block fails.
                   DESC

  s.homepage     = "https://github.com/hironytic/BFTaskPromise"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Hironori Ichimiya" => "hiron@hironytic.com" }

  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/hironytic/BFTaskPromise.git", :tag => "v#{s.version}" }
  s.source_files  = "Classes/*.{h,m}"
  
  s.requires_arc = true

  s.dependency 'Bolts/Tasks', '~> 1.9'
end
