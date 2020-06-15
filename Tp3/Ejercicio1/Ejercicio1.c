#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ARRAY_SIZE   7
#define MALLOC_SIZE 10000


struct nodo
{
    int nro;
    int id_padre;
    int id_hijo;
};

//[]
void ayuda();
void error();
void guardar_info(int ,pid_t);
int crear_procesos(int n);
void mostrar_info();

struct nodo identificadores[ARRAY_SIZE];  /*datos sin inicializar*/
//struct nodo *identificadores = malloc(7 * sizeof(struct nodo));

void main(int argc, char *argv[])
{
    int n=0;
    printf("Introduce un numero entero: \n");
    scanf("%d",&n);

    crear_procesos(n);
}

int crear_procesos(int n)
{

    guardar_info(0,getpid());
    mostrar_info();

    pid_t h1 = fork();
    if(h1==0)
    {
        guardar_info(1,getpid());
        mostrar_info();
        exit(0);
    }
    else if(h1>1)
    {
        pid_t h2 = fork();

        if (h2 == 0)
        {
            guardar_info(2,getpid());
            mostrar_info();

            pid_t n4 = fork();
            if(n4==0)
            {
                guardar_info(4,getpid());
                mostrar_info();


                pid_t bn7 = fork();
                if(bn7==0)
                {
                    guardar_info(7,getpid());
                    mostrar_info();

                    for(int i=1;i<=n;i++)
                    {
                        pid_t numero = fork();
                        if(numero>0) // Si es el padre no hace nada sale
                        {
                            break;
                        }
                        else
                        {
                            guardar_info(7+i,getpid());
                            mostrar_info();
                        }
                        
                    }    
                    
                    exit(0);
                }                
                
            }else if(n4>0)
            {
                
                pid_t n5 = fork();
                if(n5==0)
                {
                    guardar_info(5,getpid());
                    mostrar_info();
                    exit(0);
                }
            exit(0);
            }
        exit(0);
        }
        else //Hijo 3
        {
            pid_t h3 = fork();
            if (h3==0)
            {
                guardar_info(3,getpid());
                mostrar_info();
                
                pid_t n6 = fork();
                if(n6==0)
                {
                    guardar_info(6,getpid());
                    mostrar_info();
                    exit(0);
                }
                exit(0);
            }
        exit(0);
        }
            
    exit(0);
    }
}

void guardar_info(int nro, int pid)
{
    struct nodo n;
    n.id_padre = pid;
    n.nro = nro;

    identificadores[nro] = n;
}

void mostrar_info()
{
    for(int i=sizeof(identificadores);i>=0;i--)
    {
        if(identificadores[i].id_padre!=0){
        printf("%01d(%04d) - ", identificadores[i].nro,identificadores[i].id_padre);
    }
    }
        
    printf("\n");
}
    

void ayuda()
{

}

void error()
{
    printf("Error de creacion de proceso\n");
}

