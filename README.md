# mysql-shrink-database
Shrink mysql database

Bash script to shrink files in mysql database


All the steps we need to compress mysql database based on stackoverflow thread
http://dba.stackexchange.com/questions/8982/what-is-the-best-way-to-reduce-the-size-of-ibdata-in-mysql

Step 01) MySQLDump all databases into a SQL text file
Step 02) Drop all databases (except mysql, performance_schema, and information_schema)
Step 03) Shutdown mysql
Step 04) Add the following lines to /etc/my.cnf
  [mysqld]
  innodb_file_per_table
  innodb_flush_method=O_DIRECT
  innodb_log_file_size=1G
  innodb_buffer_pool_size=4G
Step 05) Delete ibdata1, ib_logfile0 and ib_logfile1
Step 06) Restart mysql
Step 07) Reload SQLData.sql into mysql

I hope you enjoy!



