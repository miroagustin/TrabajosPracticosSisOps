#!/bin/bash
#TP1 - Ejercicio 4 - Primera Entrega
#Integrantes:
#Parra, Martin                  DNI:40012233
#Di Vito, Tomas                 DNI:39340228
#Fernandez, Matias Gabriel      DNI:38613699
#Mirò, Agustin                  DNI:40923621
#Estevez, Adrian                DNI:39325872

if [[ $1 == "--help" || $1 == "-h" || $1 == "-?" ]]
then
        echo "

        Autor: Grupo 4

        Ejercicio 6 Trabajo Practico 1

        Este script debe ejecutarse como ./tp1_ej6.sh -f directorioArchivoEntrada
        
        El script procesará el archivos de entrada, sumando todos los numeros fraccionarios contenidos en el.
        El resultado sera otro numero fraccionario, simplificado, el cual se mostrara por pantalla ademas de guardarse dentro de un archivo llamado salida.out..

        El directorio de prueba es lotes_ej6

        "
        exit 0;
fi
#Validacion de parametros
[[ $# != 2 ]] && { echo "Hay un error en los parametros, revise el --help"; exit 1; }
[[ "$1" != "-f" ]] && { echo "El primer parametro debe ser -f"; exit 2; }
[[ -f "$2" ]] || { echo "El archivo ingresado por parametro no existe"; exit 3; }
[[ -s "$2" ]] || { echo "El archivo ingresado por parametro se encuentra vacio"; exit 3; }

echo "Procesando..."

fracciones=$(cat "$2")
fracciones=${fracciones//:/' + '}
fracciones=${fracciones//,/' + '}
fracciones=${fracciones//-/'- '}

num1=0
den1=1
signo="+"
for i in ${fracciones}
do
        elemento=$i
        if [[ ${elemento} != '+' && ${elemento} != '-' ]]
        then
                [[ $(echo ${elemento} | awk '{print match($0, "/")}') -eq 0 ]] && { elemento="${elemento}/1"; }
                num2=$(echo ${elemento} | awk '{print substr($0,1,index($0,"/")-1)}')
                den2=$(echo ${elemento} | awk '{print substr($0,index($0,"/")+1)}')
                mcm=$(echo "${den1}*${den2}" | bc)
                res1=$(echo "${mcm}/${den1}*${num1}" | bc)
                res2=$(echo "${mcm}/${den2}*${num2}" | bc)
                res3=$(echo "${res1}${signo}${res2}" | bc)
                num1=${res3}
                den1=${mcm}
        fi
        [[ ${elemento} == '+' || ${elemento} == '-' ]] && { signo=${elemento}; }
done

numerador=${num1}
denominador=${den1}
[[ ${num1} -lt 0 ]] && { signo="-"; } || { signo="+"; }
[[ ${num1} -gt ${den1} ]] && { dividendo=$(echo ${num1} | tr -d -); divisor=${den1}; } || { dividendo=${den1}; divisor=$(echo ${num1} | tr -d -); }

resto=$(echo "${dividendo}%${divisor}" | bc)
while [ ${resto} -gt 0 ]; do resto=$(echo "${dividendo}%${divisor}" | bc); [[ ${resto} -eq 0 ]] && { break; }; dividendo=${divisor}; divisor=${resto}; done
MCD=${divisor}

numerador=$(echo "${numerador}/${MCD}" | bc)
denominador=$(echo "${denominador}/${MCD}" | bc)

echo "Resultado de la suma recibida del archivo $2: ${signo}${numerador}/${denominador}" > salida.out
echo "${signo}${numerador}/${denominador}"