#!/bin/bash
#TP1 - Ejercicio 3 - Primera Entrega
#Integrantes:
#Parra, Martin                  DNI:40012233
#Di Vito, Tomas                 DNI:39340228
#Fernandez, Matias Gabriel      DNI:38613699
#Mirò, Agustin                  DNI:40923621
#Estevez, Adrian                DNI:39325872
if [[ $1 == "-h" || $1 == "-?" || $1 == "--help" ]]
then
	echo "
	Ejercicio 3 Trabajo Practico 1
	Autor: Grupo 4

	A partir del directorio y el tiempo pasados por parametro, este script crea un demonio que verifica
	el path ingresado y borra los registros de semanas anteriores cuando se crea uno nuevo.

	Este script toma 2 parametros:
       	El primero es el path del directorio a revisar en la forma -f pathDirectorio
	El segundo es el tiempo que espera para revisar de nuevo el directorio en la forma -t tiempo

	El directorio de prueba es lotes_ej3		
	"
	exit 1;
fi
if [[ $# != 4 ]]
then
	echo "Estan mal los parametros, por favor revise el --help."
	exit 1;
fi
# Codigo para detectar los parametros
idx=1
for parametro in "$@"
do
	idx=$((idx+1))
	proximo_parametro=$(echo $@ | cut -d' ' -f $idx)
	if [[ $parametro == "-f" ]]
	then
		directorio=$proximo_parametro
	fi
	if [[ $parametro == "-t" ]]
	then
		tiempo=$proximo_parametro
	fi
done

if ! test -e $directorio && ! test -d $directorio;
then
	echo "El path no existe o no es un directorio"
	exit 1;
fi

if [[ $tiempo =~ [^1-9]+ ]]
then
	echo "El segundo parametros no es un numero mayor a 0"
	exit 1;
fi
empezarDemonio()
{
	directorio=$1
	tiempo=$2
	archivos=""
	while true; do
	sleep $tiempo
	archivosNuevos=$(ls $directorio)
	if [[ $archivos == $archivosNuevos ]]
	then
		continue;
	fi
	archivos=$archivosNuevos
	for filename in $archivos; do
		if ! [[ $filename =~ [A-Za-z]+-[0-9]+(\.log) ]]
		then
			archivos=${archivos//$filename /}
			continue;
		fi
		nombreArchivo=`echo $filename | cut -d'-' -f 1`
		semanaArchivo=`echo $filename | cut -d'-' -f 2 | cut -d'.' -f 1`
		for candidato in $archivos; do
			if ! test -e $directorio/$candidato
			then
				continue;
			fi
			semanaArchivoCandidato=`echo $candidato | cut -d'-' -f 2 | cut -d'.' -f 1`
			if [[ ! $candidato == *"$nombreArchivo"* || ! $candidato =~ [A-Za-z]+-[0-9]+(\.log) ]]
			then
				continue;
			fi
			if [ $semanaArchivo -gt $semanaArchivoCandidato ]
			then
				echo "
Se encontro $filename con semana $semanaArchivo se elimina $candidato con semana $semanaArchivoCandidato"
				archivos=${archivos//$candidato /}
				rm "$directorio/$candidato"
			fi
		done
	done
done
}
empezarDemonio $directorio $tiempo &
echo "Se inicio correctamente el demonio su PID es: $! y esta observando el directorio $directorio"
