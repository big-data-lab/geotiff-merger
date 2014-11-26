#!/bin/bash

find $1 -type f | awk -F "\/" '{print $NF}' | awk -F "_" '{print $4 "_" $5 }' | sort | uniq
