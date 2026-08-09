require "rqrcode"

module QrCodeHelper
  # Screen: compact. Print: larger modules + quiet zone for reliable camera scan.
  def work_order_qr_svg(work_order, module_size: 5, quiet_modules: 4)
    qr = RQRCode::QRCode.new(work_order_public_url(work_order), level: :m)
    quiet = module_size * quiet_modules
    qr.as_svg(
      offset: quiet,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: module_size,
      standalone: true,
      use_path: false
    ).html_safe
  end
end
