#!/usr/bin/env ruby
#

###
#
# File: Controller.rb
#
######


###
#
# (c) 2013, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Controller.rb
# @author     Bjoern Rennhak
#
#######


# Libraries {{{

# OptionParser related
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'awesome_print'

# Local
require_relative 'lib/logger'

# }}}


# @class      class Controller
# @brief      Central controller class taking care of input argument handling and providing a basic CLI user interface
class Controller

  # @fn       def initialize options = nil # {{{
  # @brief    Constructor of the controller class
  #
  # @param    [OpenStruct]      options     Options OpenStruct processed by the parse_cmd_arguments function
  def initialize options = nil

    @options                      = options

    @log                          = Logger.new( @options )

    # Minimal configuration
    @config                       = OpenStruct.new
    @config.build_dir             = "build"
    @config.encoding              = "UTF-8"
    @config.archive_dir           = "archive"
    @config.config_dir            = "configurations"
    @config.cache_dir             = "cache"

    unless( options.nil? )
      @log.message :success, "Starting #{__FILE__} run"
      @log.message :debug,   "Colorizing output as requested" if( @options.colorize )

      ####
      # Main Control Flow
      ##########



    end # of unless( options.nil? )

  end # of def initialize }}}

  # @fn       def parse_cmd_arguments( args ) # {{{
  # @brief    The function 'parse_cmd_arguments' takes a number of arbitrary commandline arguments and parses
  #           them into a proper data structure via optparse
  #
  # @param    [Array]         args  Ruby's STDIN.ARGS from commandline
  # @returns  [OptionParser]        Ruby optparse package options hash object
  def parse_cmd_arguments( args )

    options                                 = OpenStruct.new

    # Define default options
    options.verbose                         = false
    options.colorize                        = false
    options.filter_window                   = true
    options.filter_point_window_size        = 20
    options.filter_polyomial_order          = 5
    options.filter_runs                     = 1
    
    pristine_options                        = options.dup

    opts                                    = OptionParser.new do |opts|
      opts.banner                           = "Usage: #{__FILE__.to_s} [options]"

      opts.separator ""
      opts.separator "General options:"

      opts.on("-f", "--filter-motion-capture-data OPT OPT2", "Filter the motion capture data against outliers before proceeding with other calculations (smoothing) with a polynomial of the order OPT with point window size OPT2 (e.g. \"5 20\")") do |f|
        data = f.split( " " )
        raise ArgumentError, "Needs at least two arguments provided enclosed by \"\"'s, eg. \"5 20\" for order 5 and 20 points" unless( data.length == 2 )
        options.filter_motion_capture_data                               = true
        data.collect! { |i| i.to_i }
        options.filter_polyomial_order, options.filter_point_window_size = *data
      end

      opts.on( "--filter-iterations OPT" ) do |i|
        options.filter_runs = i.to_i
      end

      opts.on( "--filter-window" ) do |i|
        options.filter_window = i
      end

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-v", "--verbose", "Run verbosely")                                                       { |v| options.verbose     = v           }
      opts.on("-q", "--quiet", "Run quietly, don't output much")                                        { |v| options.quiet       = q           }

      opts.separator ""
      opts.separator "Common options:"

      # Boolean switch.
      opts.on("-c", "--colorize", "Colorizes the output of the script for easier reading") do |c|
        options.colorize = c
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts OptionParser::Version.join('.')
        exi.sortt
      end
    end

    opts.parse!(args)

    # Show opts if we have no cmd arguments
    if( options == pristine_options )
      puts opts
      puts ""
    end

    options
  end # of parse_cmd_arguments }}}

  # @fn       def learn method, code # {{{
  # @brief    Dynamical method creation at run-time
  #
  # @param    [String]   method    Takes the method header definition
  # @param    [String]   code      Takes the body of the method
  def learn method, code
      eval <<-EOS
          class << self
              def #{method}; #{code}; end
          end
      EOS
  end # end of learn( method, code ) }}}

end # of class Controller


# Direct Invocation (local testing) # {{{
if __FILE__ == $0

  options = Controller.new.parse_cmd_arguments( ARGV )
  bc      = Controller.new( options )

end # of if __FILE__ == $0 }}}

# vim:ts=2:tw=100:wm=100
