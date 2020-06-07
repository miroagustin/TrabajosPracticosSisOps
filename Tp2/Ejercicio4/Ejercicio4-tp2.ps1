<#
.SYNOPSIS
Comprime los archivos logs antes de borrarlos para resolver problemas de almacenamiento.

.DESCRIPTION
Dado una carpeta de logs, se genera un comprimido de estos antes de eliminarlos. Este .zip se almacenara en la carpeta indicada como parametro.

.EXAMPLE
./Ejercicio4-tp2.ps1 -Directorio [ruta de carpeta de logs] -DirectorioZip [ruta de la carpeta contenedora de zips] -Empresa [Nombre de la empresa a zipear]

.EXAMPLE
./Ejercicio4-tp2.ps1 -Directorio [ruta de carpeta de logs] -DirectorioZip [ruta de la carpeta contenedora de zips]

.INPUTS
Directorio: Directorio en el que se encuentran los archivos de log. 
DirectorioZip:  Directorio en el que se generarán los archivos comprimidos de los clientes.
Empresa (opcional): Nombre de la empresa a procesar.
#>
#------------------------------------FIN GET-HELP ----------------------------------------------------------------------------------------
[CmdLetBinding()]
Param(
    [Parameter(Position=0, 
               Mandatory=$true,
               HelpMessage = "Ingrese la ruta de una carpeta valida")]
               [ValidateScript({Test-Path $_})]
               [ValidateNotNullorEmpty()]
    [string]$Directorio,

    [Parameter(Position=1, 
               Mandatory=$true,
               HelpMessage = "Ingrese la ruta de una carpeta valida")]
               [ValidateScript({Test-Path $_})]
               [ValidateNotNullorEmpty()]
    [string]$DirectorioZip,

    [Parameter(Position=2, 
               Mandatory=$false,
               HelpMessage = "Ingrese el nombre de una empresa valido")]
    [string]$Empresa
)

function Zipear-Empresa {
    [CmdLetBinding()]
    Param(
    [Parameter(Position=0, 
               Mandatory=$true)]
    [string]$Directorio,

    [Parameter(Position=1, 
               Mandatory=$true)]
    [string]$DirectorioZip,

    [Parameter(Position=2, 
               Mandatory=$true)]
    [string]$Empresa
    )

    if($Directorio[$Directorio.Length - 1] -eq "\") {
        $Directorio = $Directorio.Substring(0, $Directorio.LastIndexOf("\"))
    }
    if($DirectorioZip[$DirectorioZip.Length - 1] -eq "\") {
        $DirectorioZip = $DirectorioZip.Substring(0, $DirectorioZip.LastIndexOf("\"))
    }
    
    $bandera=0
    New-Item -Path "." -Name $Empresa -ItemType "directory"  -Force | Out-Null
    Get-ChildItem $Directorio -Name | ForEach-Object -Process {
        if ($_ -match '^[A-Za-z]+-[0-9]+\.log$') {
            $NombreLeido = $_.Substring(0,$_.indexOf("-"))
            $inicio = $_.indexOf("-")+1
            $fin = $_.indexOf(".")
            $nroActual = $_.Substring($inicio, $fin - $inicio) -as [int]
            if($NombreLeido -eq $Empresa) {
                if($bandera -eq 0){
                    $semanaMayor=$nroActual
                    $nombreSemanaMayor=$_
                    $bandera=1
                } else {
                    if ($nroActual -gt $semanaMayor) {
                            Move-Item -Path "$Directorio/$nombreSemanaMayor" -Destination $Empresa
                            $semanaMayor=$nroActual  
                            $nombreSemanaMayor=$_
                        } else {
                            Move-Item -Path "$Directorio/$_" -Destination $Empresa
                        }  
                    }
            }
        }
    }
    if((Get-ChildItem $Empresa | Measure-Object).Count -ne 0) {
        Compress-Archive -Path $Empresa -Destination "$DirectorioZip/$Empresa.zip" -Update
        Write-Host "Se ha creado el zip correspondiente a la empresa: "$Empresa
    } else {
        Write-Host "No hay archivos para comprimir de la empresa: "$Empresa
    }
        
    Remove-Item -Path $Empresa -Recurse
} 

$NombreEmpresas = @()
$PrimerNombreDistinto = ""

Get-ChildItem $Directorio -Name | ForEach-Object -Process {
    if ($_ -match '^[A-Za-z]+-[0-9]+\.log$') {
        $NombreLeido = $_.Substring(0,$_.indexOf("-"))
        if($NombreLeido -ne $PrimerNombreDistinto) {
            $PrimerNombreDistinto = $NombreLeido
            $NombreEmpresas += $PrimerNombreDistinto
        }
    }
} 

 if($Empresa){
        ForEach-Object -Process {
            if($_ -eq $Empresa) {
                Zipear-Empresa -Directorio $Directorio -DirectorioZip $DirectorioZip -Empresa $Empresa
                exit
            }
        }  -InputObject $NombreEmpresas
        Write-Host "No se encontro la empresa indicada."
} else {
        foreach ($NombreEmpresa in $NombreEmpresas) {
            Zipear-Empresa -Directorio $Directorio -DirectorioZip $DirectorioZip -Empresa $NombreEmpresa
        }    
 }



