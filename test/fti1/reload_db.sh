#!/bin/bash

#!/bin/bash

# Get the current directory name as database name
database_name=$(basename "$PWD")

# Loop through all .ibd files in the current directory
for ibd_file in *.ibd; do
    # Skip if no .ibd files are found
    [ -e "$ibd_file" ] || continue

    # Get the table name (filename without extension)
    table_name="${ibd_file%.ibd}"

    echo "Processing table: $table_name in database: $database_name"

    # Backup the .ibd file to .ibd.bak
    cp "$ibd_file" "$ibd_file.bak"
    if [ $? -ne 0 ]; then
        echo "Failed to copy $ibd_file"
        continue
    fi
    # Discard tablespace
    mysql --skip-column-names --batch --database "$database_name" --execute "SET foreign_key_checks = 0;SET @@session.innodb_strict_mode = 0;SET sql_mode = ''; ALTER TABLE \`$table_name\` DISCARD TABLESPACE"
    if [ $? -ne 0 ]; then
        echo "Failed to discard tablespace for $table_name"
        continue
    fi

    # Copy the replacement .ibd file from the incoming directory
    incoming_file="/var/lib/percona/incoming/$database_name/$ibd_file"
    incoming_cfg_file="/var/lib/percona/incoming/$database_name/$table_name.cfg"
    if [ ! -f "$incoming_file" ]; then
        echo "Incoming file $incoming_file not found!"
        continue
    fi
    cp "$incoming_file" .
    if [ $? -ne 0 ]; then
        echo "Failed to copy $incoming_file"
        continue
    fi
    cp "$incoming_cfg_file" .

    chown 1001 $table_name.ibd
    chown 1001 $table_name.cfg

    chmod 0777 $table_name.ibd
    chmod 0777 $table_name.cfg

    if [ $? -ne 0 ]; then
        echo "Failed to copy $incoming_cfg_file"
        continue
    fi

    # Import tablespace
    mysql --skip-column-names --batch --database "$database_name" --execute "ALTER TABLE \`$table_name\` IMPORT TABLESPACE"
    if [ $? -ne 0 ]; then
        echo "Failed to import tablespace for $table_name"
        continue
    else
        rm $incoming_file
        rm $incoming_cfg_file
    fi

    echo "Successfully processed $table_name"
done