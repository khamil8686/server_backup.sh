#!/bin/bash
# Script to backup entire sever to /nas
export date=`date +%m_%d_%y`;
export backup_dir="/dir/server_backups";
export backup_name="server_backup_name";
export backup_full_name="${backup_name}_${date}";
export backup_full_path="${backup_dir}/${backup_full_name}.tar.gz";
export index_full_path="${backup_dir}/${backup_full_name}_index.txt";
export db_backup_name="db_backup";
export db_backup_full_name="${db_backup_name}_${date}.sql";
export db_user="user";
export db_pass="pass";
export db_host="127.0.0.1";
export days_to_keep_backups=10;
export excludesfile_name="excludes_file.txt";
export path_to_exclude_file="${backup_dir}/$excludesfile_name";
#export services=("service-name");

# Stop services
#for service in "${!services[@]}"; do
#  export cmd="systemctl stop ${services[$index]}";
#  echo "Stopping services${my_array[$index]}... $cmd";
#  eval $cmd;
#done

# Delete database backups older than 1 day
IFS= read -r -d '' cmd <<EOF
find /tmp -maxdepth 1 -iname '${db_backup_name}*.sql' -ctime +1 -exec rm -v {} \; 2>&1
EOF
echo "Deleting old database backups... $cmd" 2>&1
eval $cmd

# Backup all host databases to /tmp/${db_backup_full_name}
IFS= read -r -d '' cmd <<EOF
mariadb-dump --user='${db_user}' -h ${db_host} --password=${db_pass} --all-databases > /tmp/${db_backup_full_name} 2>&1
EOF
echo "Backing up database... $cmd" 2>&1
eval $cmd

# Delete server backups older than X days
IFS= read -r -d '' cmd <<EOF
find "${backup_dir}" -maxdepth 1 -iname "${backup_name}*" -ctime +${days_to_keep_backups} -exec rm -v {} \; 2>&1
EOF
echo "Deleting old server backups... $cmd" 2>&1
eval $cmd

# Backup entire server to ${backup_full_path).tar.gz
IFS= read -r -d '' cmd <<EOF
tar --sparse --preserve-permissions --gzip --exclude-from=${path_to_exclude_file} --exclude-backups --verbose --index-file=${index_full_path} --create --file ${backup_full_path} / 2>&1
EOF
echo "Backing up entire server... $cmd" 2>&1
eval $cmd

# Set permissions on backup file
#IFS= read -r -d '' cmd <<EOF
#chown user:group ${index_full_path} 2>&1;
#chown user:group ${backup_full_path} 2>&1;
#EOF
#echo "Changing permissions on backup for Nextcloud... $cmd" 2>&1
##eval $cmd

# Copy remote /nas to /nas_backup using rsync
#IFS= read -r -d '' cmd <<EOF
#rsync -rlptgo --delete-before /nas /nas_backup 2>&1
#EOF
#echo "Backing up /nas to /nas_backup... $cmd" 2>&1
##eval $cmd

# Start services that were stopped
#for service in "${!services[@]}"; do
#  export cmd="systemctl start ${services[$index]}";
#  echo "Starting services${my_array[$index]}... $cmd";
#  eval $cmd;
#done
