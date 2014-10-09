require 'mkmf'
$CFLAGS += " -std=c99"

if have_library('xml2', 'xmlNewDoc')
  # libxml2 libraries from http://www.xmlsoft.org/
  pkg_config('libxml-2.0')

  # nokogiri configuration from gem install
  nokogiri_lib = Gem.find_files('nokogiri').
    sort_by { |name|
      name.match(%r{gems/nokogiri-([\d.]+)/lib/nokogiri}) ? Regexp.last_match[1].split('.').map(&:to_i) : [0, 0, 0]
    }.last
  if nokogiri_lib
    nokogiri_ext = nokogiri_lib.sub(%r(lib/nokogiri(.rb)?$), 'ext/nokogiri')

    # if that doesn't work, try workarounds found in Nokogiri's extconf
    unless find_header('nokogiri.h', nokogiri_ext)
      require "#{nokogiri_ext}/extconf.rb"
    end

    # if found, enable direct calls to Nokogiri (and libxml2)
    $CFLAGS += ' -DNGLIB' if find_header('nokogiri.h', nokogiri_ext)
    
    if File.exists?("/etc/gentoo-release")
      # link to the library to prevent: nokogumbo.c:(.text+0x26a): undefined reference to `Nokogiri_wrap_xml_document'
      $LDFLAGS += " -L#{nokogiri_ext} -l:nokogiri.so"
    end
  end
end

# add in gumbo-parser source from github if not already installed
unless have_library('gumbo', 'gumbo_parse')
  rakehome = ENV['RAKEHOME'] || File.expand_path('../..')
  unless File.exist? "#{rakehome}/ext/nokogumboc/gumbo.h"
    require 'fileutils'
    FileUtils.cp Dir["#{rakehome}/gumbo-parser/src/*"],
      "#{rakehome}/ext/nokogumboc"

    case RbConfig::CONFIG['target_os']
    when 'mingw32', /mswin/
      FileUtils.cp Dir["#{rakehome}/gumbo-parser/visualc/include/*"],
        "#{rakehome}/ext/nokogumboc"
    end

    $srcs = $objs = nil
  end
end

create_makefile('nokogumboc')
