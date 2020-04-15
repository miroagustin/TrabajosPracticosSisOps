#!/bin/bash
if [[ $1 == "-h" || $1 == "-?" || $1 == "--help" ]]
then
	echo "
	Ejercicio 3 Trabajo Practico 1
	Autor: Grupo 4

	A partir del directorio y el tiempo pasados por parametro, este script crea un demonio que verifica
	el path ingresado y borra los registros de semanas anteriores cuando se crea uno nuevo.

	Este script toma 2 parametros:
       	El primero es el path del directorio a revisar en la forma -p pathDirectorio
	El segundo es el tiempo que espera para revisar de nuevo el directorio en la forma -t tiempo
	"
	exit 1;
fi
if [[ $# != 4 ]]
then
	echo "Estan mal los parametros, por favor revise."
	exit 1;
fi
if [[ $1 != "-p" ]]
then
	echo "El primer parametro debe ser de la forma -p pathDirectorio"
	exit 1;
fi
if ! test -e $2 && ! test -d $2;
then
	echo "El path no existe o no es un directorio"
	exit 1;
fi
if [[ $3 != "-t" ]]
then
	echo "El segundo parametro debe ser de la forma -t tiempo"
	exit 1;
fi
if [[ $4 =~ [^1-9]+ ]]
then
	echo "El segundo parametros no es un numero mayor a 0"
	exit 1;
fi

for filename in `ls $2`; do

	if ! [[ $filename =~ [A-Za-z]+-[0-9]+(\.log) ]]
	then
		echo "Archivo Invalido:" $filename
		rm "$2/$filename"
	fi
	if test -e "$2/$filename"
	then
		nombreArchivo=`echo $filename | cut -d'-' -f 1`
		semanaArchivo=`echo $filename | cut -d'-' -f 2 | cut -d'.' -f 1`
		for candidato in `ls $2 | grep $nombreArchivo`; do
			semanaArchivoCandidato=`echo $candidato | cut -d'-' -f 2 | cut -d'.' -f 1`
			if [[ $semanaArchivo > $semanaArchivoCandidato ]] && test -e "$2/$candidato"
			then
				echo "Se elimino " $2/$candidato
				rm "$2/$candidato"
			fi
		done
	fi
done
sleep $4
