require 'digest/sha1'
require 'resque'
require 'resque/plugins/progress'
require 'resque/plugins/progress/version'

class ProgressJob
  extend Resque::Plugins::Progress
  @queue = :test

  def self.expire_meta_in
    10
  end

  def self.meta_id(*args)
    Digest::SHA1.hexdigest([rand.to_s, self, args].join)
  end

  def self.perform(meta_id)
    (0..4).each do |i|
      at(i, 5, 'working')
    end
    at(5, 5, 'complete')
  end
end

class IncludeBothJob
  extend Resque::Plugins::Meta
  extend Resque::Plugins::Progress
  @queue = :test

  def self.expire_meta_in
    10
  end

  def self.meta_id(*args)
    Digest::SHA1.hexdigest([rand.to_s, self, args].join)
  end

  def self.perform(meta_id)
    (0..4).each do |i|
      at(i, 5, 'working')
    end
    at(5, 5, 'complete')
  end
end


class ProgressTest < Test::Unit::TestCase
  def setup
    Resque.redis.flushall
  end

  def test_resque_version
    major, minor, patch = Resque::Version.split('.')
    assert_equal 1, major.to_i
    assert minor.to_i >= 8
  end

  def test_meta_version
    major, minor, patch = Resque::Plugins::Meta::Version.split('.')
    assert_equal 1, major.to_i
  end

  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::Progress)
    end
  end

  def test_initial_progress
    meta = ProgressJob.enqueue
    assert_not_nil(meta)
    assert_not_nil(meta.progress)
    assert_equal(0, meta.progress[:num])
    assert_equal(1, meta.progress[:total])
    assert_equal(0, meta.progress[:percent])
    assert_nil(meta.progress[:message])
  end

  def test_final_progress
    meta = ProgressJob.enqueue
    worker = Resque::Worker.new(:test)
    worker.work(0)

    meta = ProgressJob.get_meta(meta.meta_id)
    assert_not_nil(meta)
    assert(meta.finished?)
    assert_not_nil(meta.progress)
    assert_equal(5, meta.progress[:num])
    assert_equal(5, meta.progress[:total])
    assert_equal(100, meta.progress[:percent])
    assert_equal('complete', meta.progress[:message])
  end

  def test_include_both
    meta = IncludeBothJob.enqueue
    assert_not_nil(meta)
    assert_not_nil(meta.progress)
    assert_equal(0, meta.progress[:num])
    assert_equal(1, meta.progress[:total])
    assert_equal(0, meta.progress[:percent])
    assert_nil(meta.progress[:message])

    worker = Resque::Worker.new(:test)
    worker.work(0)

    meta = IncludeBothJob.get_meta(meta.meta_id)
    assert_not_nil(meta)
    assert(meta.finished?)
    assert_not_nil(meta.progress)
    assert_equal(5, meta.progress[:num])
    assert_equal(5, meta.progress[:total])
    assert_equal(100, meta.progress[:percent])
    assert_equal('complete', meta.progress[:message])
  end
end