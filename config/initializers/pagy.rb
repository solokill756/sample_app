require "pagy/extras/bootstrap"
Pagy::DEFAULT[:size] = Settings.dig(:pagy, :size)
Pagy::DEFAULT[:bootstrap] = {
  nav: "pagy-bootstrap-nav",
  nav_js: "pagy-bootstrap-nav-js",
  combo_nav_js: "pagy-bootstrap-combo-nav-js"
}
