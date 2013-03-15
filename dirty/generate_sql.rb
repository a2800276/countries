
# generate sql from the processed files.

require "./config.rb"
require "./generate_base.rb"

CREATE =<<END
DROP TABLE XXXcountries;
CREATE TABLE XXXcountries (
  alpha2      CHAR(2)      PRIMARY KEY,
  alpha3      CHAR(3)      NOT NULL UNIQUE, 
  numeric3166 CHAR(3)      NOT NULL UNIQUE,
  name        VARCHAR(256) NOT NULL UNIQUE, -- hmmm, english?
  currency    CHAR(3)      REFERENCES XXXcurrencies(alpha3)
);

DROP TABLE XXXcurrencies;
CREATE TABLE XXXcurrencies (
  alpha3      CHAR(3)      PRIMARY KEY,
  numeric4217 CHAR(3)      NOT NULL UNIQUE,
  name        VARCHAR(256) NOT NULL UNIQUE,
  minor       NUMERIC(1)   NOT NULL
  -- minor_name ... tbd
  -- symbol      VARCHAR(10) -- determine
);

-- CREATE TABLE XXXflags {
--  alpha2 CHAR(2), -- fk -> XXXcountries
--  flag   VARCHAR(1024)
-- }

-- country name
-- currency name

END

OUTPUT    = "../countries.sql"

USAGE =<<END
  [ruby] #{$0} (-p PREFIX)
    output file: #{OUTPUT}
    if a PREFIX is provided, it is prepended to the names
    of any sql elements.
END

def usage
  STDERR.puts USAGE
  exit 1
end




def generate_output prefix, countries, currencies
  File.open(OUTPUT, "w") { |output|
    output.print CREATE.gsub(/XXX/, prefix)

    output.puts "-- COUNTRIES"
    countries.keys.sort.each {|key|
      output.print countries[key].to_insert prefix 
    }

    output.puts "\n-- CURRENCIES"
    currencies.keys.sort.each {|key|
      output.print currencies[key].to_insert prefix
    }
  }

end
if $0 == __FILE__ 
  if ARGV.length != 0 && ARGV.length != 2
    usage
  end

  prefix = ARGV[0] == "-p" ? ARGV[1] + "_" : "" 
  
  # check all csv there
  co, cu = read_input
  generate_output prefix, co, cu
end

