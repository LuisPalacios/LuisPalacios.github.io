source "https://rubygems.org"
# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#

# Dependency versions
# https://pages.github.com/versions/

# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
# Comentada para que funcione con GitHub pages
# Source: https://docs.github.com/es/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll
#gem "jekyll", "~> 4.2.0"
#gem "jekyll", github: "jekyll/jekyll", ref: "refs/pull/9248/head"

# This is the default theme for new Jekyll sites. You may change this to anything you like.
#
# Estudiar lo siguiente si quieres hacer un cambio de tema. No es sencillo...
# https://jekyllrb.com/docs/themes/#overriding-theme-defaults
gem "minima", "~> 2.5.1"
#gem "minima", "~> 2.5"
#gem "jekyll-theme-cayman", "~> 0.1.1"

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins
#gem "github-pages", "~> 214", group: :jekyll_plugins
gem "github-pages", "~> 231", group: :jekyll_plugins

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17.0"
end
#group :jekyll_plugins do
#  gem "un-plugin"
#  gem "otro-plugin"
#end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

gem "webrick", "~> 1.7"

# Necesito el racc para que no de error
gem "racc", "~> 1.7.3"
