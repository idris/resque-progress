resque-progress
===============
Depends on [Resque](http://github.com/defunkt/resque/) 1.8 and 
[resque-meta](http://github.com/lmarlow/resque-meta/) 1.0.0


About
-----
Inspired by [resque-status](http://github.com/quirkey/resque-status/). 
Unfortunately, resque-status seems incompatible with resque-meta, so this 
plugin uses resque-meta to provide a similar functionality. This plugin 
differs a bit because it's mainly focused on progress. The resque-meta plugin 
already includes methods for `finished?`, `working?`, `succeeded?`, etc.


Examples
--------
	class MyJob
	  extend Resque::Plugins::Progress

	  def self.perform(meta_id, *args)
	    (0..9).each do |i|
	      at(i, 10, "Lifted \#{num} heavy things. \#{10-num} more to go!")
	      heavy_lifting(i)
	    end
		at(10, 10, "Finished lifting everything. Kthxbai!")
	  end
	end

	meta0 = MyJob.enqueue('stuff')
	meta0.progress.num_complete # => 0
	meta0.progress.total # => 10
	meta0.progress.percent # => 100
	meta0.progress.message # => nil

	# later
	meta1 = MyJob.get_meta('03c9e1a045ad012dd20500264a19273c')
	meta1.finished? # => false
	meta1.progress.num_complete # => 4
	meta1.progress.total # => 10
	meta1.progress.percent # => 40
	meta1.progress.message # => 'Lifted 4 heavy things. 6 more to go!'


Requirements
------------
* [resque](http://github.com/defunkt/resque/) 1.8
* [resque-meta](http://github.com/lmarlow/resque-meta/) 1.0.0