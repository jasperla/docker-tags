# Copyright (c) 2016 Jasper Lievisse Adriaanse <j@jasper.la>
# See LICENSE for details

require 'faraday'
require 'json'

module DockerTags
  module Commands
    def self.follow(image)
      dbh = DockerTags::Db.new

      # There can only be one.
      r = dbh.query "SELECT name FROM images WHERE name = '#{image}'"
      if r.size > 0
        DockerTags::Log.err("Already following image '#{image}'")
      end

      dbh.query "INSERT INTO images VALUES('#{image}', '')"
      dbh.close
    end

    def self.unfollow(image)
      dbh = DockerTags::Db.new
      dbh.query "DELETE FROM images WHERE name = '#{image}'"
      dbh.query "DELETE FROM tags WHERE image = '#{image}'"

      n = dbh.changes
      puts "Succesfully removed #{n - 1} tags for #{image}" if n > 0
      dbh.close
    end

    def self.initdb
      dbh = DockerTags::Db.new

      dbh.query DockerTags::Db::CREATE_IMAGES_TABLE
      dbh.query DockerTags::Db::CREATE_TAGS_TABLE

      dbh.close
    end

    def self.dump
      dbh = DockerTags::Db.new

      data = {}
      data[:images] = dbh.query 'SELECT * FROM images'
      data[:tags] = dbh.query 'SELECT * FROM tags'

      puts JSON.pretty_generate(data)
      dbh.close
    end

    def self.get_images
      dbh = DockerTags::Db.new false

      r = dbh.query('SELECT name FROM images')

      images = []
      r.each { |i| images << i[0] }
      dbh.close

      images
    end

    def self.report(image)
      if image.nil? || image == ''
        images = get_images
      else
        images = [image]
      end

      result = {}
      images.each do |i|
        new_tags = sync_tags(i)
        if new_tags.size > 0
          r = { image => { tags: [] } }
          new_tags.each do |t|
            r[image][:tags] << {
              tag:   t['name'],
              layer: t['layer']
            }
          end

          result[i] = r
        end
      end

      puts JSON.pretty_generate(result)
    end

    def self.latest(image)
      if image.nil? || image == ''
        image_names = get_images
      else
        image_names = [image]
      end

      latest_images = {}
      image_names.each do |i|
        sync_tags(i)

        dbh = DockerTags::Db.new
        rows = dbh.query "SELECT latest FROM images WHERE name = '#{i}'"
        latest_layer = rows[0]['latest']

        rows = dbh.query "SELECT tag, layer FROM tags WHERE layer = '#{latest_layer}' AND tag != 'latest'"
        dbh.close

        image_result = {
          image: i,
          layer: latest_layer,
          tag: []
        }

        # Image only has the 'latest' tag, do display it in that case.
        if rows.empty?
          image_result[:tag] = 'latest'
        else
          rows.each { |t| image_result[:tag] << t['tag'] }
        end

        latest_images[i] = image_result
      end

      puts JSON.pretty_generate(latest_images)
    end

    def self.sync_tags(image)
      conn = Faraday.new(url: 'https://registry.hub.docker.com/v1') do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end

      resp = conn.get "repositories/#{image}/tags"
      status = resp.status

      if status == 404
        DockerTags::Log.err("Could not find image '#{image}' on Docker Hub")
      elsif status != 200
        DockerTags::Log.err("Could not retrieve tags for '#{image}' (error: #{status})")
      end

      all_tags = JSON.parse(resp.body)

      dbh = DockerTags::Db.new

      # Now get all the existing tags for this image
      current_tags = dbh.query "SELECT tag AS name, layer AS layer FROM tags WHERE image = '#{image}'"

      # prune the results
      current_tags.each { |t| t.delete(0); t.delete(1) }

      # Compare the existing tags with what we've just fetched.
      # Save the result of the difference and return that later.
      new_tags = all_tags - current_tags

      # Finish by inserting the list of new tags.
      new_tags.each do |t|
        dbh.query "INSERT INTO tags VALUES('#{t['name']}','#{t['layer']}','#{image}')"
      end

      latest = all_tags.select { |t| t['name'] == 'latest' }
      if latest.size > 0
        # Set the latest layer
        dbh.query "UPDATE images SET latest = '#{latest[0]['layer']}' WHERE name = '#{image}'"
      end

      dbh.close

      # Return the hash of differences for #report to handle
      new_tags
    end
  end
end
