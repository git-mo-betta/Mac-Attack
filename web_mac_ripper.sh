#!/bin/bash

MAC_INPUT=$(cat)

original_mac_list=/home/josec/projects/scripts/maclist2.txt

#mac_addr_regex='\s*[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}|([0-9A-Fa-f]{2}\-){5}[0-9A-Fa-f]{2}|([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\s*' #use with grep -E it will capture most mac addresses with or without whitespace in front or behind. 
mac_addr_regex='[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}|[0-9A-Fa-f]{2}(?:-[0-9A-Fa-f]{2}){5}|[0-9A-Fa-f]{2}(?::[0-9A-Fa-f]{2}){5}'



#First step is to grab the list of Macs from the webpage input and place it into an array, REGARDLESS OF MAC FORMAT. 
if [ -n "$MAC_INPUT" ]; then  #if the string is not empty 
  mapfile -t mac_array < <(grep -Po "$mac_addr_regex" <<< "$MAC_INPUT") #Take the variable MAC_INPUT as stdin, run thru the regex and place in array
else
   echo "everything failed! go home!"
   #mapfile -t mac_array < <(grep -Po "$mac_addr_regex" "$original_mac_list") #if not take your stdin from the file???
fi 
#done < "$original_mac_list"
#echo ${matches[@]}
#echo ${mac_array[@]}
#echo "Is this working"




#this step, we rip away the delimiter, making all macs just 12 digits with nothing inbetween from xxxx.xxxx.xxxx to xxxxxxxxxxxx, then we add the proper delimiter :'s
new_array=() #example for two: 00:d0:2b:c7:e9:cc 00:30:b6:67:2a:00
for x in ${mac_array[@]}; do
  no_delim=$(echo "$x" | tr -d '.:-') 
  #new_array+=($no_delim) This is just here to test the output at this point. As an example, 00d02bc7e9cc 0030b6672a00 00d0ffe8c40a etc.
  format=$(echo "$no_delim" | sed 's/\(..\)/\1:/g; s/:$//') #sed logic explained below
  new_array+=($format)
done
#echo ${new_array[@]}

#\(..\) = two chars 
#/ --just a delim
#\1: replaces those two characters with themselves followed by a colon.
#/
#g this is like a gsub, and it makes the earlier commands repeat globally. Without it, 00:d02bc7e9cc instead of 00:00:00:00:00:00
#s/:$// this is to trim the colon a the end of the line. substitute colon with nothing if at end of line in english. 

#echo ${new_array[@]}


manufacturer=()  # example for two: "JETCELL, INC." "Cisco Systems, Inc"
for y in ${new_array[@]}; do
  results=$(curl -s https://api.maclookup.app/v2/macs/$y?apiKey=01k7nkx8fy86g8aybnv8wd6qz101k7nm1hfcghrgpa87be7cn13bqwt12bs8p1nb | jq '.company') 
  echo "Mac address is $y and the manufacturer is $results"
  #manufacturer+=($results)
done





#echo ${manufacturer[3]}


#final_product=()
#for a in ${mac_array[@]}; do 
#  for b in ${manufacturer[@]}; do
#    echo "Mac address is $a and the manufacturer is $b"
#  done
#done

#echo "MAC ${new_array[2]} belongs to ${manufacturer[1]}"

















#echo "${mac_array[5]}" print the 5th of the array (really six since array starts at 0)
#echo "${mac_array[@]}" print entire mac array 
#echo "${mac_array[@]}" | xargs -n1 print each mac in the array one line at a time
#Now you just need to feed this into an OUI API and output the information nicely
#Perhaps add a mac address option 
#https://api.maclookup.app/v2/macs/00:00:00:00:00:00?apiKey=01k7nkx8fy86g8aybnv8wd6qz101k7nm1hfcghrgpa87be7cn13bqwt12bs8p1nb
#MY Key: 01k7nkx8fy86g8aybnv8wd6qz101k7nm1hfcghrgpa87be7cn13bqwt12bs8p1nb
