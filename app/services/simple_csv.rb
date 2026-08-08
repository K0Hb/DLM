# Minimal CSV builder — no dependency on the extracted `csv` default gem (Ruby 3.4+).
# UTF-8 BOM + CRLF + ";" — чтобы кириллица и колонки нормально открывались в Excel (RU/Windows).
module SimpleCsv
  UTF8_BOM = "\uFEFF"
  COL_SEP = ";"

  module_function

  def generate(rows)
    body = rows.map { |row| row.map { |cell| escape(cell) }.join(COL_SEP) }.join("\r\n")
    "#{UTF8_BOM}#{body}\r\n"
  end

  def escape(value)
    text = value.to_s
    if text.include?(COL_SEP) || text.include?('"') || text.include?("\n") || text.include?("\r")
      %("#{text.gsub('"', '""')}")
    else
      text
    end
  end
end
