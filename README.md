# Microservice BP
Es un microservicio desarrollado en Golang que expone un EndPoint /DevOps, que solo responde cuando se le pasa determinados datos via POST
y con unas cabeceras especificas, caso contrario solo devolvera acceso prohibido.
El presente esta divido en dos partes:
* La carpeta IAC que contiene codigo HCL para desplegar en Amazon dos instancias t2.micro con sus respectivas 
conecciones de red detras de un balanceador de carga.
* La carpeta APP que contiene el codigo en Golang, que compila el microservicio, crea una imagen docker con el mismo y lo despliega
a las dos instancias previamente creadas por el codigo IAC. Las IPs de cada instancia para la conexion SSH se obtienen dinamicamente a traves
de el command line Amazon.
* La carpeta K8s contiene el codigo base para realizar un despliegue en Kubernetes, esta parte no esta conluida, por cuestiones de tiempo.

## IAC
Pasos a seguir para que funciones el despliegue del IAC:
* Crear un par de claves SSH publica y privada.
* Editar el valor por defecto de la variable ssh_key en iac/variables.tf, colocando la clave publica generada anteriormente como valor por defecto de la mencionada variable.
Esta sera la clave publica que se agregara a las instancias EC2.
* El repositorio github debe contener tambien la clave publica generado en el paso uno, para poder realizar los TAGS.
* Agregar en el Jenkins la clave privada generada en el paso uno, con el ID microservice_bp_private_key.
* Agregar al Jenkins las AWS Credentials con los permisos adecuados con el ID aws_credential.
* Se debe crear en AWS S3 un bucket con el nombre que desee para almacenar el estado del IAC, el nombre del bucket debe ser editado en la variable bucket_name en iac/variables.tf

Luego de realizar los pasos anteriores solo queda desplegar el Jenkinsfile.

## APP
Ademas de los pasos anteriores se deben ejecutar los siguientes:
* Anadir al Jenkins las credenciales para acceder al docker hub con el ID docker-hub-registry.
* Adicional se debe ejecutar primeramente el pipeline de IAC, para que las instancias esten listas cuando se realize el despliegue del microservicio, es decir, este pipeline 
no falla, solo que no habra instancias a donde desplegar el microservicio.

## Jenkins
El jenkins debe estar corriendo sobre una maquina que ejecute docker para que los pipelines funcionen correctamente.
Adicionalmente a los plugins que se instalan por defecto en Jenkins, debera obtener el plugin para agregar AWS credentials.


## K8s
Esta carpeta contiene :
* Deployment
* Configmap
* Secret
* Service
Tanto para demo y produccion, para este momento solo a manera de ejemplo.
