
# generate sql from the processed files.

require "./config.rb"
require "./generate_base.rb"


OUTPUT    = "../countries.csv"

USAGE =<<END
  [ruby] #{$0}
    output file: #{OUTPUT}
END

def usage
  STDERR.puts USAGE
  exit 1
end




def generate_output countries, currencies
  CSV.open(OUTPUT, "w") { |csv|
    csv << %w{ALPHA2 ALPHA3 NUMERIC NAME CURR_CODE CURR_NUM CURR_NAME CURR_MINOR}
    countries.keys.sort.each {|key|
      csv << countries[key].to_csv_arr(currencies)
    }
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

