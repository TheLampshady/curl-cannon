#brew install jq

if [ -z "$1" ] 
then
    echo "No site provided."
    exit 1
fi

if [ -a "$1" ] 
then
  echo "Please Create File, 'post.json'."
  exit 2
fi

#Get Cookies
#curl $1 -o /dev/null -c cookies.txt -s
prefix="value="

TOKEN_LINE="$(curl $1 | grep -F "xsrf")"
TOKEN_PARAM="$(echo $TOKEN_LINE | grep -o 'value=[^ >]\+' | sed s/\"//g)"
JSON_TOKEN="$(echo $TOKEN_LINE | grep -o 'value=[^ >]\+' | sed "s/value=/\"value\":/g")"
TOKEN=${TOKEN_PARAM#$prefix}

echo "Token: ${TOKEN_LINE}"

PARAMS="xsrf="$TOKEN
while IFS='' read -r line || [[ -n $line ]]; do
  PARAMS="${line}&${PARAMS}"
done < "params.txt"
#JSON="$(echo $TOKEN_LINE | grep -o 'value=[^ >]\+' | sed "s/value=/\"value\":/g")"

#cp post.json temp.json
#sed -i '$s/}/,\n${JSON}/' temp.json
JSON="$(jq -c ".xsrf=\"${TOKEN}\"" post.json)"

#-s for silent
# -X for setting Type of Request. Need -d to actually post
# -H sets header
# -d sets as POST. @ preface for filename
#curl -s -X POST -H "Accept: application/json" -d @temp.json $1
curl -s -X POST -H "Accept: application/json" -d $PARAMS $1
