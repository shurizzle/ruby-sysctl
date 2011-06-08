Gem::Specification.new {|g|
    g.name          = 'sysctl'
    g.version       = '0.0.1.alpha1'
    g.author        = 'shura'
    g.email         = 'shura1991@gmail.com'
    g.homepage      = 'http://github.com/shurizzle/ruby-sysctl'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'A wrapper around sysctl to make its use cool in OpenBSD too'
    g.summary       = 'A wrapper around sysctl to make its use cool in OpenBSD too'
    g.files         = Dir.glob('lib/**/*')
    g.require_path  = 'lib'
    g.executables   = [ ]

    g.add_dependency('ffi')
    g.add_dependency('memoized')
}
