# Renewzle

This is a solar calculator and lead generator I built several years ago with a small team including David Anderson, Brad Smith, Russ Smith and Noel Jackson. The business never took off, so we decided to finally open source it. I've never really cared for the name, but perhaps the calculator model will be of interest to someone :P

I've stripped out a lot of company-specific content, plugins and other assorted junk. You'll find most of the necessary data (which, I'm sure, is now hopelessly out of date) in vendor/data. The core of the calculator is in app/models/calculation_engine.rb.

The plugins we were originally using included:

* active_merchant
* acts_as_soft_deletable
* geokit
* rspec
* rspec-rails
* ssl_requirement
* type_attributes
* upload_column
* webrat
* will_paginate

You'll also find a bunch of OmniGraffle schematics in doc that might be interesting.

All of the code that's ours is under the MIT license. 

The static content (including the OmniGraffle documents) are [Creative Commons Attribution-NonCommercial-ShareAlike](http://creativecommons.org/licenses/by-nc-sa/3.0/).

— J.D. Hollis, 10 September 02011


## Standing up a Renewzle development environment

* Necessary gem dependencies are set in config/environment.rb. We've included a few unpacked gems in vendor/gems. Run 'rake gems:install' to get the rest (in case you don't already have them).
* Set up your databases along with your own config/database.yml.
* Run 'rake log:create' and 'rake tmp:create' (just in case your working copy doesn't already have them).
* Run 'rake db:migrate' to get the latest version of the schema.
* cd into vendor/data and run 'bunzip2 solar_ratings.sql.bz2'
* Then run 'mysql -u [insert your preferred user here] -p [insert renewzle development database here] < solar_ratings.sql' (this is much faster than using 'rake data:load:latilt')
* cd back into the application root ('cd ../..') and run 'rake data:load:all'
* Finally, run 'rake data:load:cec_companies'

You should be all set now.