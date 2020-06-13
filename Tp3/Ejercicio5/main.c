#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include<unistd.h>
#include <pthread.h> // Requiere link con lpthread

#define PORT 8080



void *connection_handler(void*);
void cargar_listado(FILE**, char*);
void log(size_t, void*, char*);

pthread_muted_t log_lock;

int main() {
  int max_clientes = 30;
  int server_socket = 0;
  int client_socket = 0;

  FILE* listado;
  cargar_listado(&listado, "./listado");

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
  }

  listen(server_socket, 3);
  printf("El servidor esta escuchando en el puerto %d\n", PORT);

  pthread_t thread_id;
  int client_len = sizeof(client_addr);

  while ((client_socket = accept(server_socket, (struct sockaddr *) &client_addr, &client_len))) {
    printf("Conneccion aceptada");
    // TODO(Tomas): Crear un log con la conexion e irlo actualizando con los mensajes recibidos.

    // Creo un hilo por cada conexion al servidor.
    if (pthread_create(&thread_id, NULL, connection_handler, (void*)&client_socket) < 0) {
      perror("No se pudo crear el thread.");
      exit(1);
    }

    pthread_join(thread_id, NULL);
  }

  if (client_socket < 0) {
    perror("Fallo al aceptar la conexion con el cliente");
    exit(2);
  }

  return 0;
}

void log(size_t type, void* sock_addr, char* message) {
  pthread_mutex_lock(&lock);
    // Region critica.
    // Se va a abrir el archivo de log y se tiene que
    // agregar el evento que ocurrio.
    // TYPE 0: NUEVA CONEXION
    // TYPE 1: NUEVO MENSAJE ENVIADO A CLIENTE
    // TYPE 2: NUEVO MENSAJE RECIBIDO DE CLIENTE
    // TYPE 3: DESCONEXION DE CLIENTE.
  pthread_muted_unlock(&lock);
  return NULL;
}

void cargar_listado(FILE** archivo, char* path) {
  // Se abre el archivo del listado de usuarios
  // en modo lectura ya que solo se necesita comparar
  // los valores de usuarios y contraseñas y saber 
  // el rol del usuario.
  *archivo = fopen(path, "r");

  if (*archivo == 0) {
    perror("Error al abrir el archivo del listado");
    exit(3);
  }
}

void *connection_handler(void *socket_desc) {
  int socket = *(int*)socket_desc;
  int read_size;
  char *message, client_message[1025];

  message = "Bienvenido a la plataforma de la Universidad Nacional de La Matanza\nIngrese nombre de usuario y contraseña como <nombre_de_usuario>:<contraseña>";
  write(socket, message, strlen(message));

  while ((read_size = recv(socket, client_message, 1025, 0)) > 0) {
    client_message[read_size] = '\0';

    memset(client_message, 0, 1025);
  }

  if (read_size == 0) {
    printf("Cliente desconectado");
    fflush(stdout);
  } else if (read_size == -1) {
    perror("Fallo al recibir informacion (recv failed)");
  }

  return 0;
}