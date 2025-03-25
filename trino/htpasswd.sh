sudo apt install apache2-utils

touch password.db
htpasswd -B -C 10 password.db ${username}