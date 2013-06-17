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

# Custom
require_relative '../lib/mathematics'


# @class      Class Curvature
# @brief      The class Curvature takes input data an extracts local maxima on which it can be cut.
#
#             The input should be a rather smooth curve otherwise you will end up with alot of false
#             positives for your precision/recall.
class Curvature

  # @fn       def initialize  # {{{
  # @brief    Custom constructor for the Spline class
  def initialize
    @mathematics = Mathematics.new
  end # of def initialize }}}

  # @fn       def clean input {{{
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

  # @fn       def extract_columns input {{{
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

  # @fn       def extract_rows input {{{
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

  # @fn       def angles {{{
  # @brief    Extracts all angles for given equvi-sized triangles on the time series data.
  #           Takes a window size, e.g. 20 points with which the timeseries data
  #           gets split into t(0), t(20), t(40). Using this a angle can be measured on t(20)
  #           as two 3D lines intersect.
  #           http://visual.ipan.sztaki.hu/corner/node7.html
  #
  #           The isosceles triangle described here extracts the angle from time series data.
  #
  # @param    [Array]       data
  # @param    [Numeric]     window        Length of one side of the isosceles triangle expressed in a point window
  #
  # @returns  [Array]       Returns an array with numeric entries for each points angles of the isoscele triangle
  def angles data, window = 10


    #          B t(0+20)
    #         **
    #        *  *
    #       *    *
    #      *      *
    #     C        A t(0)

    length  = data.length - 1
    results = []

    0.upto( length ) do |index|
      a = index
      b = index + window
      c = index + ( 2 * window )

      # The beginning/end points smaller than the required window
      results << nil if( a < window )
      results << nil if( c > length )

      next if( (a < window) or (c > length) )

      results << @mathematics.angle_between_two_lines( data[a], data[b], data[c], data[b] ) 

    end

    results

  end # of def angles }}}

  # @fn       def select_corners data, angles, angle = 125 {{{
  # @brief    Cuts the given data curve when a angle theta is smaller than e.g. 125 deg.
  #
  # @param    [Array]     data      Array containing row wise x,y,z data
  # @param    [Array]     angles    Array containing angles for each point t_n, with nil if angle couldn't be extracted.
  # @aaram    [Numeric]   angle     Angle used as cut criteria, smaller than given angle is a corner
  #
  # @returns  [Array]     Returns array containing data index, x,y,z of proposed cut point
  def select_corners data, angles, angle = 125

    # Remove nil's from angles
    angles.collect! { |i| ( i.nil? ) ? ( 180.0 ) : ( i ) } # 180deg is straight line

    result = []

    angles.each_with_index do |b, i|

      # 85 deg = very sharp
      # 120 deg = normal corner

      #          B t(0+20)
      #         **
      #        *  *
      #       *    *
      #      *      *
      #     C        A t(0)

      a = angles[ i - 1 ]
      c = angles[ i + 1 ]
      next if( a.nil? or c.nil? )

      # make sure given angle is within criteria
      if( b <= angle.to_f )
        # make sure sourrounding angles are larger
        if( (a >= b) and (c >= b) )
          result << [ i, data[ i ] ]
        end
      end

    end # of angles.each_with_index

    result
  end # }}}

  # @fn       def density {{{
  # @brief    The function extracts the epsilon area density at point p_n for the given time series.
  #           This works similarly as a gaussian kernel, but only consideres the time series
  #           component not the entire space.
  def density
  end # of def density }}}

  attr_accessor   :mathematics
end


# Direct Invocation (local testing) # {{{
if __FILE__ == $0

  curvature = Curvature.new

  data      = File.open( "../data/3d/non_linear/result/tdata.gpdata", "r" ).readlines
  data      = curvature.clean( data )                     # remove \t, \n, etc.
  rows      = curvature.extract_rows( data )
  angles    = curvature.angles( rows )
  cuts      = curvature.select_corners( rows, angles )


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
