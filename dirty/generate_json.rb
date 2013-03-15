
# generate sql from the processed files.

require "./config.rb"
require "./generate_base.rb"


OUTPUT    = "../countries.json"

USAGE =<<END
  [ruby] #{$0}
    output file: #{OUTPUT}
END

def usage
  STDERR.puts USAGE
  exit 1
end




def generate_output countries, currencies
  # result should be:
  # {countries: [{},...], currencies: [{},...]}
  result = {}
  result[:countries]  = []
  result[:currencies] = []

  countries.keys.sort.each {|c|
    result[:countries].push countries[c]
  }
  currencies.keys.sort.each {|c|
    result[:currencies].push currencies[c]
  }

  require "json"
  File.open(OUTPUT, "w") {|output|
    output.print(JSON.pretty_generate(result))
  }
  
end

if $0 == __FILE__ 
  if ARGV.length != 0 && ARGV.length != 2
    usage
  end

  
  # check all csv there
  co, cu = read_input
  generate_output co, cu
end

