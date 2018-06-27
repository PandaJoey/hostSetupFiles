apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential
apt-get -y install nginx
service nginx start
apt-get -y install nodejs
apt-get -y install npm
git clone https://github.com/PandaJoey/vagrantTestScript.git
cd vagrantTestScript/
mv hello-app /etc/nginx/sites-enabled/
sudo nginx -s stop
sudo service nginx start
npm install -y
node app.js &
