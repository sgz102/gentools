#!/bin/bash

whoiam=$(whoami)

mymachine=$(uname -n)
printf "\n"
printf "user machine \n $whoiam $mymachine\n" | column -t
printf "\n"




