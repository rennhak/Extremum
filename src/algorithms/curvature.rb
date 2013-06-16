#!/usr/bin/env ruby
#

###
#
# (c) 2009-2013, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       curvature.rb
# @author     Bjoern Rennhak
#
#######


# System includes
require 'gsl'
require 'awesome_print'

# Namespaces
include GSL



# @class      Class Curvature
# @brief      The class Curvature takes input data an extracts local maxima on which it can be cut.
class Curvature

  # @fn       def initialize  # {{{
  # @brief    Custom constructor for the Spline class
  def initialize
  end # of def initialize }}}

  # @fn       def clean {{{
  # @brief    Takes input data and cleans it from spaces, tabs and newlines for each line
  #
  #           " 554.2572093389093 -338.6062325459966 -561.6394251506157 \n" =>
  #           "554.2572093389093 -338.6062325459966 -561.6394251506157"
  #
  # @param    [Array]     input       Array containing each line of input data as string
  #
  # @returns  [Array]     Array containing strings without extra newlines, tabs or spaces
  def clean input
    input.collect! do |line|
      line.strip!
    end

    return input
  end # }}}

  # @fn       def extract_columns {{{
  # @brief    Takes input data and returns each column as sub-arrays.
  #           Numbers are translated from string into Numeric.
  #           "Split e.g. x(t),y(t),z(t) into their own arrays
  #
  #           "554.2572093389093 -338.6062325459966 -561.6394251506157"
  #           "714.7077358417557 -286.02874244378114 -386.06759886106306" 
  #
  #           => 
  #
  #           [ [ 554.2572093389093, 714.7077358417557 ], [ -338.6062325459966, -286.02874244378114 ], [ -561.6394251506157, -386.06759886106306 ] ]
  #           which is esseintially: [ column1, column2, column3,...]
  #
  # @param    [Array]     input       Array containing each line of input data as string
  #
  # @returns  [Array]     Array containing subarrays of each individual column
  def extract_columns input
    result = []

    # Split each line and append into subarray of result at right index
    input.each_with_index do |column_value, column_index|
      components = column_value.split( " " )
      components.collect! { |item| item.to_f }

      components.each_with_index do |row_value, row_index|
        result[ row_index ] = Array.new if( result[ row_index ].nil? )
        result[ row_index ] << row_value
      end

    end

    return result
  end # }}}

  # @fn       def extract_rows {{{
  # @brief    Takes input data and returns each row as sub-arrays with elements.
  #           Numbers are translated from string into Numeric.
  #           "Split e.g. "x(t),y(t),z(t)" into their own floats inside the array
  #
  #           "554.2572093389093 -338.6062325459966 -561.6394251506157"
  #           "714.7077358417557 -286.02874244378114 -386.06759886106306" 
  #
  #           => 
  #           [ 554.2572093389093, -338.6062325459966, -561.6394251506157 ],
  #           [ 714.7077358417557, -286.02874244378114, -386.06759886106306 ]
  #
  # @param    [Array]     input       Array containing each line of input data as string
  #
  # @returns  [Array]     Array containing subarrays of each individual row
  def extract_rows input
    result = []

    # Split each line and append into subarray of result at right index
    input.each_with_index do |column_value, column_index|
      components = column_value.split( " " )
      components.collect! { |item| item.to_f }

      result << components
    end

    return result
  end # }}}


end


# Direct Invocation (local testing) # {{{
if __FILE__ == $0

  curvature = Curvature.new

  # Read sample tdata
  data = File.open( "../../data/3d/non_linear/tdata.gpdata", "r" ).readlines
  data = curvature.clean( data )                     # remove \t, \n, etc.
  rows = curvature.extract_rows( data )

  # Print x(t), y(t), z(t)
  # columns = curvature.extract_columns( data )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[0] ) ] )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[1] ) ] )
  # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[2] ) ] )



  # # first var is parameters - discard
  # _, x = spline.bspline_smoothing( parameters, columns[0] )
  # _, y = spline.bspline_smoothing( parameters, columns[1] )
  # _, z = spline.bspline_smoothing( parameters, columns[2] )

  # x = x.to_a
  # y = y.to_a
  # z = z.to_a

  # res = []
  # 0.upto(x.length-1) { |i| res << [ x[i], y[i], z[i] ] }

  # File.open("/tmp/tdata.gpdata", "w" ) do |f|
  #   res.each do |array|
  #     f.write( array.join(", ") + "\n" )
  #   end
  # end

  # # Spline fitting
  # # Ref: http://ruby-gsl.sourceforge.net/spline.html
  # # s = GSL::Spline.alloc( Interp::CSPLINE, data.length )
  # # s.init( parameters, columns[0] )
  # # res = []

  # # parameters.each do |p|
  # #   res << s.eval( p )
  # # end

  # # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( columns[0] ) ] )
  # # GSL::graph( [ GSL::Vector.alloc( parameters ), GSL::Vector.alloc( res ) ] )




end # of if __FILE__ == $0 }}}

# vim:ts=2:tw=100:wm=100
