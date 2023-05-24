#!bin/bash

while true
do
  curl -s "http://rate.am" -o rate.html
  # Set the input file name
  input_file="index.html"

  # Read the input file into a variable
  html_content=$(cat "$input_file")

  selectPattern='<a href="\/am\/bank\/[a-z\-]{1,19}">[Ա-Ֆա-և_ -]{1,30}<\/a>'
  pattern='<td>.*<\/td>'

  # Use grep with the -o option to extract the matched elements and store them in an array
  mapfile -t selectMatches < <(echo "$html_content" | grep -E "$selectPattern")

  mapfile -t matches < <(echo "$html_content" | grep -E "$pattern")

  buy=2
  shell=3
  index=0
  Banks=()
  Buys=()
  Shells=()
  for ((i=0; i<=${#selectMatches[@]}; i++))
  do
    Bank=$( echo ${selectMatches[$i]} | grep -Eo '[Ա-Ֆա-և\ ]{1,20}' )
    if [[ $Bank ]];
    then
      Banks+=("$Bank")
    fi
  done
  for ((i=0; i<=${#matches[@]}; i++))
  do
    if [ $i == $buy ]
    then
      usdBuy=$( echo ${matches[$i]} | grep -Eo '[0-9.]{3,6}' )
      Buys+=("$usdBuy")
      buy=$(($buy+10))
    fi
    if [ $i == $shell ]
    then
      usdShell=$( echo ${matches[$i]} | grep -Eo '[0-9.]{3,6}' )
      Shells+=("$usdShell")
      shell=$(($shell+10))
    fi
  done

  bestBuy=0
  bestShell=0
  bestBuyBank=()
  bestShellBank=()

  for i in $(seq 0 17)
  do
    usdBuy=$(echo ${Buys[$i]} | bc | sed 's/\./,/')
    usdShell=$(echo ${Shells[$i]} | bc | sed 's/\./,/')
    if [[ $i -ne 0 ]];
    then
      if [[ $bestBuy -lt $usdBuy ]];
      then
        bestBuyBank=("${Banks[$i]}")
        bestBuy="$usdBuy"
      elif [[ $bestBuy -eq $usdBuy ]];
      then
        bestBuyBank+=("${Banks[$i]}")
        bestBuy="$usdBuy"
      fi
    fi
    if [[ $i -ne 0 ]];
    then
      if [[ $bestShell -gt $usdShell ]];
      then
        bestShellBank=(${Banks[$i]})
        bestShell="$usdShell"
      elif [[ $usdShell -eq $bestShell ]];
      then
        bestShellBank+=(${Banks[$i]})
        bestShell="$usdShell"
      fi
    fi
    if [[ $i -eq 0 ]];
    then
      bestBuyBank=(${Banks[$i]})
      bestBuy="$usdBuy"
      bestShellBank=(${Banks[$i]})
      bestShell="$usdShell"
    fi
  done
  echo BestBuy $bestBuy
  echo BestBuyBanks ${bestBuyBank[@]}
  echo BestShell $bestShell
  echo BestShellBanks ${bestShellBank[@]}




  # Generate the HTML code
  html="<html>
  <head>
      <meta charset='UTF-8'>
      <title>Exchange Rates</title>
  </head>
  <body>
      <h1>Exchange Rates</h1>
      <table>
      <tr>
          <td>BestBuy:</td>
          <td>$bestBuy</td>
      </tr>
      <tr>
          <td>BestBuy Banks:</td>
          <td>${bestBuyBank[@]}</td>
      </tr>
      <tr>
          <td>BestShell:</td>
          <td>$bestShell</td>
      </tr>
      <tr>
          <td>BestShell Banks:</td>
          <td>${bestShellBank[@]}</td>
      </tr>
      </table>
  </body>
  </html>"

  sleep 30

  # Write the HTML code to a file
  echo "$html" > /var/www/rateInfo/index.html
done
