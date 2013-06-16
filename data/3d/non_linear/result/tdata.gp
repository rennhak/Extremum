reset
set ticslevel 0
set mxtics 2
set mytics 2
set grid
set border
set pointsize 1
set xlabel 'X'
set ylabel 'Y'
set zlabel 'Z'
set autoscale
set font 'arial'
set key left box
set nokey
set hidden3d
set output
set terminal x11 persist
set title 'B-Spline Smoothing of T-Data'

# Styles
set palette rgbformulae 22,12,-32
set style line 1 lw 3

# Plot
splot 'tdata.gpdata' using 1:2:3 with points pt 12 ps 1, \
      'tdata.gpdata' using 1:2:3 with lines lw 2 lt 1, \
      'tdata_orig.gpdata' using 1:2:3 with lines lw 2 lt 3
