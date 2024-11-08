sum=0
for i in `ps -Alo vsz`
do
        test=`echo "$i" | egrep "^[0-9]+$"`
        if [ "$test" ];  then
                sum=`expr $sum + $i`
        fi
done
 
# Multiply by 4K
sum=`expr $sum \* 4096`
 
sum=`expr $sum / 1024`
 
sum=`expr $sum / 1024`
 avail=`vmstat | grep -i System | cut -f 3 -d '=' | cut -f 1 -d 'M'`
 
echo "Physical Memory Configured: $avail MB"
echo "Memory Used: $sum MB"