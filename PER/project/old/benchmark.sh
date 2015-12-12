#!/usr/bin/sh
alias time='/usr/bin/time'
times=()
#lengths=(1 5 10 20 50 100)
lenghts=(1)

for ((j=0;j<=5;j++)) 
do
    timetotal=0
    for ((i=1;i<=10;i++))
    do
        timevar=` (time -f "%e" perl main.pl pax6_motif.txt -s ${lengths[$j]} > /dev/null) 2>&1 `
        timetotal=`echo  $timetotal + $timevar | bc`
    done
    timevar=`echo  $timetotal/10.0 | bc`
    times=(${times[@]} $timevar)
done

echo -e "Length of S\tTime taken" > benchmark_times.txt
for ((j=0;j<=5;j++)) 
do
    #echo -e "${lengths[$j]}\t${times[$j]}" >> benchmark_times.txt
    printf "%f\t%f\n" ${lengths[$j]} ${times[$j]} >> benchmark_times.txt
done
