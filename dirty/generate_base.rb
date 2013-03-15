
class Country 
  attr_accessor :alpha2, :alpha3, :numeric3166, :currency, :name

  def name_sql 
    name.gsub("'", "''")
  end
  def to_insert prefix
    "INSERT INTO #{prefix}countries(alpha2, alpha3, numeric3166, name, currency) "+
    "VALUES ('%s', '%s','%s','%s', '%s');\n" % [alpha2, alpha3, numeric3166, name_sql, currency]
  end

  def to_csv_arr currency_hash
    c = currency_hash[currency] || Currency.new
    [alpha2, alpha3, numeric3166, name, c.alpha3, c.numeric4217, c.name, c.minor]
  end

  def to_json *a
    result = {}
    result[:alpha2]=alpha2
    result[:alpha3]=alpha3
    result[:numeric3166]=numeric3166
    result[:currency]=currency
    result[:name]=name
    result.to_json *a
  end
end

class Currency
  attr_accessor :alpha3, :numeric4217, :name, :minor

  def minor_sql minor
    # pseudo currencies such as gold (XAU) have currency exponent marked
    # as N.A. only have room for one CHAR in DB...
    # probably SHOULD make DB field be NUMERIC and leave as NULL if N.A.
    minor.gsub("N.A.", "-") if minor
  end

  def initialize
    @symbol = ""
  end
  def to_insert prefix
    "INSERT INTO #{prefix}currencies(alpha3, numeric4217, name, symbol, minor) "+
    "VALUES ('%s', '%s','%s','%s');\n" % [alpha3, numeric4217, name, minor_sql]
  end
  def to_json *a
    result = {}
    result[:alpha3]=alpha3
    result[:numeric4217]=numeric4217
    result[:name]=name
    result[:minor]= minor == "N.A." ? nil : minor
    result.to_json *a
  end
end


def read_input
  countries  = {}
  currencies = {}

  require 'csv'

  File.open(INPUT_3166) { |file|
    CSV.new(file, {:headers=>true}).each {|csv|
      c = Country.new
      ccsv = csv.map {|a| a[1]} # urgh. csv file has a header which means each value is ["name", value]
      c.name, c.alpha2, c.alpha3, c.numeric3166 = *ccsv
      countries[c.alpha2] = c
    }
  }

  File.open(INPUT_4217) {|file|
    CSV.new(file, {:headers=>true}).each {|csv|
      c = Currency.new
      ccsv = csv.map {|a| a[1]}
      _, c.name, c.alpha3, c.numeric4217, c.minor = *ccsv
      if c.alpha3 == nil
        next
      end
      currencies[c.alpha3] ||= c
    }
  }

  File.open(INPUT_3166_2_4217) {|file|
     CSV.new(file, {:headers=>true}).each {|csv|
      if c = countries[csv[0]]
        c.currency = csv[1]
        countries[csv[0]] = c
      end
     }
  }
  return countries, currencies
end
