<#
.SYNOPSIS
        El script realiza dos funciones no simultaneas cada cierto tiempo.
        -Informar el promedio de tiempo de las llamas realizadas por dia
        -Informar el promedio de tiempo y cantidad por usuario por dia
        -Los tres usuarios con mas llamadas en la semana
        -Informar cuantas llamadas no superan la media de tiempo por dia y la persona con mas llamadas que no la supero en la semana
.DESCRIPTION
        El script recibe como primer parametro -Path el cual lo que viene a continuacion es la ruta de acceso
        parametro el directorio a analizar. Si no recibe segundo parametro
        se toma por defecto el directorio en el que se encuentra ejecutando el script.
.EXAMPLE
        ./ej2_tp2.ps1 -Path ./lote
.NOTES
        TRABAJO PRÁCTICO 2 - EJERCICIO 2
        PRIMERA ENTREGA 
        INTEGRANTES:
        Parra, Martin                  DNI:40012233
        Di Vito, Tomas                 DNI:39340228
        Fernandez, Matias Gabriel      DNI:38613699
        Mirò, Agustin                  DNI:40923621
        Estevez, Adrian                DNI:39325872

#>

Param (
    [Parameter(Position = 1, Mandatory = $true)]
    [String] $Path
)

$ErrorActionPreference = "Stop"
function resolver()
{
    Param ([string]$Path)
    $archivos=Get-ChildItem $Path
    
    #Variables Semana
    $promedio_semana = 0
    $cantidad_llamada_semana = 0
    $llamada_semana = @{}
    $cantidad_de_llamadas_semana = @{}
    $registrosLlamadaSemana=[System.Collections.ArrayList]@{}
    $llamada_debajo_media_semana=@{}
    
    
    foreach($archivo in $archivos)
    {
        #Variables para el dia (Inicializo los valores de vuelta para el otro archivo)
        $llamadaTiempo=@{}
        $cantidad_de_llamadas = @{}
        $promedio = @{}
        $duracionDiaUsuario=@{}
        $registrosLlamadaDia=[System.Collections.ArrayList]@{}
        $registrosLlamadaDelDia=[System.Collections.ArrayList]
        $Promedio_dia_total = 0 #Saco el Promedio Total del dia
        $cantidad_llamada_dia_total = 0#Acumulo todas las llamadas del dia
        $llamada_debajo_media_dia=0            
        
        foreach($line in Get-Content $archivo) 
        {
            if($line -match $regex) # Leo hasta el final del registro
            {    
                [DateTime]$fechaYhora=$line.Split(" _ ")[0] #Corto la fecha
                $usuario=$line.Split(" _ ")[1] # Corto el usuario.
                
                if(-Not $llamadaTiempo.ContainsKey($usuario)) #Si entra en ese caso es porque no hay registro de llamadas del usuario (seria el inicio)
                {
                    $llamadaTiempo[$usuario]=[DateTime]$fechaYhora #primero guardo la fecha como esta 
                }
                else
                {
                    #Calculos del dia---------------
                    $tiempo_llamada=New-TimeSpan -Start $llamadaTiempo[$usuario] -End $fechaYHora #resto las dos fechas y despues la paso a segundos 
                    $llamadaTiempo.Remove($usuario) #remuevo al usuario para seguir con el incio de la otra llamada
                    
                    $registrosLlamadaDelDia = "" | Select-Object    @{n='Fecha'; e={$fechaYhora}}, @{n='Usuario'; e={$usuario}},@{n='TiempoLlamada'; e={$tiempo_llamada}}
                    
                    $cantidad_de_llamadas[$usuario]=$cantidad_de_llamadas[$usuario]+1 # Es la cantidad de llamadas por dia                                                                    
                    $duracionDiaUsuario[$usuario] = $duracionDiaUsuario[$usuario] + $registrosLlamadaDelDia.TiempoLlamada.TotalMinutes # Es el total de minutos acumulados en el dia
                    $registrosLlamadaDia+=$registrosLlamadaDelDia #Lo agrego a la lista que cuando finalize los calculos del dia se limpia

                    #calculo semanal---------------
                    $registrosLlamadaSemana+=$registrosLlamadaDelDia #almaceno todos los registros para hacer las cosas semanal
                    if(-Not $llamada_debajo_media_semana[$usuario]) # Es para inicializar el value dentro del key (usuario)
                    {
                        $llamada_debajo_media_semana[$usuario]=0
                    }
                }
            }
        }

        #Calculo los promedios
        foreach($k in $duracionDiaUsuario.Keys)
        {
            [double]$promedio[$k]=$duracionDiaUsuario[$k]/$cantidad_de_llamadas[$k] #Promedio por usuario
          
            #Calculos para el dia
            $Promedio_dia_total = $Promedio_dia_total + $duracionDiaUsuario[$k] #Primero lo acumulo y cuando salgo del for lo divido
            $cantidad_llamada_dia_total = $cantidad_llamada_dia_total + $cantidad_de_llamadas[$k]
            #Calculos de la semana (estas no se eliminaran y se usan para los calculos de la semana)
            $promedio_semana = $promedio_semana + $duracionDiaUsuario[$k]
            $cantidad_llamada_semana=$cantidad_llamada_semana + $cantidad_de_llamadas[$k]
            $llamada_semana[$k]= $llamada_semana[$k] + $duracionDiaUsuario[$k]
            $cantidad_de_llamadas_semana[$k] = $cantidad_de_llamadas_semana[$k] + $cantidad_de_llamadas[$k]    
        }

        # Obtengo el promedio total del dia
        $Promedio_dia_total = $Promedio_dia_total / $cantidad_llamada_dia_total
        
        #Calculo la cantidad de llamadas que no superaron la media (por dia y por semana)
        foreach($z in $registrosLlamadaDia)
        {
            if($Promedio_dia_total -gt $z.TiempoLlamada.TotalMinutes)
            {
                $llamada_debajo_media_dia=$llamada_debajo_media_dia+1 #con esto saco la cantidad por dia (No piden que muestre la persona)
                
                $llamada_debajo_media_semana[$z.usuario]=$llamada_debajo_media_semana[$z.usuario]+1 #Sumo la cantidad de llamadas que estan por debajo de la media por usuario 
            }
        }

        # Muetro los resultados del dia
        Write-Host ""
        Write-Host "-------------------------------------------------------------------------"
        Write-Host $archivo.Name
        Write-Host "-------------------------------------------------------------------------"
        Write-Host "promedio de tiempo en el dia (Minutos):      " $Promedio_dia_total 
        Write-Host ""
        Write-Host "Cantidad de llamadas por debajo de la media: " $llamada_debajo_media_dia
        Write-Host ""
        Write-Host "---------------------------------------"
        Write-Host "Duracion de llamadas del dia (Minutos)"
        Write-Host "---------------------------------------" 
        $duracionDiaUsuario | Format-List
        
        Write-Host "----------------------------------------------------"
        Write-Host "Promedio de tiempo de llamadas por usuario (Minutos)"
        Write-Host "----------------------------------------------------" 
        $promedio | Format-List

        Write-Host "-----------------------------" 
        Write-Host "cantidad de llamadas del dia"
        Write-Host "-----------------------------" 
        $cantidad_de_llamadas | Format-List
        Write-Host "" 

    }
    Write-Host "------------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host "Calculos semanales"
    Write-Host "------------------------------------------------------------------------------------------------------------------------------------------"
    Write-Host ""
    $promedio_semana = $promedio_semana / $cantidad_llamada_semana 
    Write-Host "El promedio de llamadas es de: " $promedio_semana " minutos"
    Write-Host ""
    
    # Ordeno y muestro las tres personas con mas llamadas en la semana
    Write-Host "Las tres personas con mas llamadas de la semana son: "
    $contador=1
    foreach($item in $llamada_semana.GetEnumerator() | Sort-Object -Property "Value" -Descending )
    {
       if($contador -le 3)
       {
        $item | Format-List
       }
       else{break}
       $contador=$contador+1
    }
    Write-Host ""
    #Ordeno y muestro el mayor de todos
    Write-Host ""
    Write-Host "El usuario con mas llamadas por debajo de la media es: "
    $contador=0
    foreach($item in $llamada_debajo_media_semana.GetEnumerator() | Sort-Object -Property "Value" -Descending )
    {
       if($contador -lt 1)
       {
        $item | Format-List
       }
       else{break}
        $contador=$contador+1
    }
    Write-Host ""
}

resolver -Path $Path
