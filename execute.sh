#/bin/sh
echo "Update Environment"

cat .crds-to-apply | grep "environments/dev" > crds-env-to-apply.txt | true

for line in $(cat "crds-env-to-apply.txt")
do
    command="ssd apply -f $line"
    echo "Executando: $command"
done