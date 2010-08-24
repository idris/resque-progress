require 'lib/resque/plugins/progress/version'

Gem::Specification.new do |s|
  s.name              = 'resque-progress'
  s.version           = Resque::Plugins::Progress::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'A Resque plugin for progress updates on jobs.'
  s.homepage          = 'http://github.com/idris/resque-progress'
  s.email             = 'idris@umd.edu'
  s.authors           = [ 'Idris Mokhtarzada' ]
  s.has_rdoc          = false

  s.files             = %w( README.markdown Rakefile LICENSE )
  s.files            += Dir.glob('lib/**/*')
  s.files            += Dir.glob('test/**/*')

  s.add_dependency 'resque', '>= 1.8.0'
  s.add_dependency 'resque-meta', '>= 1.0.0'

  s.description       = <<description
A Resque plugin that provides helpers for progress updates from within your 
jobs.

For example:

    class MyJob
      extend Resque::Plugins::Progress

      def self.perform(meta_id, *args)
        (0..10).each do |i|
          at(i, 10, "Lifted \#{num} heavy things. \#{10-num} more to go!")
          heavy_lifting(i)
        end
      end
    end

    meta0 = MyJob.enqueue('stuff')
    meta0.progress.num_complete # => 0
    meta0.progress.total # => 10
    meta0.progress.percent # => 100
    meta0.progress.message # => nil

    # later
    meta1 = MyJob.get_meta('03c9e1a045ad012dd20500264a19273c')
    meta1.progress.num_complete # => 4
    meta1.progress.total # => 10
    meta1.progress.percent # => 40
    meta1.progress.message # => 'Lifted 4 heavy things. 6 more to go!'
description
end