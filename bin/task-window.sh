#!/bin/bash

{
  khal --color list today today
  task \
    rc._forcecolor=on \
    rc.detection=off \
    rc.defaultheight=100 \
    rc.defaultwidth=120 \
    next \
    2>/dev/null
} | head -n 37

read -N 1
