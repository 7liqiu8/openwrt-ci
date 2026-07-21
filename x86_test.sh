

./scripts/feeds update -a
./scripts/feeds install -a

#  Fullcone 补丁
echo "正在应用 Fullcone NAT 补丁..."
curl -sSL -o add_sonic_fullcone.sh \
  https://raw.githubusercontent.com/mufeng05/openwrt-sonic-fullcone/master/add_sonic_fullcone.sh
  
chmod +x add_sonic_fullcone.sh

./add_sonic_fullcone.sh
