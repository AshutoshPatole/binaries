#!/bin/bash

# This script will clear the cached memory from the system
# To clear cache memory we have to run the script as root .

if [ "$(whoami)" != "root" ]
then
  echo "You have to run this script as Superuser!"
  exit 1
fi

# Get Free and Cached Memory Information
freemem_before=$(cat /proc/meminfo | grep MemFree | tr -s ' ' | cut -d ' ' -f2) && freemem_before=$(echo "$freemem_before/1024.0" | bc)
cachedmem_before=$(cat /proc/meminfo | grep "^Cached" | tr -s ' ' | cut -d ' ' -f2) && cachedmem_before=$(echo "$cachedmem_before/1024.0" | bc)

echo -e "This script will clear cached memory and free up your ram.\n\nAt the moment you have $cachedmem_before MiB cached and $freemem_before MiB free memory."

# Test sync i.e If the return value of the previous command(Memory information) is != 0 then it means that
# our file system is synced and the cached memory can be deleted .
if [ "$?" != "0" ]
then
  echo "Something went wrong, It's impossible to sync the filesystem."
  exit 1
fi

# Clear Filesystem Buffer using "sync" and Clear Caches.
sync && echo 3 > /proc/sys/vm/drop_caches
rm -rfv ~/.cache/thumbnails

freemem_after=$(cat /proc/meminfo | grep MemFree | tr -s ' ' | cut -d ' ' -f2) && freemem_after=$(echo "$freemem_after/1024.0" | bc)

echo -e "This freed $(echo "$freemem_after - $freemem_before" | bc) MiB, so now you have $freemem_after MiB of free RAM."

exit 0 

