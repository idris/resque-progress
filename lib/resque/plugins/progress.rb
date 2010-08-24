require 'resque/plugins/meta'

module Resque
  module Plugins
    module Progress
      def self.extended(mod)
        mod.extend(Resque::Plugins::Meta)
        Resque::Plugins::Meta::Metadata.send(:include, Resque::Plugins::Progress::Metadata)
      end

      def at(num, total, message)
        meta = get_meta(meta_id)
        meta.progress = [num, total, message]
        meta.save
      end

      module Metadata
        def progress
          p = self['progress'] || [0, 1, nil]
          { :num => p[0].to_i, :total => p[1].to_i, :percent => 100*(p[0].to_f / p[1].to_i), :message => p[2] }
        end

        def progress=(p)
          self['progress'] = p
        end
      end
    end
  end
end