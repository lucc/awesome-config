#!/bin/bash

khal
read -N 1
if [[ $REPLY == i || $REPLY == I ]]; then
  clear
  echo
  echo Starting ikhal ...
  exec ikhal
fi
