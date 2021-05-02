#!/bin/zsh
#
# Script to convert jpeg images as per these recommendations: 
# https://developers.google.com/speed/docs/insights/OptimizeImages?hl=es
#
convert ${1}.jpg -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB ${1}_converted.jpg
