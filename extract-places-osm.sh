#! /bin/sh

OSMOSIS=${HOME}/osmosis-0.43.1
STORAGE=${HOME}/Dropbox/osmdata
TMPDIR=${HOME}/tmp/osm-place-connectivity
WEBDATA=/home/tomcat/osm-mosques/data

COUNTIES=

COUNTRIES=
COUNTRIES="${COUNTRIES} germany"
COUNTRIES="${COUNTRIES} turkey"

extract_data() {

    country=$1
    county=$2
    type=$3

    if [ ${type} == "all" ]
    then
	tag="*"
    else
	tag=${type}
    fi

    ${OSMOSIS}/bin/osmosis \
	--read-pbf file=${FILE} \
	--tag-filter accept-nodes religion=${type} \
	--tag-filter reject-ways \
	--tag-filter reject-relations \
	--write-xml ${TMPDIR}/${country}-${county}-religion-${type}.osm \
	> ${TMPDIR}/${country}-${county}-religion-${type}.stdout.txt \
	2> ${TMPDIR}/${country}-${county}-religion-${type}.stderr.txt

    mkdir -p ${STORAGE}/${country}/${MONTH}/${DAY}

    cp -f \
	${TMPDIR}/${country}-${county}-religion-${type}.osm \
	${STORAGE}/${country}/${MONTH}/${DAY}/${country}-${county}-religion-${type}.osm

    cp -f \
	${TMPDIR}/${country}-${county}-religion-${type}.osm \
	${WEBDATA}/${country}-${county}-religion-${type}.osm
}


for country in ${COUNTRIES}
do

    COUNTIES=

    if [ "germany" == "${country}" ]
    then
	COUNTIES="${COUNTIES} baden-wuerttemberg"
	COUNTIES="${COUNTIES} bayern"
	COUNTIES="${COUNTIES} berlin"
	COUNTIES="${COUNTIES} brandenburg"
	COUNTIES="${COUNTIES} bremen"
	COUNTIES="${COUNTIES} hamburg"
	COUNTIES="${COUNTIES} hessen"
	COUNTIES="${COUNTIES} mecklenburg-vorpommern"
	COUNTIES="${COUNTIES} niedersachsen"
	COUNTIES="${COUNTIES} nordrhein-westfalen"
	COUNTIES="${COUNTIES} rheinland-pfalz"
	COUNTIES="${COUNTIES} saarland"
	COUNTIES="${COUNTIES} sachsen"
	COUNTIES="${COUNTIES} sachsen-anhalt"
	COUNTIES="${COUNTIES} schleswig-holstein"
	COUNTIES="${COUNTIES} thueringen"
    else
	COUNTIES="${COUNTIES} all"
    fi

    for county in ${COUNTIES}
    do
	:
	mkdir -p ${TMPDIR}
	cd ${TMPDIR}

	FILE=${TMPDIR}/${country}-${county}-latest.osm.pbf

	rm -f ${FILE}

	if [ "germany" == "${country}" ]
	then
	    :
	    wget http://download.geofabrik.de/europe/${country}/${county}-latest.osm.pbf -O ${FILE} \
		> ${FILE}.out 2> ${FILE}.err
	else
	    :
	    cp ${TMPDIR}/../osm-place-connectivity/${country}-latest.osm.pbf ${TMPDIR}/${country}-${county}-latest.osm.pbf
	fi

	MONTH=$(date +%Y%m --reference ${FILE})
	DAY=$(date +%Y%m%d --reference ${FILE})

	extract_data ${country} ${county} muslim

	find ${STORAGE}/${country} -type f -a -mtime +14 | xargs --no-run-if-empty
	find ${STORAGE}/${country} -type d -a -empty | xargs --no-run-if-empty rmdir
    done
done

# TODO grep in property file to obtain username / password for webapp
for country in ${COUNTRIES}
do
    :
    # curl \
    # http://localhost:8888/osm-mosques-rest/osm/import \
    # -o ${STORAGE}/${country}-${county}/${MONTH}/${DAY}/curl.data.txt \
    # > ${STORAGE}/${country}-${county}/${MONTH}/${DAY}/curl.out \
    # 2> ${STORAGE}/${country}-${county}/${MONTH}/${DAY}/curl.err
done
