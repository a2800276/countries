
#
# takes copy and pasted (manually) table from wikipedia:
# http://en.wikipedia.org/wiki/ISO_3166-1
#
# and cleans it into csv.
#

OUTPUT = "clean/3166.csv"

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

  File.open(ARGV[0]) {|f|
    require 'csv'
    CSV.open(OUTPUT, "w") {|csv| 
      f.each_line {|line|
        arr = line.split("\t")
        if arr.length != 5
          STDERR.puts "DANGER: #{line}"
          exit 1
        end
        csv << arr[0,arr.length-1]
      }
    }
  }
end


