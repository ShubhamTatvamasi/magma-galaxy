#!/bin/bash

# Solicita o número de linhas a serem geradas
read -p "Digite o número de linhas a serem geradas: " num_linhas

# Solicita o valor PLMN (até 6 dígitos)
read -p "Digite o valor PLMN (até 6 dígitos): " plmn

# Solicita o valor de uma APN
read -p "Digite o nome da APN: " apn

# Gera um arquivo template.txt
echo ";Data items are separated by 1 space" > template.txt
echo ";Data items header must be listed below, cannot be changed" >> template.txt
echo ";Data items header must be consistent and data value" >> template.txt
echo ";You can choose a few data items" >> template.txt
echo ";The IMSI must be in front of ACC" >> template.txt
echo "PIN1 PUK1 PIN2 PUK2 ADM ICCID IMSI ACC MSISDN KI OPC" >> template.txt

# Loop para gerar o número especificado de linhas
for ((i=1; i<=num_linhas; i++)); do
    # Gera valores aleatórios para PIN, PUK, ADM, ICCID, IMSI e MSISDN
    PIN=$(printf "%04d" $((RANDOM % 10000)))
    PUK=$(printf "%08d" $((RANDOM % 100000000)))
    ADM=$(openssl rand -hex 4 | tr '[:lower:]' '[:upper:]')
    ICCID=$(printf "%018d" $((RANDOM % 1000000000000000000)))
    
    while true; do
        IMSI="$plmn$(printf "%010d" $((RANDOM % 1000000000)))"
        # Verifica se o IMSI já existe no array
        if [[ -z "${imsi_array[$IMSI]}" ]]; then
            # Se não existe, adiciona ao array e sai do loop
            imsi_array[$IMSI]="1"
            break
        fi
    done

    ACC="8001"

    MSISDN=$(printf "%010d" $((RANDOM % 10000000000)))

    KI=$(openssl rand -hex 16)
    OPC=$(openssl rand -hex 16)

    # Adiciona a linha ao arquivo template.txt
    echo "$PIN $PUK $PIN $PUK $ADM $ICCID $IMSI $ACC $MSISDN $KI $OPC" >> template_"$apn".txt
done


awk 'NR>6 {print "IMSI"$7",IMSI"$7","$10","$11",ACTIVE,None,dataplan100M,APN,policy100M"}' template_"$apn".txt > subscribers_"$apn".csv
sed -i "s/APN/$apn/g" subscribers.csv


echo "O arquivo template.txt foi gerado com sucesso com $num_linhas linhas."

exit 0
