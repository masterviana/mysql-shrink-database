
#!/bin/sh


# (1) set up all the mysqldump variables
FILE=minime.sql.`date +"%Y%m%d"`
DBSERVER=127.0.0.1
USER=root
PASS=ilovemysql
IBDATA1=/var/lib/mysql/ibdata1
IB_LOGFILE0=/var/lib/mysql/ib_logfile0
IB_LOGFILE1=/var/lib/mysql/ib_logfile1

# (2) in case you run this more than once a day, remove the previous version of the file
unalias rm     2> /dev/null
rm ${FILE}     2> /dev/null
rm ${FILE}.gz  2> /dev/null

# (3) do the mysql database backup (dump)

# use this command for a database server on a separate host:
#mysqldump --opt --protocol=TCP --user=${USER} --password=${PASS} --host=${DBSERVER} ${DATABASE} > ${FILE}


# use this command for a database server on localhost. add other options if need be.
mysqldump --opt --user=${USER} --password=${PASS} --all-databases --hex-blob --routines --triggers  > ${FILE}

# (4) gzip the mysql database dump file
#gzip $FILE

# (5) show the user the result
echo "${FILE} was created:"
ls -l ${FILE}

#drop database except mysq, performance_schema information_schema
mysql -u ${USER} -p${PASS} << EOF
SET @tables = NULL;
select table_schema INTO @tables  FROM information_schema.tables TB
where TB.TABLE_SCHEMA not in ('information_schema','mysql','performance_schema');
SET @tables = CONCAT('DROP DATABASE ', @tables);
PREPARE stmt1 FROM @tables;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;
EOF

echo "Delete all mysql tables"

#Shutdown mysql service
service mysql stop
echo "Stop mysql service"



#You should add this lines on /etc/my.conf
#If you want to solve ibdata1 ib_logfile0 and ib_logfile1

#[mysqld]
#innodb_file_per_table
#innodb_flush_method=O_DIRECT
#innodb_log_file_size=1G
#innodb_buffer_pool_size=4G

#delete ibdata1 ib_logfile0 and ib_logfile1
#delete ibdata1
if [ -f $IBDATA1 ] ; then
    echo "delete file  ${IDDATA1}"
    rm -rf $IBDATA1
fi

#delete ib_logfile0
if [ -f $IB_LOGFILE0 ] ; then
    rm -rf $IB_LOGFILE0
fi


#delete ib_logfile1
if [ -f $IB_LOGFILE1 ] ; then
    rm -rf  $IB_LOGFILE1
fi


#start mysql service
service mysql start
echo "start mysql service"

#load database from dump
echo "Will load all dumop file: ${FILE}"
mysql -u ${USER} -p${PASS}  < ${FILE}

echo "Mysql Dump was loaded"
