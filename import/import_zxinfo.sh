#!/bin/bash
ES_HOST=localhost
ES_PORT=9200

GAMES_INDEX=zxinfo_games

MAGAZINES_INDEX=zxinfo_magazines
MAGAZINES_TYPE=zxinfo_magazines

WRITE_INDEX=`date "+zxinfo-%Y%m%d-%H%M%S"`
WRITE_ALIAS="${GAMES_INDEX}_write"

DUMP_CMD="./node_modules/elasticdump/bin/elasticdump";

echo 'Elasticsearch host: ' $ES_HOST
echo 'Elasticsearch port: ' $ES_PORT
echo 'Index/Type        : ' $GAMES_INDEX
echo 'Index             : ' ${WRITE_INDEX}
echo 'Index_alias       : ' ${WRITE_ALIAS}

## ZXINFO
echo '-- create ' $WRITE_INDEX
$DUMP_CMD \
  --input=zxinfo_games.analyzers.txt \
  --output=http://localhost:9200/${WRITE_INDEX} \
  --type=analyzer \
  --headers='{"Content-Type": "application/json"}'

$DUMP_CMD \
  --input=zxinfo_games.mappings.txt \
  --output=http://localhost:9200/${WRITE_INDEX} \
  --type=mapping \
  --headers='{"Content-Type": "application/json"}'

echo '-- remove all alias for ' $WRITE_ALIAS
curl -H'Content-Type: application/json' -XPOST "http://${ES_HOST}:${ES_PORT}/_aliases" -d '
{
    "actions" : [
        { "remove" : { "index" : "*", "alias" : "'$WRITE_ALIAS'" } }
    ]
}'; echo ""

echo '-- create alias ' $WRITE_ALIAS ' for index ' $WRITE_INDEX
curl -H'Content-Type: application/json' -XPOST "http://${ES_HOST}:${ES_PORT}/_aliases" -d '
{
    "actions" : [
        { "add" : { "index" : "'$WRITE_INDEX'", "alias" : "'$WRITE_ALIAS'" } }
    ]
}'; echo ""

echo '-- importing data into ' $WRITE_ALIAS
$DUMP_CMD \
  --input=zxinfo_games.index.txt \
  --output=http://localhost:9200/${WRITE_ALIAS} \
  --type=data \
  --headers='{"Content-Type": "application/json"}'


## wait
read -n1 -r -p "Press space to swith to new index..." key

echo '-- remove all alias for ' ${GAMES_INDEX}
curl -H'Content-Type: application/json' -XPOST "http://${ES_HOST}:${ES_PORT}/_aliases" -d '
{
    "actions" : [
        { "remove" : { "index" : "*", "alias" : "'${GAMES_INDEX}'" } }
    ]
}'; echo ""

echo "Switching to new INDEX ${WRITE_INDEX} for ALIAS ${GAMES_INDEX}"
curl -H'Content-Type: application/json' -XPOST "http://${ES_HOST}:${ES_PORT}/_aliases" -d '
{
    "actions" : [
        { "add" : { "index" : "'$WRITE_INDEX'", "alias" : "'$GAMES_INDEX'" } }
    ]
}'

# curl http://localhost:9200/_cat/indices?v
# curl http://localhost:9200/_cat/aliases?v
# curl http://localhost:9200/zxinfo_games/_doc/0002259
echo ""
echo "test: curl http://localhost:9200/zxinfo_games/_doc/0002259 | jq"
