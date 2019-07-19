def get_key(line)
  start_index = line.index('"')
  end_index = line.index('>')
  return line[(start_index)..(end_index-1)]
end

def get_value(line)
  start_index = line.index('>')
  end_index = line.rindex('<')
  return '"' + line[(start_index+1)..(end_index-1)] + '"'
end

def write_line(line, dictionary)
  key = get_key line
  value = get_value line
  dictionary[key] = value
end

def parse_file(lines, dictionary)
  multipleRowLine = ""
  for index in 0..(lines.length-1)
    line = lines[index]
    if line.length < 1
      continue
    elsif not line.end_with?("</string>\n")
      multipleRowLine += line
    else
      multipleRowLine += line
      write_line multipleRowLine, dictionary
      multipleRowLine = ""
    end
  end
end

# # ANDROID SRC LOCALIZATION FILES
source_en_file_path = 'Source/strings_ru.xml'
source_ru_file_path = 'Source/strings_ua.xml'
#
# IOS LOCALIZATION FILES
source_localization_file_path = "./../../TokenD-Plus/Resources/ru.lproj/Localizable.strings"
target_file_path = './../../TokenD-Plus/Resources/uk-UA.lproj/Localizable.strings'

source_content_en = File.read(source_en_file_path)
source_content_ru = File.read(source_ru_file_path)

source_content_en.encode!('UTF-8')
source_content_ru.encode!('UTF-8')

source_content_en_lines = source_content_en.lines
source_content_ru_lines = source_content_ru.lines

$dictionary_en = {}
$dictionary_ru = {}
$result_dictionary = {}

for index in 0..(source_content_en_lines.length) do
  parse_file source_content_en_lines, $dictionary_en
end

for index in 0..(source_content_ru_lines.length) do
  parse_file source_content_ru_lines, $dictionary_ru
end


$dictionary_en.each_key { |key|
  ru_value = $dictionary_ru[key]
  if ru_value != nil
    $result_dictionary[$dictionary_en[key]] = ru_value
  end
}

loc_keys_string = "// Localized strings\n\n"

source_localization_content = File.read(source_localization_file_path)
source_localization_content.encode!('UTF-8')
source_localization_content_lines = source_localization_content.lines

source_localization_content_lines.each { |line|
    string_to_write = ""      
    pair = line.split('=')
    next if pair.count < 2
    
    string_to_write += pair[0]
    
    value = pair[1]
    value = value.strip().delete ';'
    translated_value = $result_dictionary[value]
    if translated_value != nil
          string_to_write += "= #{translated_value};\n"
    else
          string_to_write += "=#{pair[1]}"
    end
    loc_keys_string += string_to_write
}

target_file = File.open(target_file_path, 'w')
target_file.write(loc_keys_string)
target_file.close
