#!/bin/bash

# 1. Check if .env file exists
if [ -e .env ]; then
    source .env
else 
    echo "Vi que você não criou o seu arquivo .env, então vamos criar um para você."
    cp .env.sample .env
    exit 1
fi

binLogFile=$(docker exec -it mysql-primary sh -c "MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql -uroot -e 'SHOW MASTER STATUS\G;' | sed -n 's/.*File: //p'")
position=$(docker exec -it mysql-primary sh -c "MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql -uroot -e 'SHOW MASTER STATUS\G;' | sed -n 's/.*Position: //p'")

docker exec -it mysql-secondary sh -c "MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql -uroot -e \"CHANGE MASTER TO MASTER_HOST='mysql-primary',MASTER_USER='root',MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD',MASTER_LOG_FILE='$binLogFile',MASTER_LOG_POS=$position;\""
docker exec -it mysql-secondary sh -c "MYSQL_PWD=$MYSQL_ROOT_PASSWORD mysql -uroot -e \"START SLAVE;\""

echo $binLogFile $position

