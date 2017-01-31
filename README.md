# News Aggregator

New Aggregator is a quick and dirty project to collect and store new stories from (ogili.com)[http://ogili.com] in Redis.

## Usage:

1. Clone the repository and install all of the gem dependencies

`bundle install`

2. Install and ensure that Redis is running (https://redis.io)[https://redis.io/download#installation]

`redis-server`

3. Fetch news stories

`rake fetch`

## Additional News Stories:

By default News Aggregator will only fetch one zip file archive of news stories. If you want to process more archives then pass the number of additional archives you'd like to process as an argument in the rake task.

`rake fetch[10]`

## Redis Storage

Each story is unique based on it's `post_url`. We use the `post_url` as the primary key in Redis. If needed we can make a compound key that might be easier to search or filter.

```ruby
key = "#{date_posted}:#{post_url}"
```

Currently, you can see the documents in redis by running the following from the redis-cli:

`$ redis-cli`
`127.0.0.1:6379> KEYS news-aggregator|*`

## Contributors

 * Eric Shelley ([@bartimaeus](https://github.com/bartimaeus))

## Copyright

Copyright (c) 2017 Eric Shelley. See LICENSE.txt for further details.
