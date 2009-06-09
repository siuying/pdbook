Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version= 
  s.name = 'pdbook'
  s.version = '0.1.2'
  s.date = '2009-06-09'
 
  s.description = "Convert PDB (Palm Database) Ebook to PDF format. Specially handle document from haodoo.net."
  s.summary = "Convert PDB (Palm Database) Ebook to PDF format. Specially handle document from haodoo.net."
 
  s.author = "siuying"
  s.email = "siu.ying@gmail.com"

  # = MANIFEST =
  s.files = %w[
    LICENSE
    README
    Rakefile
    bin/pdbook
    lib/pdbook.rb
    lib/pdbook/converter.rb
    pdbook.gemspec
  ]
  # = MANIFEST =
  
  s.extra_rdoc_files = %w[README LICENSE]
  s.add_dependency 'prawn'
  s.add_dependency 'palm'
  s.add_dependency 'chardet'   
  s.has_rdoc = false
  s.executables = ["pdbook"]
  s.require_paths = %w[lib]
  s.rubygems_version = '1.1.1'
  
end