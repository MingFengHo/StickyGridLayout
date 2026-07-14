Pod::Spec.new do |s|
  s.name             = 'StickyGridLayout'
  s.version          = '1.0.0'
  s.summary          = 'A spreadsheet-style UICollectionViewLayout with frozen header rows and columns.'

  s.description      = <<-DESC
  StickyGridLayout is a data-driven UICollectionViewLayout that freezes any number
  of header rows and columns — like freeze panes in a spreadsheet — while the body
  scrolls freely in both directions. The layout geometry is a pure-Swift, UIKit-free
  core, so the sizing and pinning math is independently unit-testable.
  DESC

  s.homepage         = 'https://github.com/MingFengHo/StickyGridLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ming Feng Ho' => 'MingFengHo@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/MingFengHo/StickyGridLayout.git', :tag => s.version.to_s }

  s.ios.deployment_target  = '12.0'
  s.tvos.deployment_target = '12.0'
  s.swift_version          = '5.7'

  s.source_files = 'Sources/StickyGridLayout/**/*.swift'
end
