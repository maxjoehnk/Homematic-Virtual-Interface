ADDONNAME=hvl
ADDON_DIR=/usr/local/addons/${ADDONNAME}
CONFIG_DIR=/usr/local/etc/config
WWW_DIR=${CONFIG_DIR}/addons/www/${ADDONNAME}

#check if we have our core module; if not go ahead and call the installer stuff
if [ ! -f ${ADDON_DIR}/node_modules/homematic-virtual-interface/lib/index.js ]; then

mkdir -p ${WWW_DIR}
chmod 755 ${WWW_DIR}

echo "[Installer]Start installer" >>/var/log/hvl.log
echo "[Installer]Program Dir is ${ADDON_DIR}" >>/var/log/hvl.log

#install node and fetch the core module
cd ${ADDON_DIR}

#
#
#echo "[Installer]Installing node" >>/var/log/hvl.log


#if $(uname -m | grep -Eq ^armv6); then
# wget https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-armv6l.tar.xz -Onode.tar.xz --no-check-certificate
# tar xf node.tar.xz
# rm node.tar.xz
# mv node-v6.10.0-linux-armv6l node
#else
# wget https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-armv7l.tar.xz -Onode.tar.xz --no-check-certificate
# tar xf node.tar.xz
# rm node.tar.xz
# mv node-v6.10.0-linux-armv7l node
#fi



echo "[Installer]Switch Root FS to RW" >>/var/log/hvl.log

# since the settingsfile of npm is located in /root/.npm we need rw on the root filesystem
mount -o remount,rw /

echo "[Installer]mk cache dir ${ADDON_DIR}/.npm" >>/var/log/hvl.log
cd ${ADDON_DIR}
mkdir ${ADDON_DIR}/.npm

echo "cache=/usr/local/addons/hvl/.npm" > /root/.npmrc
echo "init-module=/usr/local/addons/hvl/.npm-init.js" >> /root/.npmrc
echo "userconfig=/usr/local/addons/hvl/.npmrc" >> /root/.npmrc
echo "path=/usr/local/addons/hvl/.npm" >> /root/.npmrc



#install log rotator
echo "[Installer]Add logrotator" >>/var/log/hvl.log
cp ${ADDON_DIR}/etc/hvl.conf /etc/logrotate.d/hvl.conf


#make .npm
echo "[Installer]Build cache " >>/var/log/hvl.log
npm config set cache ${ADDON_DIR}/.npm >>/var/log/hvl.log

echo "[Installer]Check cache " >>/var/log/hvl.log
npm config get cache >>/var/log/hvl.log

#install the core system
echo "[Installer]Install Core system" >>/var/log/hvl.log
cd ${ADDON_DIR}
npm install homematic-virtual-interface >>/var/log/hvl.log

echo "[Installer]Switch Root FS back to RO" >>/var/log/hvl.log

echo "[Installer]Add Menu Buttons" >>/var/log/hvl.log
#add the menu button
cd /usr/local/addons/hvl/etc/
chmod +x update_addon
chmod +x remove_hvl_object
#touch /usr/local/etc/config/hm_addons.cfg
node /usr/local/addons/hvl/etc/hm_addon.js hvl /usr/local/addons/hvl/etc/hvl_addon.cfg


#link redirector
ln ${ADDON_DIR}/etc/www/index.html ${WWW_DIR}/index.html

#Setup config.json
if [ ! -f ${CONFIG_DIR}/hvl/config.json ]; then
	cp ${ADDON_DIR}/etc/config.json.default ${CONFIG_DIR}/hvl/config.json
	sed -i ${CONFIG_DIR}/hvl/config.json -e "s/ADDON_DIR/\/usr\/local\/addons\/hvl/g"
fi

# end check install needed
fi

#switch back to read only
mount -o remount,ro /

#Rebuild .npmrc on ever boot
#mount -o remount,rw /
#echo "cache=/usr/local/addons/hvl/.npm" > /root/.npmrc
#echo "init-module=/usr/local/addons/hvl/.npm-init.js" >> /root/.npmrc
#echo "userconfig=/usr/local/addons/hvl/.npmrc" >> /root/.npmrc
#echo "path=/usr/local/addons/hvl/.npm" >> /root/.npmrc
#mount -o remount,ro /
