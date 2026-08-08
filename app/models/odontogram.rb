module Odontogram
  NOTATION = "fdi"
  CONFIG_PATH = Rails.root.join("config/odontogram.yml")

  FDI_TEETH = (
    (11..18).to_a + (21..28).to_a + (31..38).to_a + (41..48).to_a
  ).freeze

  # Старые коды из прежних версий config/odontogram.yml
  TYPE_ALIASES = {
    "inlay_onlay" => "inlay",
    "pontic" => "bridge",
    "omit_in_bridge" => "bridge",
    "implant_crown" => "crown",
    "temporary" => "crown",
    "adjacent" => "healthy"
  }.freeze

  module_function

  def config
    @config ||= load_config
  end

  def reload_config!
    @config = load_config
  end

  def types
    config.fetch("types")
  end

  def materials
    config.fetch("materials")
  end

  def shades
    config.fetch("shades")
  end

  def known_codes
    types.map { |t| t["code"] }
  end

  def known_material_codes
    materials.map { |m| m["code"] }
  end

  def known_shade_codes
    shades.map { |s| s["code"] }
  end

  def type_options
    types.map { |t| [ t["name"], t["code"] ] }
  end

  def material_options
    materials.map { |m| [ m["name"], m["code"] ] }
  end

  def shade_options
    shades.map { |s| [ s["name"], s["code"] ] }
  end

  def label_for(code)
    types.find { |t| t["code"] == code.to_s }&.dig("name") || code.to_s
  end

  def material_label_for(code)
    return "" if code.blank?

    materials.find { |m| m["code"] == code.to_s }&.dig("name") || code.to_s
  end

  def shade_label_for(code)
    return "" if code.blank?

    shades.find { |s| s["code"] == code.to_s }&.dig("name") || code.to_s
  end

  def color_for(code)
    types.find { |t| t["code"] == code.to_s }&.dig("color") || "#94A3B8"
  end

  def colors_map
    base = types.each_with_object({}) { |t, h| h[t["code"]] = t["color"] }
    TYPE_ALIASES.each { |legacy, current| base[legacy] = base[current] if base[current] }
    base
  end

  def labels_map
    base = types.each_with_object({}) { |t, h| h[t["code"]] = t["name"] }
    TYPE_ALIASES.each { |legacy, current| base[legacy] = base[current] if base[current] }
    base
  end

  def material_labels_map
    materials.each_with_object({}) { |m, h| h[m["code"]] = m["name"] }
  end

  def empty
    { "notation" => NOTATION, "shade" => nil, "teeth" => [], "connectors" => [] }
  end

  def normalize(raw)
    data = raw.is_a?(String) ? (JSON.parse(raw) rescue {}) : (raw || {})
    data = data.deep_stringify_keys
    shade = data["shade"].presence
    shade = nil if shade && !known_shade_codes.include?(shade)
    {
      "notation" => NOTATION,
      "shade" => shade,
      "teeth" => Array(data["teeth"]).map { |t| normalize_tooth(t) }.compact,
      "connectors" => Array(data["connectors"]).map { |pair| normalize_connector(pair) }.compact
    }
  end

  def normalize_tooth(tooth)
    t = tooth.deep_stringify_keys
    n = t["n"].to_i
    return nil unless FDI_TEETH.include?(n)

    type = t["type"].presence
    type = TYPE_ALIASES[type] || type if type
    return nil if type && !known_codes.include?(type)

    material = t["material"].presence
    material = nil if material && !known_material_codes.include?(material)

    {
      "n" => n,
      "type" => type, # null = зуб выбран, параметры ещё не заданы
      "material" => material,
      "shade" => nil # цвет общий на наряд (formula["shade"]), не на зуб
    }
  end

  def normalize_connector(pair)
    a, b = Array(pair).map(&:to_i)
    return nil unless FDI_TEETH.include?(a) && FDI_TEETH.include?(b) && a != b

    [ a, b ].sort
  end

  def valid?(raw)
    data = normalize(raw)
    codes = known_codes
    materials = known_material_codes
    shades = known_shade_codes
    (data["shade"].nil? || shades.include?(data["shade"])) &&
      data["teeth"].all? do |t|
        FDI_TEETH.include?(t["n"]) &&
          (t["type"].nil? || codes.include?(t["type"])) &&
          (t["material"].nil? || materials.include?(t["material"]))
      end && data["connectors"].all? { |a, b| FDI_TEETH.include?(a) && FDI_TEETH.include?(b) }
  end

  def load_config
    raw = YAML.safe_load_file(CONFIG_PATH, aliases: true)
    raise "odontogram.yml: missing types" unless raw.is_a?(Hash) && raw["types"].is_a?(Array)
    raise "odontogram.yml: missing materials" unless raw["materials"].is_a?(Array)
    raise "odontogram.yml: missing shades" unless raw["shades"].is_a?(Array)

    raw["types"] = raw["types"].map do |entry|
      entry = entry.stringify_keys
      raise "odontogram.yml: type needs code/name/color" unless entry["code"] && entry["name"] && entry["color"]

      {
        "code" => entry["code"].to_s,
        "name" => entry["name"].to_s,
        "color" => entry["color"].to_s
      }
    end

    raw["materials"] = raw["materials"].map do |entry|
      entry = entry.stringify_keys
      raise "odontogram.yml: material needs code/name" unless entry["code"] && entry["name"]

      {
        "code" => entry["code"].to_s,
        "name" => entry["name"].to_s
      }
    end

    raw["shades"] = raw["shades"].map do |entry|
      entry = entry.stringify_keys
      raise "odontogram.yml: shade needs code/name" unless entry["code"] && entry["name"]

      {
        "code" => entry["code"].to_s,
        "name" => entry["name"].to_s
      }
    end

    raw
  end
  private_class_method :load_config
end
