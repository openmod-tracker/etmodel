require 'rspec'
require 'yaml'

# Define the path to the locales folder
LOCALE_FOLDER = 'config/locales'

# Method to recursively extract all keys from a YAML hash
def extract_keys(hash, parent_key = nil)
  keys = []
  hash.each do |key, value|
    full_key = [parent_key, key].compact.join('.')
    if value.is_a?(Hash)
      keys.concat(extract_keys(value, full_key))
    else
      keys << full_key
    end
  end
  keys
end

# Load all .yml files and organize them by language
def load_locale_files
  locale_files = Dir.glob(File.join(LOCALE_FOLDER, '*.yml'))
  locales = {}
  locale_files.each do |file|
    language = File.basename(file, '.yml').split('_').first # Extract "en" or "nl" from filename
    locales[language] ||= []
    locales[language] << file
  end
  locales
end

# Load all keys from a set of YAML files
# Load all keys from a set of YAML files
def load_all_keys(files)
  keys = []
  files.each do |file|
    yaml_content = YAML.safe_load(File.read(file), aliases: true) # Enable YAML aliases
    root_key = yaml_content.keys.first # Get the top-level language key
    keys.concat(extract_keys(yaml_content[root_key])) if root_key
  end
  keys
end

RSpec.describe 'Locale key consistency' do
  it 'ensures all keys in English are present in Dutch and vice versa across all files' do
    locales = load_locale_files

    english_files = locales['en'] || []
    dutch_files = locales['nl'] || []

    en_keys = load_all_keys(english_files)
    nl_keys = load_all_keys(dutch_files)

    missing_in_nl = en_keys - nl_keys
    missing_in_en = nl_keys - en_keys

    expect(missing_in_nl).to be_empty, "Keys missing in Dutch locale: #{missing_in_nl.join(', ')}"
    expect(missing_in_en).to be_empty, "Keys missing in English locale: #{missing_in_en.join(', ')}"
  end
end