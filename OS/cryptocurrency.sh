#!/usr/bin/env bash

unset base
unset exchangeTo
old="true"
configuredClient="curl"

#tool for request
httpGet()
{
	curl -A curl -s "$@"

}

## Top 10 cryptocurrencies as base
checkValidCurrency()
{
  if [[ $1 != "BTC" && $1 != "ETH" \
      && $1 != "XRP" && $1 != "LTC" && $1 != "XEM" \
      && $1 != "ETC" && $1 != "DASH" && $1 != "MIOTA" \
      && $1 != "XMR" && $1 != "STRAT" && $1 != "BCH" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

checkTargetCurrency()
{
  if [[ $1 != "AUD" && $1 != "BRL" \
      && $1 != "CAD" && $1 != "CHF" && $1 != "CNY" \
      && $1 != "EUR" && $1 != "GBP" && $1 != "HKD" \
      && $1 != "IDR" && $1 != "INR" && $1 != "JPY" && $1 != "KRW" \
      && $1 != "MXN" && $1 != "RUB" && $1 != "USD" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

## Grabs the base currency from the user and validates it with all the possible currency
## types available on the API and guides user through input (doesnt take in arguments)
getBase()
{
  echo -n "What is the base currency: "
  read -r base
  base=$(echo $base | tr /a-z/ /A-Z/)
  if [[ $(checkValidCurrency $base) == "1"  ]]; then
    unset base
    echo "Invalid base currency"
    getBase
  fi
}


# Matches the symbol to the appropriate ids regarding the API calling.
transformBase()
{
  case "$base" in
    "ETH") reqId="ethereum" ;;
    "BTC") reqId="bitcoin" ;;
    "XRP") reqId="ripple" ;;
    "LTC") reqId="litecoin" ;;
    "XEM") reqId="nem" ;;
    "ETC") reqId="ethereum-classic" ;;
    "DASH") reqId="dash" ;;
    "MIOTA") reqId="iota" ;;
    "XMR") reqId="monero" ;;
    "STRAT") reqId="stratis" ;;
    "BCH") reqId="bitcoin-cash" ;;
  esac
}

## Grabs the exchange to currency from the user and validates it with all the possible currency
## types available on the API and guides user through input (doesnt take in arguments)
getExchangeTo()
{
  echo -n "What currency to exchange to: "
  read -r exchangeTo
  exchangeTo=$(echo $exchangeTo | tr /a-z/ /A-Z/)
  if [[ $(checkTargetCurrency $exchangeTo) == "1" ]]; then
    echo "Invalid exchange currency"
    unset exchangeTo
    getExchangeTo
  fi
}


## Get the amount that will be exchanged and validate that the user has entered a number (decimals are allowed)
## doesnt take in argument, it guides user through input
getAmount()
{
  echo -n "What is the amount being exchanged: "
  read -r amount
  if [[ ! "$amount" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "The amount has to be a number"
    unset amount
    getAmount
  fi
}


checkInternet()
{
  httpGet github.com > /dev/null 2>&1 || { echo "Error: no active internet connection" >&2; return 1; } # query github with a get request
}

## Grabs the exchange rate and does the math for converting the currency
convertCurrency()
{
  exchangeTo=$(echo "$exchangeTo" | tr '[:upper:]' '[:lower:]')
  exchangeRate=$(httpGet "https://api.coinmarketcap.com/v1/ticker/$reqId/?convert=$exchangeTo" | grep -Eo "\"price_$exchangeTo\": \"[0-9 .]*" | sed s/"\"price_$exchangeTo\": \""//g) > /dev/null
  if ! command -v bc &>/dev/null; then
    oldRate=$exchangeRate
    exchangeRate=$(echo $exchangeRate | grep -Eo "^[0-9]*" )
    amount=$(echo $amount | grep -Eo "^[0-9]*" )
    exchangeAmount=$(( $exchangeRate * $amount ))
    exchangeRate=$oldRate
  else
    exchangeAmount=$( echo "$exchangeRate * $amount" | bc )
  fi
  exchangeTo=$(echo "$exchangeTo" | tr '[:lower:]' '[:upper:]')

  cat <<EOF
=========================
| $base to $exchangeTo
| Rate: $exchangeRate
| $base: $amount
| $exchangeTo: $exchangeAmount
=========================
EOF
}

#graph
graph(){
	checkInternet || exit 1
	echo ${base,,}
	link="rate.sx/${base,,}/${exchangeTo,,}"
	httpGet $link
}

# Continue or not
cont()
{
	read -p 'Want to check anything else(Y/N)?' ans
	if [[ $ans == 'Y' ]]; then
		unset base
		unset exchangeTo
		start
	fi
}

# main function
start()
{
	getBase # get base currency
	getExchangeTo # get exchange to currency
	getAmount # get the amount to be converted
	transformBase
	convertCurrency # grab the exhange rate and perform the conversion
	graph #graph
	cont #Continue or not
}

start



read -p 'Do you want to see all the exchange rates(Y/N) ?' result
if [[ $result == 'Y' ]]; then
	checkInternet || exit 1
	link="rate.sx"
	httpGet $link
fi


