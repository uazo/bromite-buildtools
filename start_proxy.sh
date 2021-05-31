mkdir ngrok

cd ngrok/

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip

./ngrok authtoken $NGROK_TOKEN
./ngrok http 8088 --log stdout --log-level info >ngrok.txt &

sleep 10s
cat ngrok.txt

cd ..