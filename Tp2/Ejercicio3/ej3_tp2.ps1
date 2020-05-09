Param (
    [ValidateScript( {
            if (-Not ($_ | Test-Path) ) {
                throw "El archivo o carpeta no existe" 
            }
            if (($_ | Test-Path -PathType Leaf) ) {
                throw "El parametro Directorio debe ser una carpeta"
            }
            return $true
        })]
    
    [string]$Directorio
)

$global:Directorio = $Directorio
<#
.Synopsis
Punto 3 del TP2 de Sistemas Operativos 1er Cuatrimestre 2020

Parra, Martin                  DNI:40012233
Di Vito, Tomas                 DNI:39340228
Fernandez, Matias Gabriel      DNI:38613699
Mirò, Agustin                  DNI:40923621
Estevez, Adrian                DNI:39325872
.DESCRIPTION
    Punto 3 del TP2 de Sistemas Operativos 1er Cuatrimestre 2020
    
    A partir del directorio pasado por parametro, este script verifica
    el path ingresado y borra los registros de semanas anteriores cuando se crea uno nuevo.
    El directorio de prueba es lotes_ej3	
    
    Parra, Martin                  DNI:40012233
    Di Vito, Tomas                 DNI:39340228
    Fernandez, Matias Gabriel      DNI:38613699
    Mirò, Agustin                  DNI:40923621
    Estevez, Adrian                DNI:39325872
.EXAMPLE
./ej3_tp2.ps1 lotes_ej3 1
.EXAMPLE
./ej3_tp2.ps1 -Directorio lotes_ej3 -Tiempo 1
.NOTES
Este Script usa un evento del FileSystemWatcher que cuando se crea un nuevo archivo ejecuta su funcionamiento
#>
function global:Start-Demonio {
    $ErrorActionPreference = "Stop"
    $ArchivosViejos = ""
    $RegexArchivosInvalidos = "[A-Za-z]+-[0-9]+(\.log)"
    $proveedores = @{ }
    $ArchivosValidos = Get-ChildItem -Path $Directorio | Where-Object -FilterScript { $_.Name -match $RegexArchivosInvalidos }
    if ($ArchivosViejos -eq $ArchivosValidos) {
        continue;
    }
    $ArchivosViejos = $ArchivosValidos
    foreach ($file in $ArchivosValidos) {
        $proveedorName = $file.Name.Split("-")[0]
        if ($proveedores[$proveedorName] -eq 1) {
            continue;
        }
        $ArchivosMismoNombre = $ArchivosValidos | Where-Object -FilterScript { $_.Name -match "^$proveedorName" }
        $numeroSemanaMaximo = 0;
        foreach ($candidato in $ArchivosMismoNombre | Sort-Object -Property "Name" -Descending) {
            $numeroSemana = [int]$candidato.Name.Split("-")[1].Split(".")[0]
            if ($numeroSemana -ge $numeroSemanaMaximo) {
                $numeroSemanaMaximo = $numeroSemana
                if ($numeroSemanaMaximo -ne 0) {
                    $ArchivosABorrar = $ArchivosMismoNombre | Where-Object { [int]$_.Name.Split("-")[1].Split(".")[0] -lt $numeroSemanaMaximo }
                    foreach ($archivo in $ArchivosABorrar) {
                        Remove-Item $archivo
                    }
                }
            }
        }
        $proveedores[$proveedorName]++;
    }
}
$FileSystemWatcher = New-Object System.IO.FileSystemWatcher
$FileSystemWatcher.Path = Join-Path -Path $PWD.Path -ChildPath $Directorio
$FileSystemWatcher.EnableRaisingEvents = $true

$Action = { global:Start-Demonio }
Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Created -Action $Action