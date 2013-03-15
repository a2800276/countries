require "./config.rb"

# Downloads and processes Common Locale Data Repository (CLDR)
# data from unicode.org.

CLDR_VERSION="22.1"
CLDR_URL="http://unicode.org/Public/cldr/#{CLDR_VERSION}/core.zip"
CLDR_OUTPUT="./cldr/core.#{CLDR_VERSION}.zip"
WORK="work"


USAGE =<<END
  [ruby] #{$0} 
    output dir: #{OUTPUT}
END


def usage
  STDERR.puts USAGE
  exit 1
end

def download_cldr
  return if File.exist? CLDR_OUTPUT
  require "open-uri"
  File.open(CLDR_OUTPUT, "wb") { |file|
    open(CLDR_URL, "rb") { |cldr|
      IO.copy_stream(cldr, file)
    }
  }
end

def unzip_cldr
  usage unless File.exist? CLDR_OUTPUT
  `unzip #{CLDR_OUTPUT} -d work` 
end

CLDR_SUPP="#{WORK}/common/supplemental/supplementalData.xml"

def parse_cldr
  require "rexml/document"
  require "csv"
  # start with alpha2 3166 country to currency
  supp = File.new(CLDR_SUPP)
  doc = REXML::Document.new supp
  CSV.open(OUTPUT_3166_2_4217, "w") { |csv|
    csv << ["3166 alpha2", "4217 aplha2"]
    doc.elements.each("*/currencyData/region") { |el|
      country  = el.attributes["iso3166"]
      currency = nil
      next if country == "150"
      el.elements.each("currency") { |curr|
        if curr.attributes["to"] == nil && curr.attributes["from"] != nil
          csv << [country, curr.attributes["iso4217"]]
        end
      }

    }
  } # csv
  
ensure
  supp.close
end


if $0 == __FILE__ 
  if ARGV.length != 0
    usage
  end

  download_cldr
  unzip_cldr
  parse_cldr
end

