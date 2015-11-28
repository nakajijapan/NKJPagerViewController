Pod::Spec.new do |s|
  s.name         = "NKJPagerViewController"
  s.version      = "1.0.0"
  s.summary      = "NKJPagerViewController is like a PagerTabStrip, which is in Android. It contains an endlessly scrollable UIScrollView."
  s.homepage     = "https://github.com/nakajijapan/NKJPagerViewController"
  s.screenshots  = "https://raw.githubusercontent.com/nakajijapan/NKJPagerViewController/master/swipe.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.social_media_url   = "https://twitter.com/nakajijapan"
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/nakajijapan/NKJPagerViewController.git", :tag => s.version.to_s }
  s.source_files = "Classes/**/*.{h,m}"
  s.requires_arc = true
end
