require "rqrcode"

module QrCodeHelper
  def work_order_qr_svg(work_order, size: 4)
    qr = RQRCode::QRCode.new(work_order_public_url(work_order))
    qr.as_svg(
      offset: 0,
      color: "0f172a",
      shape_rendering: "crispEdges",
      module_size: size,
      standalone: true,
      use_path: true
    ).html_safe
  end
end
