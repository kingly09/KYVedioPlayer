Pod::Spec.new do |s|
s.name         = "KYVedioPlayer"
s.summary      = "KYVedioPlayer 是基于AVPlayer的封装视频播放器,支持播放mp4、m3u8、3gp、mov等格式；支持网络视频和本地视频播放；支持全屏和小屏幕播放；还在UITableViewCell中播放视频 ；支持横屏竖屏自动播放"
s.version      = '0.0.5'
s.homepage     = "https://github.com/kingly09/KYVedioPlayer"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author       = { "kingly" => "libintm@163.com" }
s.platform     = :ios, "7.0"
s.source       = { :git => "https://github.com/kingly09/KYVedioPlayer.git", :tag => s.version.to_s }
s.social_media_url   = "https://github.com/kingly09"
s.source_files = 'KYVedioPlayerLib/*.{h,m}'
s.resource = 'KYVedioPlayerLib/KYVedioPlayer.bundle'
s.frameworks = "MediaPlayer", "AVFoundation", "UIKit"
s.dependency "Masonry", "~> 1.0.1"
s.requires_arc = true
end
