Gem::Specification.new do |s|
  s.name        = 'pulseaudio_simple_ffi'
  s.version     = '0.0.1'
  s.summary     = 'A Ruby-FFI implementation of the PulseAudio Simple API.'
  s.description = s.summary
  s.author      = 'Benjamin Cook'
  s.email       = 'root@baryon.it'
  s.files       << 'lib/pulseaudio_simple_ffi.rb'
  s.homepage    = 'https://github.com/Canar/pulseaudio_simple_ffi'
  s.add_runtime_dependency 'ffi', '>= 1.15'
  s.required_ruby_version = '>= 3.0'
end
