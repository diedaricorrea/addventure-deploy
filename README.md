# 🚀 AddVenture - Deployment con Docker

Orquestación completa de la aplicación AddVenture usando Docker Compose.

## 📦 Repositorios del Proyecto

- **Backend**: https://github.com/diedaricorrea/addventurebackend-deploy
- **Frontend**: https://github.com/diedaricorrea/addventurefronted-deploy
- **Deployment** (este repo): Configuración de Docker Compose

## 🏗️ Arquitectura

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Frontend      │      │    Backend       │      │     MySQL       │
│   Angular 17+   │─────▶│   Spring Boot    │─────▶│      8.0        │
│   Nginx         │      │   Java 21        │      │                 │
│   Puerto 80     │      │   Puerto 8080    │      │   Puerto 3306   │
└─────────────────┘      └──────────────────┘      └─────────────────┘
```

## 🚀 Quick Start - Desarrollo Local

### Requisitos
- Docker Desktop instalado
- Git instalado
- PowerShell (Windows) o Terminal (Mac/Linux)

### Pasos

```powershell
# 1. Clonar este repo
git clone https://github.com/diedaricorrea/addventure-deploy.git
cd addventure-deploy

# 2. Clonar backend y frontend
git clone https://github.com/diedaricorrea/addventurebackend-deploy.git
git clone https://github.com/diedaricorrea/addventurefronted-deploy.git

# 3. Generar JWT Secret
.\generate-jwt-secret.ps1

# 4. Configurar variables de entorno
copy .env.example .env
notepad .env
# Pegar el JWT_SECRET generado y configurar otros valores

# 5. Levantar la aplicación
docker compose up --build -d

# 6. Ver logs
docker compose logs -f

# 7. Abrir navegador
# http://localhost
```

## 🌐 Deployment en AWS EC2

### Paso 1: Crear instancia EC2
- Tipo: t2.micro (Free Tier)
- SO: Ubuntu Server 22.04 LTS
- Security Group: Puertos 22, 80, 443

### Paso 2: Instalar Docker

```bash
# Conectar por SSH
ssh -i ~/.ssh/addventure-key.pem ubuntu@TU-IP-PUBLICA

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Instalar Docker Compose
sudo apt install -y docker-compose-plugin git

# Cerrar sesión y volver a conectar
exit
ssh -i ~/.ssh/addventure-key.pem ubuntu@TU-IP-PUBLICA
```

### Paso 3: Clonar y Configurar

```bash
# Crear estructura
mkdir ~/addventure
cd ~/addventure

# Clonar repos
git clone https://github.com/diedaricorrea/addventure-deploy.git .
git clone https://github.com/diedaricorrea/addventurebackend-deploy.git
git clone https://github.com/diedaricorrea/addventurefronted-deploy.git

# Configurar .env
cp .env.example .env
nano .env
```

**Configurar `.env` con estos valores:**
```bash
MYSQL_ROOT_PASSWORD=tu-password-root-segura
DB_USERNAME=addventure_user
DB_PASSWORD=tu-password-user-segura
JWT_SECRET=tu-jwt-generado-con-el-script
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password
CORS_ALLOWED_ORIGINS=http://TU-IP-PUBLICA
WEBSOCKET_ALLOWED_ORIGINS=http://TU-IP-PUBLICA
```

### Paso 4: Actualizar Frontend para Producción

```bash
# Editar environment.prod.ts
nano addventurefronted-deploy/src/environments/environment.prod.ts
```

Cambiar a:
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://TU-IP-PUBLICA:8080/api',
  wsUrl: 'http://TU-IP-PUBLICA:8080/ws',
  baseUrl: 'http://TU-IP-PUBLICA:8080'
};
```

### Paso 5: Levantar Aplicación

```bash
# Build y start
docker compose up --build -d

# Ver logs (Ctrl+C para salir)
docker compose logs -f

# Verificar estado
docker compose ps
```

### Paso 6: Verificar

Abrir navegador:
```
http://TU-IP-PUBLICA
```

## 🔧 Comandos Útiles

### Ver logs
```bash
docker compose logs -f                  # Todos los servicios
docker compose logs -f backend          # Solo backend
docker compose logs -f frontend         # Solo frontend
docker compose logs -f mysql            # Solo MySQL
```

### Reiniciar servicios
```bash
docker compose restart backend          # Reiniciar backend
docker compose restart frontend         # Reiniciar frontend
docker compose restart                  # Reiniciar todo
```

### Detener/Iniciar
```bash
docker compose down                     # Detener todo
docker compose down -v                  # Detener y eliminar volúmenes (⚠️ borra DB)
docker compose up -d                    # Iniciar todo
```

### Actualizar código
```bash
# Backend
cd ~/addventure/addventurebackend-deploy
git pull
cd ~/addventure
docker compose build backend
docker compose up -d backend

# Frontend
cd ~/addventure/addventurefronted-deploy
git pull
cd ~/addventure
docker compose build frontend
docker compose up -d frontend
```

### Ver recursos
```bash
docker stats                            # Uso de CPU/RAM
docker compose ps                       # Estado de contenedores
docker system df                        # Espacio en disco
```

### Backup de Base de Datos
```bash
# Crear backup
docker exec addventure-mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} addventure > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker exec -i addventure-mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} addventure < backup_20250128.sql
```

### Acceder a contenedores
```bash
docker exec -it addventure-backend sh           # Entrar al backend
docker exec -it addventure-mysql bash           # Entrar a MySQL
docker exec -it addventure-frontend sh          # Entrar al frontend
```

## 🆘 Troubleshooting

### Backend no arranca
```bash
docker compose logs backend --tail=100
docker compose restart backend
```

### Frontend muestra 404
```bash
docker compose logs frontend
docker compose build frontend --no-cache
docker compose up -d frontend
```

### MySQL no inicia
```bash
docker compose logs mysql
docker volume ls
docker volume rm addventure_mysql_data  # ⚠️ Elimina todos los datos
docker compose up -d mysql
```

### Error de CORS
1. Verificar `.env` → `CORS_ALLOWED_ORIGINS`
2. Debe ser: `http://TU-IP-PUBLICA` (sin puerto)
3. Reiniciar backend: `docker compose restart backend`

### Limpiar todo y empezar de cero
```bash
docker compose down -v
docker system prune -a
docker compose up --build -d
```

## 📊 Monitoreo

### Logs en tiempo real
```bash
docker compose logs -f
```

### Estado de salud
```bash
docker compose ps
```

### Uso de recursos
```bash
docker stats
```

## 🔒 Seguridad

- ✅ Nunca subir `.env` a GitHub
- ✅ Usar contraseñas fuertes (20+ caracteres)
- ✅ Cambiar JWT_SECRET en cada ambiente
- ✅ Revisar logs regularmente
- ✅ Mantener Docker actualizado

## 📚 Documentación Adicional

- [Deployment con Docker](./DEPLOYMENT_DOCKER.md) - Guía completa paso a paso
- [Checklist de Deployment](./DEPLOYMENT_CHECKLIST.md) - Lista de verificación

## 🎯 Estructura de Archivos

```
addventure-deploy/
├── docker-compose.yml          # Orquestación de servicios
├── .env.example                # Template de variables de entorno
├── .env                        # Variables (NO subir a Git)
├── .dockerignore               # Archivos a ignorar en builds
├── generate-jwt-secret.ps1     # Script para generar JWT
├── DEPLOYMENT_DOCKER.md        # Guía completa
├── DEPLOYMENT_CHECKLIST.md     # Checklist
└── README.md                   # Este archivo
```

## 💰 Costos AWS EC2

**Free Tier (12 meses):**
- ✅ 750 horas/mes de t2.micro
- ✅ 30 GB almacenamiento
- ✅ 15 GB bandwidth

**Después:**
- ~$10/mes con t2.micro

## 🎓 Soporte

- Issues: Crear issue en este repo
- Docs: Ver archivos DEPLOYMENT_*.md

---

**Versión:** 1.0.0  
**Última actualización:** Noviembre 2025
