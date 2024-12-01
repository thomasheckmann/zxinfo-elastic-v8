# zxinfo-elastic-v8
Runtime for Elasticsearch v8 for running ZXInfo

## Starting Elasticsearch

Prereq: The elastic-dump utility requires `node v16.15.0`
```
nvm install v16.15.0
nvm use v16.15.0
```

````
docker-compose up -d

# or if on newer vesion on docker
docker compose up -d
````

## import from scratch
````
cd import

# install 'elasticdump'
npm install

Get a copy of latest export files - or simply unzip the file 'import_files.zip'

./import_zxinfo.sh
./import_magazines.sh


curl http://localhost:9200/zxinfo_games/_doc/0002259 | jq
curl http://localhost:9200/zxinfo_magazines/_doc/0000051 | jq
````


## Elasticsearch cleanup
It is important to cleanup indices in Elasticsearch, as new ones are create with every update.

```
curl -GET 'http://localhost:9200/_cat/aliases'

zxinfo_games           zxinfo-20241128-102124           - - - -
zxinfo_games_write     zxinfo-20241128-102124           - - - -
zxinfo_magazines       zxinfo_magazines-20241128-103131 - - - -
zxinfo_magazines_write zxinfo_magazines-20241128-103131 - - - -

# NOTE the zxinfo_games and zxinfo_magazines alias - this should NOT be deleted
The zxinfo_games alias points to the current in use index, in this case it's 'zxinfo-20241128-102124' - check which of the others can be deletes.

curl -GET 'http://localhost:9200/_cat/indices'
curl -XDELETE http://localhost:9200/zxinfo-20220830-131257
```

## TIPS & TRICKS
Remove file wrongly commited (e.g. large file)

```
git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch import/zxinfo_games.analyzers.txt" HEAD
```