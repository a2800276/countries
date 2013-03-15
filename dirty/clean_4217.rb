
require "./config.rb"

#
# takes currency data from maintenance agency:
# http://www.currency-iso.org/en/home/tables/table-a1.html
#
# and cleans it into csv.
#

OUTPUT = OUTPUT_4217

USAGE =<<END
  [ruby] #{$0} <input file>
    output file: #{OUTPUT}
END




def usage
  STDERR.puts USAGE
  exit 1
end

if $0 == __FILE__ 
  if ARGV.length != 1
    usage
  end
  require "rexml/document"
  file = File.new(ARGV[0])
  doc = REXML::Document.new file

  require "csv"
  CSV.open(OUTPUT, "w") {|csv|
    csv << %w{ENTITY CURRENCY ALPHABETIC_CODE NUMERIC_CODE MINOR_UNIT}
    doc.elements.each("ISO_CCY_CODES/ISO_CURRENCY") {|el|
      arr = []
      el.elements.each {|e2|
        arr.push e2.text
      }
      csv << arr
    }
  }
end
