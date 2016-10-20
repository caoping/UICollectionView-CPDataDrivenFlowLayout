Pod::Spec.new do |s|
  s.name         = "CPDataDrivenFlowLayout"
  s.version      = "0.1.0"
  s.summary      = "UICollectionView-CPDataDrivenFlowLayout是一个通过使用cell描述信息来驱动UICollectionView布局类"
  s.homepage     = "https://github.com/caoping/UICollectionView-CPDataDrivenFlowLayout"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "caoping" => "caoping.dev@gmail.com" }
  s.social_media_url   = "http://weibo.com/caoping"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/caoping/UICollectionView-CPDataDrivenFlowLayout.git", :tag => s.version }
  s.source_files = "CPDataDrivenFlowLayout/*.{h,m}"
  s.requires_arc = true
end
