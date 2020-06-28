#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <dirent.h> // For listing files in the folder
#include <unistd.h>
#include <pthread.h> // Requiere link con lpthread
#include <signal.h>

#define PORT 8001

#define CLIENT_CONNECTED 0
#define CLIENT_MESSAGE 1
#define SERVER_MESSAGE 2
#define CLIENT_DISCONNECTION 3

struct User {
  char role;
  char name[30];
  int comision;
};

void *connection_handler(void*);
void cargar_archivo(FILE**, char*, char*);
void server_log(size_t, int, char*);
void login(char*, char*, struct User**);
int check_for_file(char*);
void SIGN_HANDLER(int);
void cargar_asistencia(char*, char*);
int asistio(char*, char*);
int calcular_porcentaje_asistencia(char*, int);

pthread_mutex_t log_lock;
// Cuando accedemos a archivos lockeamos
// en caso de que otro usuario pueda querer
// acceder a un archivo en el mismo momento.
// Hacemos que el que haya pedido algo con un archivo
// espere a que el otro finalice de leer/escribir a un archivo.
pthread_mutex_t acceso_a_archivo;
pthread_mutex_t asistencia_mutex;

FILE* log_file;
FILE* listado;


int main(int argc, char** argv) {
  if (argc == 2 && (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0)) {
    printf("BIENVENIDO AL SISTEMA DE LA UNIVERSIDAD NACIONAL DE LA MATANZA:\nComo cliente debera conectarse y loguearse.\nSi entra como Docente podra colocar una fecha y recibir el listado de presencia de ese dia, o cargarlo siguiendo las instrucciones\nComo alumno podra preguntar si estuvo presente o ausente en un dia, o mandar 'Asistencia' para conseguir su porcentaje de asistencia actual");
    fflush(stdout);
    return 0;
  }

  int max_clientes = 50;
  int clientes = 0;
  int contador = 0;
  pthread_t hilos_cliente[max_clientes];
  int server_socket = 0;
  int client_socket = 0;

  cargar_archivo(&listado, "./listado", NULL);
  cargar_archivo(&log_file, "./server.log", "a+");

  signal(SIGINT, SIGN_HANDLER);

  struct sockaddr_in server_addr, client_addr;

  if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
    perror("Fallo el socket principal!");
    exit(EXIT_FAILURE);
  }

  // Seteando el tipo de socket
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = INADDR_ANY;
  server_addr.sin_port = htons(PORT);

  // Bindeo del socket
  if (bind(server_socket, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
    perror("Error al bindear el puerto en el socket");
    exit(0);
  }

  listen(server_socket, 40);

  printf("SERVIDOR ARRANCADO EN PUERTO %d \n", PORT);
  fflush(stdout);

  socklen_t client_len = sizeof(client_addr);

  while ((client_socket = accept(server_socket, (struct sockaddr *) &client_addr, &client_len))) {
    if (pthread_create(&hilos_cliente[contador++], NULL, connection_handler, (void*)&client_socket) < 0) {
      perror("No se pudo crear el thread.");
      exit(1);
    }
  }

  for (int i = 0; i < contador; ++i) {
    pthread_join(hilos_cliente[i], NULL);
  }

  if (client_socket < 0) {
    perror("Fallo al aceptar la conexion con el cliente");
    exit(2);
  }

  fclose(listado);
  fclose(log_file);

  return 0;
}

void SIGN_HANDLER(int sig) {
  fclose(listado);
  fclose(log_file);
  exit(0);
}

void server_log(size_t type, int socket, char* message) {
  pthread_mutex_lock(&log_lock);
    char log_header[1024];
    switch(type) {
      case CLIENT_CONNECTED:
        sprintf(log_header, "[NUEVO CLIENTE]: SOCKET %d", socket);
        break;
      case CLIENT_MESSAGE:
        sprintf(log_header, "[MENSAJE DE CLIENTE (SOCKET: %d)]", socket);
        break;
      case SERVER_MESSAGE:
        strcpy(log_header, "[MENSAJE DE SERVIDOR]: ");
        break;
      case CLIENT_DISCONNECTION:
        sprintf(log_header, "[CLIENTE DESCONECTADO]: SOCKET %d", socket);
        break;
    }

    if (message == NULL) {
      fprintf(log_file, "%s\n", log_header);
    } else {
      fprintf(log_file, "%s %s\n", log_header, message);
    }
  pthread_mutex_unlock(&log_lock);
}

void cargar_archivo(FILE** archivo, char* path, char* flag) {
  if (flag == NULL) {
    flag = "r";
  }
  *archivo = fopen(path, flag);

  if (*archivo == 0) {
    perror("Error al abrir archivos de listado o log.");
    exit(3);
  }
}

void *connection_handler(void *socket_desc) {
  int socket = *(int*)socket_desc;
  int read_size;

  int cargando_asistencia = 0;
  char archivo_asistencia[20];

  struct User *user;
  char *message, client_message[1025];

  message = (char*)(malloc(1025));

  server_log(CLIENT_CONNECTED, socket, NULL);

  strcpy(message, "Bienvenido a la plataforma de la Universidad Nacional de La Matanza\nIngrese nombre de usuario y contraseña como <nombre_de_usuario>:<contraseña>\nINGRESE: ");
  write(socket, message, strlen(message));
  server_log(SERVER_MESSAGE, 0, message);

  while ((read_size = recv(socket, client_message, 1025, 0)) > 0) {
    client_message[read_size] = '\0';
    char *newline = strchr(client_message, '\n' );
    if ( newline )
      *newline = 0;
    server_log(CLIENT_MESSAGE, socket, client_message);
    
    if (user == NULL) {
      char* username;
      char* password;
      username = strtok(client_message, ":");
      password = strtok(NULL, ":");
      
      login(username, password, &user);
      if (user != NULL) {
        sprintf(message, "\nBIENVENIDO %s | ROLE: %c | COMISION: %d\n", user->name, user->role, user->comision);
        write(socket, message, strlen(message));
        server_log(SERVER_MESSAGE, 0, message);
      } else {
        strcpy(message, "\nNo se encontro usuario con esa combinacion de USUARIO:CONTRASEÑA\nINGRESE NUEVAMENTE: ");
        write(socket, message, strlen(message));
        server_log(SERVER_MESSAGE, 0, message);
      }
    } else {
      if (user->role == 'D') {
        if (cargando_asistencia == 1) {
          if (strcmp(client_message, "FIN") == 0) {
            strcpy(message, "\nFINALIZO EL PROCESO DE CARGA. SE HA GUARDADO EL ARCHIVO\n");
            write(socket, message, strlen(message));
            server_log(SERVER_MESSAGE, 0, message);
            cargando_asistencia = 0;
          } else {
            cargar_asistencia(archivo_asistencia, client_message);
            strcpy(message, "INGRESE NOMBRE|PRESENCIA: ");
            write(socket, message, strlen(message));
            server_log(SERVER_MESSAGE, 0, message);
          }
        } else {
          sprintf(archivo_asistencia, "Asistencia_%s_%d.txt", client_message, user->comision);

          if (check_for_file(archivo_asistencia) == 1) {
            char *file_name = (char*)(malloc(50));
            sprintf(file_name, "./Asistencia/%s", archivo_asistencia);

            strcpy(message, "\nNOMBRE|PRESENTE\n");
            write(socket, message, strlen(message));
            server_log(SERVER_MESSAGE, 0, message);

            char* line;
            ssize_t read;
            ssize_t len = 0;
            pthread_mutex_lock(&acceso_a_archivo);
            FILE *f = fopen(file_name, "r");
            while((read = getline(&line, &len, f) != -1)) {
              sprintf(message, "%s", line);
              write(socket, message, strlen(message));
              server_log(SERVER_MESSAGE, 0, message);
            }
            fclose(f);
            pthread_mutex_unlock(&acceso_a_archivo);
            free(line);
            free(file_name);
          } else {
            strcpy(message, "No hay un archivo cargado para esa fecha\nIngrese el presentismo del alumno enviando ALUMNO|PRESENCIA (ROBERTO|P por ejemplo) y cuando termine envie FIN\nINGRESE NOMBRE|PRESENCIA: ");
            write(socket, message, strlen(message));
            server_log(SERVER_MESSAGE, 0, message);
            cargando_asistencia = 1;
          }
        }
        // El docente podra ingresar una fecha (yyyy-mm-dd) y se debera
        // ver si existe el archivo de asistencias (Asistencias_[FECHA]_[COMISION]) para ese
        // dia para mostrarlo.
        // Si no existe se debera promptear para que ingrese
        // Mostrandole previamente cuales son los Alumnos que tiene asignados
        // en su comision y debera llenar el listado hasta que mande un 'FIN' y se guardara el archivo.
      } else {
        // El alumno podra ingresar una fecha y recibir si
        // estuvo presente ese dia enviando una fecha como 'yyyy-mm-dd'
        // y buscarlo en un archivo Asistencias_[FECHA]_[COMISION]
        // y si envia 'ASISTENCIA' se debera recorrer todos los
        // archivos que tengan Asistencias_CUALQUIERCOSA_[COMISION]
        // e ir viendo si tienen el nombre del alumno y su estado (A o P)
        // y en base al total de Ausentes y Presentes mostrar el porcentaje
        // de asistencia por el momento.$
        if (strcmp(client_message, "ASISTENCIA") == 0) {
          int porcentaje_asistencia = calcular_porcentaje_asistencia(user->name, user->comision);
          sprintf(message, "El usuario %s de la comision %d tiene un porcentaje de asistencia del %d%%\n", user->name, user->comision, porcentaje_asistencia);
          write(socket, message, strlen(message));
          server_log(SERVER_MESSAGE, 0, message);
        } else {
          sprintf(archivo_asistencia, "Asistencia_%s_%d.txt", client_message, user->comision);
          
          if (check_for_file(archivo_asistencia) == 1) {
            if (asistio(archivo_asistencia, user->name) == 1) {
              sprintf(message, "El dia de la fecha %s el alumno %s ASISTIO a la clase de la comision %d\n", client_message, user->name, user->comision);
              write(socket, message, strlen(message));
              server_log(SERVER_MESSAGE, 0, message);
            } else {
              sprintf(message, "El dia de la fecha %s el alumno %s SE AUSENTO a la clase de la comision %d\n", client_message, user->name, user->comision);
              write(socket, message, strlen(message));
              server_log(SERVER_MESSAGE, 0, message);
            }
          } else {
            sprintf(message, "No se encontro archivo de asistencias para la fecha %s y la comision %d\n", client_message, user->comision);
            write(socket, message, strlen(message));
            server_log(SERVER_MESSAGE, 0, message);
          }
        }
      }
    }

    memset(client_message, 0, 1025);
  }

  if (read_size == 0) {
    server_log(CLIENT_DISCONNECTION, socket, NULL);
    pthread_exit(NULL);
  } else if (read_size == -1) {
    perror("Fallo al recibir informacion (recv failed)");
  }

  return 0;
}

void login(char* username, char* password, struct User **user) {
  size_t buffer_size = 255;
  char line_buffer[buffer_size];


  fseek(listado, 0, SEEK_SET);

  while (fgets(line_buffer, buffer_size, listado)) {
    char* usr = strtok(line_buffer, "|");
    char* pwd = strtok(NULL, "|");
    char* role = strtok(NULL, "|");
    char* com = strtok(NULL, "|");

    if ((strcmp(username, usr) == 0) && (strcmp(password, pwd) == 0)) {
      *user = (struct User*)(malloc(sizeof **user));
      strcpy((*user)->name, usr);
      (*user)->role = *role;
      (*user)->comision = atoi(com);
      return;
    }
  }

  return;
}

int check_for_file(char* file_name) {
  DIR *d;
  struct dirent *dir;

  pthread_mutex_lock(&acceso_a_archivo);
  d = opendir("./Asistencia");
  if (d) {
    while ((dir = readdir(d)) != NULL) {
      if (strcmp(file_name, dir->d_name) == 0) {
        closedir(d);
        pthread_mutex_unlock(&acceso_a_archivo);
        return 1;
      } 
    }
    closedir(d);
    pthread_mutex_unlock(&acceso_a_archivo);
  }
  return 0;
}

void cargar_asistencia(char *archivo, char *contenido) {
  char* path;
  sprintf(path, "./Asistencia/%s", archivo);
  pthread_mutex_lock(&acceso_a_archivo);
  FILE *f = fopen(path, "a+");
  fprintf(f, "%s\n", contenido);
  fclose(f);
  pthread_mutex_unlock(&acceso_a_archivo);
}

int asistio(char* archivo, char* user) {
  size_t buffer_size = 255;
  char line_buffer[buffer_size];
  char* file_path = (char*)(malloc(100));

  sprintf(file_path, "./Asistencia/%s", archivo);

  pthread_mutex_lock(&acceso_a_archivo);
  FILE* f = fopen(file_path, "r");
  fseek(f, 0, SEEK_SET);
  free(file_path);

  while (fgets(line_buffer, buffer_size, f)) {
    char* usr = strtok(line_buffer, "|");
    char* asistencia = strtok(NULL, "|");
    char *newline = strchr(asistencia, '\n' );
    if ( newline )
      *newline = 0;


    if ((strcmp(user, usr) == 0) && (strcmp(asistencia, "P") == 0)) {
      pthread_mutex_unlock(&acceso_a_archivo);
      return 1;
    }
  }
  fclose(f);
  pthread_mutex_unlock(&acceso_a_archivo);
  return 0;
}

int calcular_porcentaje_asistencia(char* usuario, int comision) {
  DIR *d;
  struct dirent *dir;

  int cantidad_dias = 0;
  int cantidad_presentes = 0;

  pthread_mutex_lock(&asistencia_mutex);
  d = opendir("./Asistencia");
  if (d) {
    while ((dir = readdir(d)) != NULL) {
      char* _ = strtok(dir->d_name, "_");
      char* fecha = strtok(NULL, "_");
      char* comisionConExtension = strtok(NULL, "_");
      char* com = strtok(comisionConExtension, ".");

      if (!comisionConExtension) {
        continue;
      }
      int comisionArchivo = atoi(comisionConExtension);

      if (comision == comisionArchivo) {
        cantidad_dias++;
        char* nombre_archivo = (char*)(malloc(50));
        sprintf(nombre_archivo, "Asistencia_%s_%d.txt", fecha, comisionArchivo);
        if (asistio(nombre_archivo, usuario) == 1) {
          cantidad_presentes++;
        }
        free(nombre_archivo);
      } 
    }
    closedir(d);
    pthread_mutex_unlock(&asistencia_mutex);
  }
  
  return cantidad_presentes * 100 / cantidad_dias;
}