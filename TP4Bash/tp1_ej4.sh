#! /bin/bash
#TP1 - Ejercicio 3 - Primera Entrega
#Integrantes:
#Parra, Martin                  DNI:40012233
#Di Vito, Tomas                 DNI:39340228
#Fernandez, Matias Gabriel      DNI:38613699
#Mirò, Agustin                  DNI: 40923621
#Estevez, Adrian                DNI: 39325872

zipearEmpresa(){
#param1 --> nombre de la empresa
#param2 --> ruta donde guardo los zips
#param3 --> ruta donde estan los logs

    empresa="$1"
    out="${2%/}"
    logs="${3%/}"
    bandera=0
    mkdir $empresa
    for nombreLog in $(ls $logs); do
        nombreLeido="${nombreLog%%-*}"
        numeroActual=$(($(sed -e 's/\(^.*-\)\(.*\)\(\..*$\)/\2/' <<< $nombreLog)))
        if [ "$nombreLeido" == "$empresa" ]; then
            if [ $bandera -eq 0 ]; then
                semanaMayor=$numeroActual
                nombreSemanaMayor="$nombreLog"
                bandera=1
            elif [ $numeroActual -gt $semanaMayor ]; then
                mv "${logs}/${nombreSemanaMayor}" $empresa
                semanaMayor=$numeroActual  
                nombreSemanaMayor="$nombreLog"
            else
                nombreLog="${logs}/${nombreLog}"
                mv "$nombreLog" $empresa       
            fi        
        fi       
    done
    if [ "$(ls -A $empresa)" ]; then
        zip -r "${out}/${empresa}.zip" $empresa
    fi
    rm -r $empresa
}

if ([ $# != 4 ] && [ $# != 6 ]); then
    if [[($# == 1) && ( ("$1" == "-h") || ("$1" == "-?") || ("$1" == "-help") ) ]]; then
        echo "Descripcion:"
        echo "Al ejecutar el script, se genera un .zip con todos los logs generados hasta el momento, dejando en el directorio indicado, solamente aquellos de la ultima semana."
        echo "Para ejecutar el script correctamente debe ingresar: "
        echo "1 - Parametro: Directorio donde se encuentran los archivos logs."
        echo "2 - Parametro: Directorio donde se generara el .zip."
        echo "3 - Parametro (opcional): Nombre de la empresa en caso de querer generar solamente un archivo .zip de la misma."
        echo "Ejemplo de ejecución:"
        echo "./tp1_ej4.sh -f [DIRECTORIO DE LOGS] -z [DIRECTORIO DE ZIPS] -e (opcional) [NOMBRE DE EMPRESA] (opcional)"
        exit
    else
        echo "Error de llamada. Para ver ejemplos de ejecuciòn ingrese la opción -h, -? o -help."
        exit
    fi
fi

if [ "$1" != "-f" ]; then
    echo "Error de llamada. Para ver ejemplos de ejecuciòn ingrese la opción -h, -? o -help."
    exit
elif ! [ -d "$2" ]; then
    echo "El directorio de logs no existe."
    exit
fi

if [ "$3" != "-z" ]; then
    echo "Error de llamada. Para ver ejemplos de ejecuciòn ingrese la opción -h, -? o -help."
    exit
elif ! [ -d "$4" ]; then
    echo "El directorio de salida no existe."
    exit
fi    

logs="$2"
out="$4"
declare -a nombresEmpresas
primerNombreDistinto=""
i=0

for nombreLog in $(ls $logs); do
    nombreLeido="${nombreLog%%-*}"
    if [ "$nombreLeido" != "$primerNombreDistinto" ]; then
        primerNombreDistinto=$nombreLeido
        nombresEmpresas[i]=$primerNombreDistinto
        ((i++))
    fi       
done

if ([ $# == 6 ] && [ "$5" == "-e" ]); then
    for nombreEmpresa in $nombresEmpresas; do
        if [ "$6" == "$nombreEmpresa" ]; then
            zipearEmpresa "$6" $out $logs
            echo "Se ha creado el zip de la empresa: "$6            
            exit
        fi
    done
    echo "No se encontro la empresa indicada."
elif [ $# == 4 ]; then
    for empresa in "${nombresEmpresas[@]}"; do
        zipearEmpresa $empresa $out $logs
    done
    echo "Se han creado los zips correspondientes a cada una de las empresas"
else
    echo "Error de llamada. Para ver ejemplos de ejecuciòn ingrese la opción -h, -? o -help." 
    exit
fi
