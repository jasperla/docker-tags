# Copyright (c) 2016 Jasper Lievisse Adriaanse <j@jasper.la>
# See LICENSE for details

module DockerTags
  module Utils
    # basic image name validation. cannot be empty of contain spaces
    def self.valid_image?(name)
      if name.nil? || name.empty? || (name.length != name.sub(/\s*/, "").length)
        nil
      else
        true
      end
    end
  end
end
