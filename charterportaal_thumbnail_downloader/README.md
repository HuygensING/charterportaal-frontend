The script in this folder is used to crawl the pages of the national archives and retrieve the thumbnails of the charters so we have a locally cached version and don't need to hotlink.

Running it on a dir that contains the results of the previous run will cause it to skip downloading files that already exist, without ETAG or changed data checking.

a docker image containing a working version of this script is available on https://hub.docker.com/r/huygensing/charterportaal_thumbnail_downloader that container is created from the Dockerfile in this folder.

you can run it with something like:

```
docker run -v $PWD:/images huygensing/charterportaal_thumbnail_downloader -f /images/archives_to_download.txt -w 300 -p /images/img
```

archives_to_download.txt can be found in this folder
