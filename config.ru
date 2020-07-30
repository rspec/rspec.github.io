require "rack"
require "middleman/rack"
require "rack/contrib/try_static"

use Rack::Head
use Rack::TryStatic, root: "build", urls: %w[/], try: ['.html', 'index.html', '/index.html']
run -> env do
  [404, { "Content-Type"  => "text/html", "Cache-Control" => "public, max-age=60" }, File.open("build/404/index.html", File::RDONLY)]
end
