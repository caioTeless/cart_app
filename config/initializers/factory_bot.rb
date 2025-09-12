if Rails.env.development? || Rails.env.test?
  FactoryBot.definition_file_paths << Rails.root.join('lib', 'factories')
  FactoryBot.find_definitions
end