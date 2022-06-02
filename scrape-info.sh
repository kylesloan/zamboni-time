#!/bin/bash
set -e

if [ ! -f "/.dockerenv" ]; then
  echo "Must be run inside container, see ./docker.sh"
  exit 1
fi

BASE_URL="https://anc.apm.activecommunities.com/starcenters/rest/program/__RINKID__/sessions"

TYPE=$1
VALID="false"
for CHECK_TYPE in "sticknpuck" "dropin"
do
  if [ "$CHECK_TYPE" == "$TYPE" ]; then
    VALID="true"
  fi
done

if [ "$VALID" == "false" ]; then
  echo "uknown type passed in, should be sticknpuck or dropin"
  exit 1
fi

mkdir -p "$TYPE"

while read -r MYLINE; do

  RINK_NAME=$( echo "$MYLINE" | awk '{ print $1 }' )
  RINK_ID=$( echo "$MYLINE" | awk '{ print $2 }' )
  URL=${BASE_URL//__RINKID__/$RINK_ID}

  curl -s "$URL" > "$TYPE/${RINK_NAME}.json"
  CURL_CALL=$?
  if [ $CURL_CALL -ne 0 ]; then
    echo "failed to pull $TYPE $RINK_NAME"
    exit 1
  fi

  # see if status code is bad and the site is down
  CODE=$( jq '.headers.response_code' "$TYPE/${RINK_NAME}.json" | tr -d '"' )
  if [ 0000 -ne "$CODE" ]; then
    echo "error pulling $TYPE $RINK_NAME"
    exit 1
  fi



  jq -r '.body.program_sessions[] | [.session_id, .first_date, .beginning_time, .ending_time, .days_of_week] | @tsv' < "$TYPE/${RINK_NAME}.json" | \
  sort -k2 -n | \
  awk -v RINK="${RINK_NAME}" '{ print RINK, $0 }' \
  > "$TYPE/${RINK_NAME}.tsv"

done < "stars-${TYPE}.txt"

# shellcheck disable=SC2002,SC2086
cat $TYPE/*.tsv | awk '{ print $3, $4"-"$5, $6, $1 }' | sort -n -k1,2 | sed 's;Everyday;Unknown;g' > "$TYPE-all.tsv"

awk 'BEGIN {x=0}  { if (x==0) print "<table class=\"searchable sortable zui-table\" id=myTable><thead><tr><th>Date</th><th>Time</th><th>Day</th><th>Rink</th></tr></thead><tbody>"; else print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td></tr>";   x++; }  END { print "</tbody></table>" }' "$TYPE-all.tsv" > "$TYPE-tables.html"

cat html_templates/header.html ${TYPE}-tables.html html_templates/footer.html > "html/${TYPE}.html"
