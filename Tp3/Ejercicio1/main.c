#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct nodo{
int nro;
int id_padre;
int id_hijo;

};

void ayuda();
void error();
void mostrar_info(int ,pid_t, pid_t);
//[]
struct nodo identificadores[7];


int main()
{

    int pos=0;

    printf("%d(%d) \n ",0,getpid());
    mostrar_info(pos,getpid(), getppid());
    //Armo el primer arbol del enunciado

    pid_t h1 = fork();

    if(h1==0)
    {
        printf("%d(%d) \n ",1,getpid());
        pos=1;
        mostrar_info(pos,getpid(),getppid());
    }

    pid_t h2 = fork();

    if (h2 == 0)
    {
        /*struct nodo;
        nodo.id_hijo = getpid();
        nodo.id_padre= getppid();
        nodo.nro     = 2;*/
        printf("%d(%d) \n ",2,getpid());

            pos=2;
            mostrar_info(pos,getpid(), getppid());
            pid_t n4 = fork();
            pid_t n5 = fork();

            //Errores de los nietos
            if(n4==0)
            {

                printf("%d(%d) \n ",4,getpid());
                pos=4;
                mostrar_info(pos,getpid(), getppid());
                pid_t bn7 = fork();

                if(bn7==0)
                {
                    printf("%d(%d) \n ",7,getpid());
                    pos=7;
                    mostrar_info(pos,getpid(), getppid());
                }
            }
            else
            if(n5==0)
            {
                printf("%d(%d) \n ",5,getpid());
                pos=5;
                mostrar_info(pos,getpid(), getppid());
            }

    }
    else //Hijo 3
    {
        pid_t h3 = fork();
        if (h3==0)
        {
            pos=3;
            mostrar_info(pos,getpid(), getppid());
            pid_t n6 = fork();
            if(n6==0)
            {
                pos=6;
                mostrar_info(6,getpid(), getppid());
            }
        }
    }

    //for(int i=0;i<sizeof(identificadores);i++){
    //printf("%01d \n ",i);
    //}
    //printf("%01d",sizeof(identificadores));
}


void ayuda()
{

}

void error()
{
    printf("Error de creacion de proceso\n");
}


void mostrar_info(int nro, int pid, int ppid)
{
    struct nodo n;
    n.id_padre = ppid;
    n.id_hijo = pid;

    identificadores[nro] = n;
   // printf("%01d padre: %04d - hijo: %04d \n ",nro, identificadores[nro].id_padre,identificadores[nro].id_hijo);
}

