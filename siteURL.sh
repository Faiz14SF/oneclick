#!/bin/bash

# Define output file
OUTPUT_FILE="siteURL.txt"

echo "Scanning MySQL databases for WordPress site URLs..."
echo "Saving results to: $OUTPUT_FILE"
echo "------------------------------------------------------"

# Clear the output file first
> "$OUTPUT_FILE"

{
echo "WordPress Site URL Scan Report"
echo "Generated on: $(date)"
echo "======================================================"
echo ""

# Get list of databases
databases=$(mysql -N -B -e "SHOW DATABASES;" | grep -vE "information_schema|performance_schema|mysql|sys")

for db in $databases; do
    echo "Checking database: $db"

    # Get list of tables in the DB that look like *_options
    option_tables=$(mysql -N -B -e "SHOW TABLES FROM \`$db\` LIKE '%_options';")

    for table in $option_tables; do
        # Try to fetch siteurl and home
        result=$(mysql -N -B -e "SELECT option_name, option_value FROM \`$db\`.\`$table\` WHERE option_name IN ('siteurl','home');")

        if [[ -n "$result" ]]; then
            echo "✅ Database: $db"
            echo "📦 Table: $table"
            echo "$result"
            echo "------------------------------------------------------"
        fi
    done
done

echo ""
echo "Scan completed on: $(date)"
} | tee -a "$OUTPUT_FILE"

echo "Results saved to: $OUTPUT_FILE"
