#!/usr/bin/env bash

years=$( echo "scale=3; $2 / 31557600.0" | bc )

: <<'note'
I had to use printf in here because it wasn't rounding correctly... because bc doesn't round. All it does is TRUNCATE so if you want actual rounding you have to use the bc echo as the parameter for the printf. In this case, the %f means float #, and the .2 between means I want 2 decimals. I made the scale 3 for bc so printf could actually round the number properly when the result is passed to it.
note

case "$1" in
    Mercury) printf "%.2f\n" $(echo "scale=3; $years / 0.2408467" | bc)
    ;;
    Venus) printf "%.2f\n" $(echo "scale=3; $years / 0.61519726" | bc)
    ;;
    Earth) printf "%.2f\n" $(echo "scale=3; $years" | bc)
    ;;
    Mars) printf "%.2f\n" $(echo "scale=3; $years / 1.8808158" | bc)
    ;;
    Jupiter) printf "%.2f\n" $(echo "scale=3; $years / 11.862615" | bc)
    ;;
    Saturn) printf "%.2f\n" $(echo "scale=3; $years / 29.447498" | bc)
    ;;
    Uranus) printf "%.2f\n" $(echo "scale=3; $years / 84.016846" | bc)
    ;;
    Neptune) printf "%.2f\n" $(echo "scale=3; $years / 164.79132" | bc)
    ;;
    *) echo "not a planet"; exit 1
    ;;
esac

