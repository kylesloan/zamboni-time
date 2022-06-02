Get the rink id from web inspector on the actual pages aka: https://anc.apm.activecommunities.com/starcenters/daycare/program/193?onlineSiteId=0&from_original_cui=true&online=true shows that Plano has an ID of 193

Launch docker image with
```
./docker.sh
```

Gather rink info and generate html with
```
scrape-info.sh sticknpuck
scrape-info.sh dropin
```

Run tests inside docker
```
goss v
```
