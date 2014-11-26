#!/bin/bash

find $1 -type f | awk -F "\/" '{print $NF}' | awk -F "_" '{print $1 "_" $2 "_" $3}' | sort | uniq