# docker-tags

Track latest tags for Docker images.

## Installation

Run from a git clone:

```
git clone https://github.com/jasperla/docker-tags
bundle install --path vendor/bundle
```

or install the gem:

```
gem install docker-tags
```

## Usage

All the commands for `docker-tags` take a `--db /path/to/db`
argument to select the SQLite database. Bu default
`$PWD/docker-tags.db` is used.

### Initialize the database

This creates an empty database and creates the needed tables:

```
docker-tags initdb
```

### Follow and unfollow an image

In order to start tracking the tags for an image, we have to start
following it:

```
docker-tags follow jasperla/docker-go-cross
```

In order to stop tracking, run the same command but with `unfollow`.

### Show latest tag

```
docker-tags latest jasperla/docker-go-cross
```

This will return a JSON hash for this particular image:

```
{
  "jasperla/docker-go-cross": {
    "image": "jasperla/docker-go-cross",
    "layer": "c2c017e1",
    "tag": "latest"
  }
}
```

In this case there is only one tag, `latest` (which is otherwise
filtered). If we follow more images, we can run `latest` without any
arguments and the latest tags for all images will be displayed.

### Report

To generate a report based on the new tags that were pushed to the
Docker Hub since the last time `latest` or `report` were ran:

```
docker-tags report jasperla/docker-go-cross
```

Just like `latest`, `report` will also work without any arguments.

### Dump all known tags

Essentially a SQL to JSON conversion of the database:

```
docker-tags dump
```

## ToDo

- tests and docs (oh the irony)

## Copyright and license

MIT, please see the LICENSE file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
