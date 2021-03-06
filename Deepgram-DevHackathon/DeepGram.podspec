Pod::Spec.new do |s|
  s.name             = "DeepGram"
  s.version          = "0.1.5"
  s.summary          = "Use AI to spot keywords and get insights in audio"
  s.description      = "DeepGram uses artificial intelligence to recognize speech, search for moments, and categorize audio and video. Try it on calls, meetings, podcasts, video clips, lectures—and get actionable insights from an easy to use API."
  s.homepage         = "https://www.deepgram.com"
  s.license          = 'MIT'
  s.requires_arc = true
  s.frameworks = 'Foundation'

    s.subspec 'Core' do |ss|
    ss.public_header_files = 'Pod/Classes/DeepGram.h'
    ss.source_files = 'Pod/Classes/DeepGram.{h,m}'
    ss.dependency 'AFNetworking/NSURLSession', '~> 3.0'
    end

    s.subspec 'PromiseKit' do |ss|
    ss.public_header_files = 'Pod/Classes/DeepGram+PromiseKit.h'
    ss.source_files = 'Pod/Classes/DeepGram+PromiseKit.{swift,h,m}'
    ss.dependency 'PromiseKit/CorePromise', '~> 3.0'
    ss.dependency 'DeepGram/Core'
    end

end
