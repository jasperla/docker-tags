# Copyright (c) 2016 Jasper Lievisse Adriaanse <j@jasper.la>
# See LICENSE for details

require 'sqlite3'

module DockerTags
  class Db
    CREATE_IMAGES_TABLE = %{
      CREATE TABLE IF NOT EXISTS images (
        name varchar(30),
        latest varchar(16)
      );
    }

    CREATE_TAGS_TABLE = %{
      CREATE TABLE IF NOT EXISTS tags (
        tag varchar(30),
        layer varchar(8),
	image varchar(16)
      );
    }

    def initialize(as_hash = true)
      begin
        @dbh = SQLite3::Database.new DockerTags.database_path
        @dbh.results_as_hash = as_hash
      rescue SQLite3::Exception => e
        DockerTags::Log.sql_err(e, __method__)
      end
    end

    def query(query)
      begin
        @dbh.execute(query)
      rescue SQLite3::Exception => e
        DockerTags::Log.sql_err(e, __method__)
      end
    end

    def close
      @dbh.close if @dbh
    end

    def changes
      @dbh.changes
    end
  end
end
