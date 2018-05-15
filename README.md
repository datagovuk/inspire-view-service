# Skeleton INSPIRE View Service

A working skeleton of the INSPIRE preview service ripped from https://github.com/datagovuk/ckanext-os

## To try it out

* git clone git@github.com:datagovuk/inspire-view-service.git
* cd inspire-view-service
* bundle install
* export OS_APIKEY=<APIKEY>
* rails s

Navigate to ...

http://127.0.0.1:3000/?url=http%3A%2F%2Fenvironment.data.gov.uk%2Fds%2Fwms%3FSERVICE%3DWMS%26INTERFACE%3DENVIRONMENT--6f51a299-351f-4e30-a5a3-2511da9688f7%26request%3DGetCapabilities&amp;n=55.8&amp;w=-5.7&amp;e=1.8&amp;s=50.0


## What is left to fix it

Stop this being an open proxy...

