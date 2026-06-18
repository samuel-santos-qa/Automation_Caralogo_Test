require 'rspec'
require 'httparty'
require 'yaml'
require 'json'
require 'pry'

require_relative '../../services/caralogo_service'

# Carrega a massa padrão uma vez para todos os cenários Cucumber.
data_path = File.expand_path('../../config/default_data.yaml', __dir__)
MASSA = YAML.load_file(data_path)
