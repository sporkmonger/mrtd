# -*- encoding: utf-8 -*-
# stub: mrtd 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mrtd"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bob Aman"]
  s.date = "2014-08-06"
  s.description = "MRTD is a toolbox for working with the machine-readable zones in passport and ID documents. A separate OCR tool is typically required to process an image into text which the MRTD library then attempts to process and extract data from.\n"
  s.email = "bob@sporkmonger.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["CHANGELOG", "Gemfile", "LICENSE", "README.md", "Rakefile", "lib/mrtd", "lib/mrtd.rb", "lib/mrtd/mrz.rb", "lib/mrtd/version.rb", "spec/confidential", "spec/confidential/example.txt", "spec/confidential/mrz_spec.rb", "spec/mrtd", "spec/mrtd/mrz_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/clobber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/metrics.rake", "tasks/spec.rake", "tasks/yard.rake", "website/index.html"]
  s.homepage = "https://github.com/bitpesa/mrtd"
  s.licenses = ["Apache License 2.0"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.2.2"
  s.summary = "Package Summary"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0.7.3"])
      s.add_development_dependency(%q<rspec>, [">= 2.9.0"])
      s.add_development_dependency(%q<launchy>, [">= 0.3.2"])
    else
      s.add_dependency(%q<rake>, [">= 0.7.3"])
      s.add_dependency(%q<rspec>, [">= 2.9.0"])
      s.add_dependency(%q<launchy>, [">= 0.3.2"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.7.3"])
    s.add_dependency(%q<rspec>, [">= 2.9.0"])
    s.add_dependency(%q<launchy>, [">= 0.3.2"])
  end
end
