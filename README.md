# Portfolio-Performance in Docker optimized for Unraid
Portfolio Performance is an open source tool to calculate the overall performance of an investment portfolio - across all accounts - using True-Time Weighted Return or Internal Rate of Return.

**Update:** The container will check on every start/restart if there is a newer version available

**ATTENTION:** Please save your documents only in the Home directory! Please don't save or modify anything inside the 'bin' and 'runtime' folders.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| CUSTOM_RES_W | Minimum of 1280 pixesl (leave blank for 1280 pixels) | 1280 |
| CUSTOM_RES_H | Minimum of 1024 pixesl (leave blank for 1024 pixels) | 1024 |
| UMASK | Set permissions for newly created files | 0000 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name Portfolio-Performance -d \
    -p 8080:8080 \
    --env 'CUSTOM_RES_W=1280' \
    --env 'CUSTOM_RES_H=1024' \
    --env 'UMASK=0000' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /path/to/portfolio-performance:/portfolio \
    --restart=unless-stopped\
    ich777/portfolio-performance
```

### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!
 
#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/
