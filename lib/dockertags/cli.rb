# Copyright (c) 2016 Jasper Lievisse Adriaanse <j@jasper.la>
# See LICENSE for details

require 'commander/import'

module DockerTags
  class Cli
    program :name, 'Docker Tags'
    program :version, DockerTags::VERSION
    program :description, 'Stay notified of new image tags'

    default_command :report

    command :report do |c|
      c.syntax = 'docker-tag-notify report [options]'
      c.description = 'Report of any new tags, correlating layers'
      c.option '--image NAME', String, 'Name of image to follow'
      c.option '--db /path/to/dtn.db', String, 'path to database'
      c.action do |args, options|
        options.default image: args[0]
        options.default db: DockerTags.database_path

        DockerTags.database_path = options.db

        DockerTags::Log.warn("Ignoring arguments #{args[1..-1]}") if args.length > 1
        DockerTags::Commands.report(options.image)
      end
    end

    command :latest do |c|
      c.syntax = 'docker-tag-notify latest [options]'
      c.description = 'Get the "latest" tag/aliases'
      c.option '--image NAME', String, 'Name of image to follow'
      c.option '--db /path/to/dtn.db', String, 'path to database'
      c.action do |args, options|
        options.default image: args[0]
        options.default db: DockerTags.database_path

        DockerTags.database_path = options.db

        DockerTags::Log.warn("Ignoring arguments #{args[1..-1]}") if args.length > 1
        DockerTags::Commands.latest(options.image)
      end
    end

    command :follow do |c|
      c.syntax = 'docker-tag-notify follow <image>'
      c.description = 'Track a new image and add current known tags to the db'
      c.option '--image NAME', String, 'Name of image to follow'
      c.option '--db /path/to/dtn.db', String, 'path to database'
      c.action do |args, options|
        options.default image: args[0]
        options.default db: DockerTags.database_path

        DockerTags.database_path = options.db

        DockerTags::Log.warn("Ignoring arguments #{args[1..-1]}") if args.length > 1
        DockerTags::Log.err("Invalid image name: '#{options.image}'") unless DockerTags::Utils.valid_image?(options.image)
        DockerTags::Commands.follow(options.image)
      end
    end

    command :unfollow do |c|
      c.syntax = 'docker-tag-notify unfollow <image>'
      c.description = 'Stop tracking an image and purge it from the db'
      c.option '--image NAME', String, 'Name of image to stop following'
      c.option '--db /path/to/dtn.db', String, 'path to database'
      c.action do |args, options|
        options.default image: args[0]
        options.default db: DockerTags.database_path

        DockerTags.database_path = options.db

        DockerTags::Log.warn("Ignoring arguments #{args[1..-1]}") if args.length > 1
        DockerTags::Log.err("Invalid image name: '#{options.image}'") unless DockerTags::Utils.valid_image?(options.image)
        DockerTags::Commands.unfollow(options.image)
      end
    end

    command :initdb do |c|
      c.syntax = 'docker-tag-notify init [options]'
      c.description = 'Setup and initialize the database'
      c.option '--db /path/to/dtn.db', String, 'path to database'
      c.action do |args, options|
        options.default db: DockerTags.database_path

        DockerTags.database_path = options.db

        DockerTags::Commands.initdb
      end
    end

    command :dump do |c|
      c.syntax = 'docker-tag-notify dump [options]'
      c.description = 'Print the full database contents'
      c.option '--db /path/to/dtn.db', String, 'path to database'
      c.action do |_, options|
        options.default db: DockerTags.database_path

        DockerTags.database_path = options.db

        DockerTags::Commands.dump
      end
    end
  end
end
