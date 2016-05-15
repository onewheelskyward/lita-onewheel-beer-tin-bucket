require 'lita'

Lita.load_locales Dir[File.expand_path(
  File.join('..', '..', 'locales', '*.yml'), __FILE__
)]

require 'lita/handlers/onewheel_beer_tin_bucket'

Lita::Handlers::OnewheelBeerTinBucket.template_root File.expand_path(
  File.join('..', '..', 'templates'),
 __FILE__
)
