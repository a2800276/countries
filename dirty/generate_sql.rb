
CREATE =<<END

CREATE TABLE XXXcountries (
  alpha2      CHAR(2)      PRIMARY KEY,
  alpha3      CHAR(3)      NOT NULL UNIQUE, 
  numeric3166 CHAR(3)      NOT NULL UNIQUE,
  name        VARCHAR(256) NOT NULL UNIQUE, -- hmmm, english?
  currency    CHAR(2)      FOREIGN KEY REFERENCES XXXcurrencies(alpha2)
);

CREATE TABLE XXXcurrencies (
  alpha2      CHAR(2)      PRIMARY KEY,
  numeric4217 CHAR(3)      NOT NULL UNIQUE,
  name        VARCHAR(256) NOT NULL UNIQUE,
  minor       NUMERIC(1)   NOT NULL,
-- minor_name ... tbd
--  symbol      VARCHAR(10) -- determine
);

-- CREATE TABLE XXXflags {
--  alpha2 CHAR(2), -- fk -> XXXcountries
--  flag   VARCHAR(1024)
-- }

-- country name
-- currency name

END

OUTPUT    = "clean/countries.sql"
INPUT3166 = "clean/3166.csv"
INPUT4217 = "clean/4217.csv"
INPUT316624217 = "clean/3166_2_4217.csv"

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

class Country 
  attr_accessor :alpha2, :alpha3, :numeric3166, :currency
  attr_reader   :name

  def name= name
    @name = name.gsub("'", "''")
  end
  def to_insert prefix
    "INSERT INTO #{prefix}countries(alpha2, alpha3, numeric3166, name, currency) "+
    "VALUES ('%s', '%s','%s','%s', '%s');\n" % [alpha2, alpha3, numeric3166, name, currency]
  end
end

class Currency
  attr_accessor :alpha2, :numeric4217, :name, :minor
  attr_reader :minor

  def minor= minor
    # pseudo currencies such as gold (XAU) have currency exponent marked
    # as N.A. only have room for one CHAR in DB...
    # probably SHOULD make DB field be NUMERIC and leave as NULL if N.A.
    @minor = minor.gsub("N.A.", "-") if minor
  end

  def initialize
    @symbol = ""
  end
  def to_insert prefix
    "INSERT INTO #{prefix}currencies(alpha2,  numeric4217, name, symbol, minor) "+
    "VALUES ('%s', '%s','%s','%s');\n" % [alpha2, numeric4217, name, minor]
  end
end


def read_input
  
  countries  = {}
  currencies = {}

  require 'csv'

  File.open(INPUT3166) { |file|
    CSV.new(file, {:headers=>true}).each {|csv|
      c = Country.new
      ccsv = csv.map {|a| a[1]} # urgh. csv file has a header which means each value is ["name", value]
      c.name, c.alpha2, c.alpha3, c.numeric3166 = *ccsv
      countries[c.alpha2] = c
    }
  }

  File.open(INPUT4217) {|file|
    CSV.new(file, {:headers=>true}).each {|csv|
      c = Currency.new
      ccsv = csv.map {|a| a[1]}
      _, c.name, c.alpha2, c.numeric4217, c.minor = *ccsv
      if c.alpha2 == nil
        next
      end
      currencies[c.alpha2] ||= c
    }
  }

  File.open(INPUT316624217) {|file|
     CSV.new(file, {:headers=>true}).each {|csv|
      if c = countries[csv[0]]
        c.currency = csv[1]
        countries[csv[0]] = c
      end
     }
  }
  return countries, currencies
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

