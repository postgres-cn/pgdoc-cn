#!/bin/sh

ADDITIONAL_OPTIONS="-Xms2000m" /usr/bin/fop -fo postgres-A4.fo -pdf postgres-A4.pdf -c fopcfg.xml