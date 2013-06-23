#!/bin/bash

. lib/functions.sh

for file in sources/*; do
  . $file
done

. $1
