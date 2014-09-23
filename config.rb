# Bower specific setup
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  @bower_assets_path = File.join "#{root}", @bower_config["directory"]
  sprockets.append_path @bower_assets_path
end

# dev mode addons
activate :livereload

# for build
activate :syntax
activate :directory_indexes

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'

# necessary whilst testing
set :relative_links, true

configure :build do
  activate :minify_css
  activate :minify_javascript
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
end
