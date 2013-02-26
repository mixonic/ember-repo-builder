ember-repo-builder
==================

Build Ember.js from its repo and publish the fiddle-ready files

View it in action at
[http://ember-repo-builder.madhatted.com/](http://ember-repo-builder.madhatted.com/).

Installation
==============
 * export the following three variables into your environment:
   * S3_ACCESS_KEY
   * S3_SECRET_KEY
   * S3_BUCKET
 * globally install a javascript runtime (node, therubyracer, etc)
   (must be visible to [execjs](https://github.com/sstephenson/execjs))
 * install redis (ember-repo-builder stores its build information
   in redis)

Installation advanced
==========
 * sudo yum install gcc-c++
 * gem install rake libv8 therubyracer

Troubleshooting
==========
 * Try running the builder by hand from irb:
   * `cd <project-dir>; bundle exec irb -r ./overalls.rb`
   * `>> Builder.new.run`
 * Look at the unicorn logs in
   `<project-dir>/log/unicorn.std(out|err).log`
