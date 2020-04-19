#!/bin/bash
PIFS=IFS
IFS="
"
if ! test -d "$1" || ! test -e "$1"; then
	echo "No es un directorio" $1
	exit 1;
fi

leer_archivo()
{
	declare -A llamadas
	while read -r line  || [[ -n "$line" ]];
	do
		fecha=$(echo $line | cut -d' ' -f 1)
		hora=$(echo $line | cut -d' ' -f 2)
		usuario=$(echo $line | cut -d' ' -f 4)
		segundos=$(date +%s -d "$fecha $hora")
	
		if [[ ${llamadas[$usuario]} == "" ]]
		then
			llamadas[$usuario]=$segundos
		fi
	
		tiempo_llamada=$(( ($segundos-${llamadas[$usuario]}) / 60 ))
	
		if [[ $tiempo_llamada != 0 ]]
		then
			echo $fecha $hora $usuario $tiempo_llamada >> $2
			llamadas[$usuario]=""
		fi
	done < "$1"
}
for path in $(ls $1) 
do
	nombre_archivo=$(echo $path | cut -d'.' -f 1)
	nombre_procesado="$nombre_archivo-llamadas.txt"
	leer_archivo $1/$path $nombre_procesado
	awk '
	BEGIN
	{
		print "-------------------------------------------------------------"
	}
	{
		tiempo_total_semana+=$4
		cant_llamadas_semana++
		tiempo_total_dia[$1][$3]+=$4
		cant_llamadas_dia[$1][$3]++
		tiempo_llamadas_usuario[$3][$1][NR]=$4
	}
	END {
		printf("Para el archivo %s\n\n", FILENAME)
		promedio_semana=tiempo_total_semana/cant_llamadas_semana
		for (dia in cant_llamadas_dia)
		{
			printf("Para el dia %s\n",dia)
			for(usuario in cant_llamadas_dia[dia])
			{
				tiempo_total_usuario = tiempo_total_dia[dia][usuario]
				cant_llamadas_usuario = cant_llamadas_dia[dia][usuario]

				printf("\t El usuario %s tiene un promedio de tiempo de %s y una cantidad de llamadas %s \n",
			       		usuario,tiempo_total_usuario/cant_llamadas_usuario, cant_llamadas_usuario)
				
				tiempo_dia+=tiempo_total_usuario
				cant_dia+=cant_llamadas_usuario
				cant_llamadas_semana_usuario[usuario] = cant_llamadas_usuario
			}
			promedios_dia[dia]=tiempo_dia/cant_dia
			printf("El promedio de tiempo del dia es de %s \n\n", promedios_dia[dia])
		}
		for (usuario in tiempo_llamadas_usuario)
		{
			for(dia in tiempo_llamadas_usuario[usuario])
			{
				for(llamada in tiempo_llamadas_usuario[usuario][dia])
				{
					if(llamada < promedio_semana)
						menores_promedio_semana[usuario]++
					if(llamada < promedios_dia[dia])
						menores_promedio_dia[dia]++
				}
			}
		}
		print "Cantidad de llamadas que no superan la media por dia"
		for (dia in menores_promedio_dia)
		{
			print "Dia: ",dia,"llamadas: ", menores_promedio_dia[dia]
		}
		print "\n"

		PROCINFO["sorted_in"] = "@val_num_desc"
		stop=0
		print "Top 3 Usuarios con las mayores llamadas por semana"
		for (i in cant_llamadas_semana_usuario)
		{
			if(stop == 3)
				break;
			print "Usuario: ", i,"Cantidad Llamadas: ", cant_llamadas_semana_usuario[i]
			stop++;

		}
		print "\n"
		print "El usuario con mas llamadas menores al promedio por semana"
		stop=0
		for (i in menores_promedio_semana)
		{
			if(stop == 1)
				break;
			print i, menores_promedio_semana[i]
			stop++
		}
		print "\n"
	}
	' $nombre_procesado
	rm $nombre_procesado	
done
