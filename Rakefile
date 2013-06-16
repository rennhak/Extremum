#!/usr/bin/env ruby


# Define Project
@project  = "Extremum"
@version  = (`git describe --tags`).chomp.to_s


# The supported HTTP servers
@stacks   = %w[unicorn rackup]


### General

desc "Show the default task when executing rake without arguments" # {{{
task :default => :help # }}}

desc "Show the available tasks" # {{{
task :help do |t|
  sh "rake -T"
end # }}}

### Actions

desc "Run server with Re-Run (development) - Stack OPTS: #{@stacks.join(", ")}" # {{{
task :rerun, [:stack] do |t, args|

  args.with_defaults( :stack => "rackup" )

  Dir.chdir( "src" ) do

    case args.stack
      when "rackup"
        sh "rerun -p '**/*.{rb,js,css,scss,sass,erb,html,haml,ru,slim}' -- rackup config/config.ru"

      when "unicorn"
        sh "rerun -p '**/*.{rb,js,css,scss,sass,erb,html,haml,ru,slim}' -- unicorn -c config/unicorn.conf.rb config/config.ru"

      else
        puts "Allowed values are only [ #{stacks.join(",")} ]"
    end

  end

end # }}}

desc "Run server (production) - Stack OPTS: #{@stacks.join(", ")}" # {{{
task :run, [:stack] do |t, args|

  args.with_defaults( :stack => "unicorn" )
  stacks  = %w[unicorn rackup]

  Dir.chdir( "src" ) do

    case args.stack
      when "rackup"
        sh "rackup config/config.ru"

      when "unicorn"
        sh "unicorn -c config/unicorn.conf.rb config/config.ru"

      else
        puts "Allowed values are only [ #{stacks.join(",")} ]"
    end

  end

end # }}}

desc "Generate Yardoc documentation for this project" # {{{
task :yardoc do |t|
  `yardoc graph --private --protected -o doc/yardoc *.rb lib/*.rb - README LEGAL COPYING`
end # }}}

desc "Run GetText Chain to generate pot/po files" # {{{
task :gettext => [ :updatepo, :makemo ] # }}}

### Development

desc "Generate proper README file from templates" # {{{}
task :readme do |t|
  sh "m4 m4/README.m4 > README"
end # }}}

desc "Cleans the cache files" # {{{
task :clean do |t|

  if( File.exists?(".sass-cache") )
    sh "rm -rf .sass-cache"
  end

end # }}}

desc "Look for TODO and FIXME tags in the code" # {{{
task :todo do
    egrep /(FIXME|TODO|TBD|FIXME1|FIXME2|FIXME3)/
end # }}}

desc "Run Flog over the code to find the most 'painful' places" # {{{
task :flog do |t|
  files = Dir["**/*.rb"]
  files.collect! { |f| (  f =~ %r{archive|features|spec}i ) ? ( next ) : ( f )  }
  files.compact!
  files.each do |f|
    puts ""
    puts "#######"
    puts "# #{f}"
    puts "################"
    system "flog #{f}"
    puts ""
  end
end # }}}

desc "Run Flay over the code to find the structural similarities" # {{{
task :flay do |t|
  files = Dir["**/*.rb"]
  files.collect! { |f| (  f =~ %r{archive|features|spec}i ) ? ( next ) : ( f )  }
  files.compact!
  files.each do |f|
    puts ""
    puts "#######"
    puts "# #{f}"
    puts "################"
    system "flay #{f}"
    puts ""
  end
end # }}}

desc "Update pot/po files for i10n" # {{{
task :updatepo do
  require 'gettext/tools'

  Dir.chdir( "src" ) do
    files = Dir.glob("{lib,bin,views}/**/*.{rb,rhtml,erb,slim}")
    files.concat( Dir.glob( "*.rb") )
    puts "Files selected are : "
    p files
    GetText.update_pofiles( project.to_s, files, "#{project.to_s} #{version.to_s}")
  end

end # }}}

desc "Make mo files from po files for i10n" # {{{
task :makemo do 

  Dir.chdir( "src" ) do
    require 'gettext/tools'
    GetText.create_mofiles(:mo_root => "locale")
  end

end # }}}

desc "Calculate current MyGengo cost estimation based on po/pot/mo files" # {{{
task :gengo do

  Dir.chdir( "src" ) do 

    # - price in US cents turned into USD
    costs_simple      = 5  / 100.0
    costs_business    = 10 / 100.0
    costs_ultra       = 15 / 100.0

    # gather all required files for counting words
    input = Dir.glob( "views/**" )
    files = []

    translations = [] # collect final words here

    # iterate over each file
    input.each do |filename|

      # get rid of newlines
      contents  = File.open( filename, "r" ).readlines.join( " " ).gsub( "\n", " " )

      # scan for gettext commands
      result    = contents.scan( /_\(["'][A-Za-z0-9 \t,.\(\)-]*["']\)/ )

      # if we have a hit
      unless( result.empty? )
        files << filename
        result.each do |match|
          # get rid of special characters
          tmp = ( match.tr( "\"',.\(\)", "" ) ).gsub( /_|-/, " " ).squeeze.strip

          # append words to final array where we do the eventual counting
          translations.concat( tmp.split( " " ) )
        end
      end # of unless( result.empty? )
    end # of input.each

    # Throw away words we already have
    words   = translations.uniq

    jpy     = []
    eur     = []

    # Calculate costs in MyGengo pricing for eur and jpy
    [ :eur, :jpy ].each do |currency|
      [ costs_simple, costs_business, costs_ultra ].each do |costs|
        eval( "#{currency.to_s} << cost_calculation( #{costs}, :#{currency.to_s}, #{words.length} )" )
      end
    end

    puts "MyGengo Translation price for (Standard, Business, Ultra)"
    puts "Total word count: #{words.length} (unique)"
    puts ""
    puts "JPY:   %5d %5d %5d" % jpy
    puts "EURO:  %5d %5d %5d" % eur
    puts ""

  end

end # }}}


### Helper Functions

# @fn       def egrep(pattern) # {{{
# @brief    Searches for a given regular expression among all ruby files
#
# @param    [Regexp]  pattern     Regular Expression pattern class
def egrep( pattern )

  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|

      while line = f.gets
        count += 1
        STDOUT.puts "#{fn}:#{count}:#{line}" if line =~ pattern
      end

    end # end of open
  end # end of Dir.each

end # }}}

# @fn       def cost_calculation price_in_usd, target_currency, words {{{
# @brief    Calculates based on a hard-coded conversion rate the price for a certain translation
#
# @param    []      price_in_usd
# @param    []      target_currency
# @param    []      words
#
# @returns  Returns the result of the cost in the desired target currency
def cost_calculation price_in_usd, target_currency, words

  # Input verification
  raise ArgumentError, "Can only accept symbols :eur and :jpy" unless( [ :eur, :jpy ].include?( target_currency ) )

  # 1 USD  =   0.763855 EUR  (xe.com, 11.04.2012)
  us_to_eur         = 0.763655

  # 1 USD  =   80.7114 JPY    (xe.com, 11.04.2012)
  us_to_jpy         = 80.7114

  result = nil

  case target_currency
    when :eur
      result = ( price_in_usd * words ) * us_to_eur
    when  :jpy
      result = ( price_in_usd * words ) * us_to_jpy
  end

  # Output verification
  raise ArgumentError, "Result must be of type numeric" unless( result.is_a?( Numeric ) )
  raise ArgumentError, "Result must be positive" unless( result >= 0 )

  result
end # of def cost_calculation }}}

# vim:ts=2:tw=100:wm=100:syntax=ruby
