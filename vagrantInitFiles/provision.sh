#should probably put these in some sort of function to check if they need to be installed rather than just trying to brute
#force install them
apt-get -y update
apt-get -y upgrade
apt-get -y install net-tools
apt-get -y install build-essential
apt-get -y install nginx
service nginx start
apt-get -y install nodejs
apt-get -y install npm

#clones the setup files for the VM, removes the current host file and replaces it with the one created to allow access to the host machine.
git clone https://github.com/PandaJoey/vagrantSetupAndHostFiles.git
sudo rm -rf /etc/hosts
cd vagrantSetupAndHostFiles/hostConnections/
sudo mv hosts /etc/hosts

#creates the nginx sites-enabled files by getting the ip of the host/vm and putting the ip in a file, then moves it to the sites-enabled file
#not sure if both files are required or if its one for each machine depending on the port it needs to access.
ip="$(ifconfig | grep lo -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
echo "upstream app_Hello {
        server $ip:3012;
}" > hello-app
echo 'server {
        listen 80;
        server_name l.hello.akerolabs.com;
        access_log /var/log/nginx/hello-admin.log;
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_pass http://app_Hello/;
                proxy_redirect off;
                proxy_http_version 1.1;
                proxy_buffering off;
        }
}' >> hello-app
echo "upstream app_HelloVm {
        server $ip:3025;
}" > hellovm-app

echo 'server {
        listen 80;
        server_name l.hellovm.akerolabs.com;
        access_log /var/log/nginx/hello-admin.log;
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_pass http://app_HelloVm/;
                proxy_redirect off;
                proxy_http_version 1.1;
                proxy_buffering off;
        }
}' >> hellovm-app
mv hello-app /etc/nginx/sites-enabled/
mv hellovm-app /etc/nginx/sites-enabled/

#restarts nginx so the sites-enabled can be updated
sudo nginx -s stop
sudo service nginx start

#enters the folder where the node project is and runs it ready to be accessed. 
cd ..
cd node-project/
npm install -y
node app.js &

#this scipt will need improvement so any feedback is good.