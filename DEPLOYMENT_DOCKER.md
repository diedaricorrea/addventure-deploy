# 🐳 Deployment con Docker - AddVenture

## 🎯 Ventajas de usar Docker

✅ **Setup en 5 minutos** - Un solo comando levanta todo  
✅ **Consistencia total** - Funciona igual en desarrollo, staging y producción  
✅ **Fácil rollback** - Volver a versión anterior en segundos  
✅ **Escalabilidad** - Fácil agregar más instancias  
✅ **Aislamiento** - Cada servicio en su propio contenedor  
✅ **Portable** - Funciona en cualquier servidor con Docker

---

## 📋 Requisitos Previos

- Docker instalado ([Download Docker Desktop](https://www.docker.com/products/docker-desktop))
- Docker Compose instalado (incluido en Docker Desktop)
- Git instalado
- Cuenta AWS (para EC2) o servidor con Ubuntu

---

## 🚀 OPCIÓN 1: Deployment Local (Testing)

### 1. Preparar Variables de Entorno

```powershell
# En la carpeta raíz del proyecto
cd C:\Users\Diedari\Documents\DesarrolloWebIntegrado

# Copiar archivo de ejemplo
copy .env.example .env

# Editar .env con tus valores
notepad .env
```

**Contenido de `.env` para desarrollo local:**
```bash
MYSQL_ROOT_PASSWORD=rootpassword123
DB_USERNAME=addventure_user
DB_PASSWORD=userpassword123
JWT_SECRET=tu-clave-jwt-generada-con-el-script-minimo-64-caracteres
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password
CORS_ALLOWED_ORIGINS=http://localhost,http://localhost:4200
WEBSOCKET_ALLOWED_ORIGINS=http://localhost,http://localhost:4200
```

### 2. Generar JWT Secret

```powershell
.\generate-jwt-secret.ps1
# Copiar el resultado al .env
```

### 3. Actualizar Frontend para Desarrollo

```powershell
# Editar environment.prod.ts
cd addventure-fronted
notepad src/environments/environment.prod.ts
```

Cambiar a:
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://localhost:8080/api',
  wsUrl: 'http://localhost:8080/ws',
  baseUrl: 'http://localhost:8080'
};
```

### 4. Levantar Aplicación

```powershell
# Volver a la raíz
cd ..

# Construir y levantar todos los servicios
docker-compose up --build -d

# Ver logs en tiempo real
docker-compose logs -f

# Solo ver logs del backend
docker-compose logs -f backend
```

### 5. Verificar que Todo Funcione

```powershell
# Ver estado de contenedores
docker-compose ps
```

Deberías ver 3 contenedores corriendo:
- `addventure-mysql` (puerto 3306)
- `addventure-backend` (puerto 8080)
- `addventure-frontend` (puerto 80)

**Abrir navegador:**
- Frontend: http://localhost
- Backend API: http://localhost:8080/api/home/data

### 6. Comandos Útiles

```powershell
# Detener todos los servicios
docker-compose down

# Detener y ELIMINAR volúmenes (⚠️ borra la base de datos)
docker-compose down -v

# Reiniciar un servicio específico
docker-compose restart backend

# Ver logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql

# Reconstruir solo el backend
docker-compose build backend
docker-compose up -d backend

# Ver uso de recursos
docker stats

# Entrar a un contenedor
docker exec -it addventure-backend sh
docker exec -it addventure-mysql bash

# Importar SQL a la base de datos
docker exec -i addventure-mysql mysql -u root -prootpassword123 addventure < backup.sql
```

---

## 🌐 OPCIÓN 2: Deployment en AWS EC2 con Docker

### Paso 1: Crear Instancia EC2

**Mismo proceso que antes, pero ahora SOLO necesitas:**
- Ubuntu Server 22.04 LTS
- t2.micro (Free Tier)
- Security Group con puertos: 22 (SSH), 80 (HTTP), 443 (HTTPS)

### Paso 2: Conectar por SSH

```powershell
ssh -i ~/.ssh/addventure-key.pem ubuntu@TU-IP-PUBLICA
```

### Paso 3: Instalar Docker en el Servidor

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar usuario actual al grupo docker
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo apt install -y docker-compose-plugin

# Verificar instalación
docker --version
docker compose version

# Cerrar sesión y volver a entrar para que tome efecto el grupo
exit
```

Volver a conectar:
```powershell
ssh -i ~/.ssh/addventure-key.pem ubuntu@TU-IP-PUBLICA
```

### Paso 4: Clonar el Repositorio

```bash
# Instalar Git
sudo apt install -y git

# Clonar el proyecto (reemplaza con tu repo)
git clone https://github.com/TU-USUARIO/addventure.git
cd addventure

# Si tienes repos separados:
mkdir addventure
cd addventure
git clone https://github.com/TU-USUARIO/addventure-backend.git
git clone https://github.com/TU-USUARIO/addventure-fronted.git
```

### Paso 5: Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar con nano
nano .env
```

**Contenido de `.env` para producción:**
```bash
# Usar contraseñas FUERTES en producción
MYSQL_ROOT_PASSWORD=tu-password-root-muy-segura-cambiar
DB_USERNAME=addventure_user
DB_PASSWORD=tu-password-usuario-muy-segura-cambiar
JWT_SECRET=clave-jwt-super-larga-generada-cambiar
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password
CORS_ALLOWED_ORIGINS=http://TU-IP-PUBLICA
WEBSOCKET_ALLOWED_ORIGINS=http://TU-IP-PUBLICA
```

Guardar: `Ctrl+O`, Enter, `Ctrl+X`

### Paso 6: Actualizar Frontend para Producción

```bash
nano addventure-fronted/src/environments/environment.prod.ts
```

Cambiar a (reemplaza TU-IP-PUBLICA):
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://TU-IP-PUBLICA:8080/api',
  wsUrl: 'http://TU-IP-PUBLICA:8080/ws',
  baseUrl: 'http://TU-IP-PUBLICA:8080'
};
```

### Paso 7: Levantar Aplicación

```bash
# Construir y levantar (tarda 5-10 minutos la primera vez)
docker compose up --build -d

# Ver logs en tiempo real
docker compose logs -f
```

Espera a que veas:
```
addventure-backend  | Started VentureApplication in X seconds
```

### Paso 8: Verificar

```bash
# Ver estado
docker compose ps

# Probar backend
curl http://localhost:8080/api/home/data
```

**En tu navegador:**
```
http://TU-IP-PUBLICA
```

---

## 🔄 Actualizar la Aplicación

### En Desarrollo Local:
```powershell
# Hacer cambios en el código
# Luego:
docker-compose build backend  # o frontend
docker-compose up -d backend
```

### En Producción (EC2):
```bash
# Conectar por SSH
ssh -i ~/.ssh/addventure-key.pem ubuntu@TU-IP-PUBLICA

cd addventure

# Pull de cambios
cd addventure-backend && git pull && cd ..
cd addventure-fronted && git pull && cd ..

# Reconstruir y reiniciar
docker compose build
docker compose up -d

# Ver logs para verificar
docker compose logs -f backend
```

---

## 📊 Gestión de Base de Datos

### Backup

```bash
# Crear backup de la base de datos
docker exec addventure-mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} addventure > backup_$(date +%Y%m%d).sql

# Listar backups
ls -lh backup_*.sql
```

### Restore

```bash
# Restaurar desde backup
docker exec -i addventure-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} addventure < backup_20250127.sql
```

### Importar Estructura Inicial

```bash
# Si tienes un archivo SQL de estructura
docker exec -i addventure-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} addventure < database-structure.sql
```

### Acceder a MySQL

```bash
# Entrar al contenedor de MySQL
docker exec -it addventure-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD}

# O directamente a la base de datos
docker exec -it addventure-mysql mysql -u addventure_user -p${DB_PASSWORD} addventure
```

---

## 🔍 Monitoreo y Logs

### Ver Logs

```bash
# Todos los servicios
docker compose logs -f

# Solo backend
docker compose logs -f backend

# Últimas 100 líneas
docker compose logs --tail=100 backend

# Desde las últimas 2 horas
docker compose logs --since 2h backend
```

### Ver Recursos

```bash
# Uso de CPU, memoria, red
docker stats

# Espacio en disco
docker system df

# Listar volúmenes
docker volume ls
```

### Healthcheck

```bash
# Ver salud de los contenedores
docker compose ps

# Inspeccionar salud del backend
docker inspect addventure-backend | grep -A 10 Health
```

---

## 🛠️ Troubleshooting

### Backend no arranca

```bash
# Ver logs detallados
docker compose logs backend

# Ver últimas 50 líneas
docker compose logs --tail=50 backend

# Entrar al contenedor
docker exec -it addventure-backend sh

# Verificar conexión a MySQL
docker exec addventure-backend wget -O- http://mysql:3306
```

### Frontend muestra error 404

```bash
# Reconstruir frontend
docker compose build frontend
docker compose up -d frontend

# Ver logs de Nginx
docker compose logs frontend
```

### MySQL no inicia

```bash
# Ver logs de MySQL
docker compose logs mysql

# Eliminar volumen y empezar de cero (⚠️ PIERDE DATOS)
docker compose down -v
docker compose up -d
```

### Limpiar Docker

```bash
# Eliminar contenedores parados
docker container prune

# Eliminar imágenes no usadas
docker image prune

# Limpieza completa (⚠️ cuidado)
docker system prune -a
```

---

## 🔒 Seguridad

### Variables de Entorno

- ✅ **NUNCA** subir `.env` a Git
- ✅ Usar contraseñas fuertes (20+ caracteres)
- ✅ Cambiar JWT_SECRET en cada ambiente
- ✅ Rotar contraseñas periódicamente

### Nginx

```bash
# Agregar SSL/HTTPS con Let's Encrypt (opcional)
# Instalar certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtener certificado (necesitas un dominio)
sudo certbot --nginx -d tudominio.com
```

---

## 📈 Escalabilidad

### Escalar Backend (múltiples instancias)

```yaml
# Modificar docker-compose.yml
services:
  backend:
    deploy:
      replicas: 3  # 3 instancias del backend
```

### Load Balancer con Nginx

```bash
# Agregar nginx como reverse proxy
# (configuración avanzada, preguntar si lo necesitas)
```

---

## 💰 Costos Aproximados

### AWS EC2 Free Tier (12 meses gratis):
- ✅ t2.micro 24/7
- ✅ 30 GB almacenamiento
- ✅ 15 GB bandwidth/mes

### Después de Free Tier:
- ~$10/mes con t2.micro
- ~$20/mes con t2.small (2 GB RAM, recomendado si crece)

---

## 📝 Checklist de Deployment

- [ ] Docker instalado en servidor
- [ ] Código en GitHub
- [ ] `.env` configurado con valores de producción
- [ ] `environment.prod.ts` actualizado con IP pública
- [ ] Security Group con puertos 22, 80, 443
- [ ] `docker compose up -d` ejecutado
- [ ] Todos los contenedores corriendo (mysql, backend, frontend)
- [ ] Aplicación accesible en http://TU-IP-PUBLICA
- [ ] Registro de usuario funciona
- [ ] Login funciona
- [ ] Upload de imágenes funciona

---

## 🎉 Comandos Esenciales (Cheat Sheet)

```bash
# Levantar todo
docker compose up -d

# Ver logs
docker compose logs -f

# Reiniciar servicio
docker compose restart backend

# Detener todo
docker compose down

# Actualizar código
git pull
docker compose build
docker compose up -d

# Backup DB
docker exec addventure-mysql mysqldump -u root -pPASSWORD addventure > backup.sql

# Restore DB
docker exec -i addventure-mysql mysql -u root -pPASSWORD addventure < backup.sql

# Limpiar
docker system prune
```

---

## ✅ Ventajas vs Deployment Manual

| Aspecto | Manual (sin Docker) | Con Docker |
|---------|---------------------|------------|
| Setup inicial | 2-3 horas | 15 minutos |
| Actualizar app | 20 min | 2 minutos |
| Rollback | Difícil | 1 comando |
| Portabilidad | Solo Ubuntu | Cualquier OS |
| Consistencia | Varía por entorno | 100% igual |
| Dependencias | Manual | Automático |
| Escalabilidad | Complejo | Fácil |

---

¿Prefieres seguir con Docker? Es mucho más simple y profesional. 🐳
