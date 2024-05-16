#/bin/sh
echo "Update Environment"

cat .crds-to-apply | grep "environments/dev" > crds-env-to-apply.txt | true

# Read the input file line by line using a for loop
IFS=$'\n' # set the Internal Field Separator to newline
for line in $(cat "crds-env-to-apply.txt")
do
    command="ssd apply -f $line"
    echo "Executando: $command"
done