# Copyright (c) 2016 Jasper Lievisse Adriaanse <j@jasper.la>
# See LICENSE for details

require 'dockertags/version'
require 'dockertags/log'
require 'dockertags/db'
require 'dockertags/utils'
require 'dockertags/cli'
require 'dockertags/commands'

module DockerTags
  unless defined? @@database_path
    @@database_path = 'docker-tags.db'
  end

  def self.database_path
    @@database_path
  end

  def self.database_path=(path)
    @@database_path = path
  end
end
