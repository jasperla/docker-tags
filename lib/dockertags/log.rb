# Copyright (c) 2016 Jasper Lievisse Adriaanse <j@jasper.la>
# See LICENSE for details

module DockerTags
  module Log
    def self.warn(str)
      puts "WARN: #{str}"
    end

    def self.err(str)
      puts "ERROR: #{str}"
      exit
    end

    def self.sql_err(e, m)
      puts "An SQLite error occured in #{m}: #{e}"
      exit
    end
  end
end
