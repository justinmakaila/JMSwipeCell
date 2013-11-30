Pod::Spec.new do |s|
  s.name         = "JMSwipeCell"
  s.version      = "0.0.2"
  s.summary      = "Recreation of the iMessage UITableViewCell"
  s.homepage     = "https://github.com/justinmakaila/JMSwipeCell"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "justinmakaila" => "justinmakaila@gmail.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/justinmakaila/JMSwipeCell.git", :tag => "0.0.2" }
  s.source_files  = 'JMSwipeCell', 'JMSwipeCell/**/*.{h,m}'
end
