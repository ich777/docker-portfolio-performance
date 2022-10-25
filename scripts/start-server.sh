#!/bin/bash
export DISPLAY=:99
export XDG_RUNTIME_DIR="/tmp/runtime-portfolio"
export XAUTHORITY=${DATA_DIR}/.Xauthority

DL_URL="$(wget -qO- https://api.github.com/repos/buchen/portfolio/releases/latest | jq -r ".assets[].browser_download_url" | grep "\-linux.gtk.x86_64.tar.gz" | grep -v ".tar.gz.asc")"
CUR_V="$(find ${DATA_DIR}/bin -name instv* 2>/dev/null | cut -d 'v' -f2)"
LAT_V="$(echo "$DL_URL" | cut -d '/' -f8)"

if [ -z "$LAT_V" ]; then
  if [ ! -z "$CUR_V" ]; then
    echo "---Can't get latest version of Portfolio-Performance falling back to v$CUR_V---"
    LAT_V="$CUR_V"
  else
    echo "---Something went wrong, can't get latest version of Portfolio-Performance, putting container into sleep mode---"
    sleep infinity
  fi
fi

echo "---Checking if Runtime is installed---"
if [ -z "$(find ${DATA_DIR}/runtime -name jre* 2>/dev/null)" ]; then
  echo "---Downloading and installing ${RUNTIME_NAME}---"
  mkdir -p ${DATA_DIR}/runtime
  cd ${DATA_DIR}/runtime
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/runtime/${RUNTIME_NAME}.tar.gz "${JRE_URL}" ; then
    echo "---Successfully downloaded ${RUNTIME_NAME}!---"
  else
    echo "---Something went wrong, can't download ${RUNTIME_NAME}, putting server in sleep mode---"
	rm -rf ${DATA_DIR}/runtime/${RUNTIME_NAME}.tar.gz
    sleep infinity
  fi
  mkdir ${DATA_DIR}/runtime/${RUNTIME_NAME}
  echo "---Please wait, extracting runtime!---"
  tar --directory ${DATA_DIR}/runtime/${RUNTIME_NAME} --strip-components=1 -xzf ${DATA_DIR}/runtime/${RUNTIME_NAME}.tar.gz
  rm -rf ${DATA_DIR}/runtime/${RUNTIME_NAME}.tar.gz
else
  echo "---Runtime found!---"
fi

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
  echo "---Portfolio-Performance not installed, installing---"
  mkdir -p ${DATA_DIR}/bin
  cd ${DATA_DIR}/bin
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz ${DL_URL} ; then
    echo "---Sucessfully downloaded Portfolio-Performance---"
  else
    echo "---Something went wrong, can't download Portfolio-Performance, putting container in sleep mode---"
	rm -rf ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz
    sleep infinity
  fi
  tar -C ${DATA_DIR}/bin --strip-components=1 -xf ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz
  rm -rf ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz
  touch ${DATA_DIR}/bin/instv$LAT_V
elif [ "$CUR_V" != "$LAT_V" ]; then
  echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
  rm -rf ${DATA_DIR}/bin
  mkdir -p ${DATA_DIR}/bin
  cd ${DATA_DIR}/bin
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz ${DL_URL} ; then
    echo "---Sucessfully downloaded Portfolio-Performance---"
  else
    echo "---Something went wrong, can't download Portfolio-Performance, putting container in sleep mode---"
	rm -rf ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz
    sleep infinity
  fi
  tar -C ${DATA_DIR}/bin --strip-components=1 -xf ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz
  rm -rf ${DATA_DIR}/bin/PP-v$LAT_V.tar.gz
  touch ${DATA_DIR}/bin/instv$LAT_V
elif [ "$CUR_V" == "$LAT_V" ]; then
  echo "---Portfolio-Performance v$CUR_V up-to-date---"
fi

echo "---Preparing Server---"
if [ ! -d /tmp/runtime-portfolio ]; then
	mkdir -p /tmp/runtime-portfolio
	chmod -R 0700 /tmp/runtime-portfolio
fi
echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=1280
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=1024
fi

if [ "${CUSTOM_RES_W}" -le 1279 ]; then
	echo "---Width to low must be a minimal of 1280 pixels, correcting to 1280...---"
    CUSTOM_RES_W=1280
fi
if [ "${CUSTOM_RES_H}" -le 1023 ]; then
	echo "---Height to low must be a minimal of 1024 pixels, correcting to 1024...---"
    CUSTOM_RES_H=1024
fi
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Portfolio---"
export PATH=$PATH:$(find ${DATA_DIR}/runtime/ -maxdepth 1 -mindepth 1 -type d)/bin
cd ${DATA_DIR}
${DATA_DIR}/bin/PortfolioPerformance ${START_PARAMS} 2>/dev/null