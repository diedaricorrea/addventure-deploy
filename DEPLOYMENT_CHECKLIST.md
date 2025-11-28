# ✅ Checklist de Deployment AWS EC2

## 📋 ANTES DE EMPEZAR

### En tu PC Local:
- [ ] Generar clave JWT segura: `.\generate-jwt-secret.ps1`
- [ ] Anotar la clave JWT generada
- [ ] Crear cuenta AWS (tarjeta de crédito requerida)
- [ ] Tener Git y GitHub configurados
- [ ] Exportar estructura de base de datos:
  ```bash
  mysqldump -u root -p --no-data --skip-triggers addventure > database-structure.sql
  ```

---

## 🚀 FASE 1: AWS EC2 SETUP

- [ ] Login en AWS Console
- [ ] Crear instancia EC2:
  - [ ] Tipo: `t2.micro` (Free Tier)
  - [ ] SO: `Ubuntu Server 22.04 LTS`
  - [ ] Nombre: `addventure-server`
  - [ ] Crear y descargar key pair: `addventure-key.pem`
  - [ ] Guardar .pem en `~/.ssh/`
- [ ] Configurar Security Group:
  - [ ] SSH (22) - My IP
  - [ ] HTTP (80) - 0.0.0.0/0
  - [ ] HTTPS (443) - 0.0.0.0/0
  - [ ] Custom TCP (8080) - 0.0.0.0/0
  - [ ] MySQL (3306) - My IP
- [ ] Anotar IP pública: `_________________`

---

## 🔌 FASE 2: CONECTAR AL SERVIDOR

Windows PowerShell:
```powershell
# Dar permisos a la clave
icacls "$env:USERPROFILE\.ssh\addventure-key.pem" /inheritance:r
icacls "$env:USERPROFILE\.ssh\addventure-key.pem" /grant:r "$($env:USERNAME):(R)"

# Conectar (reemplaza TU-IP)
ssh -i ~/.ssh/addventure-key.pem ubuntu@TU-IP-PUBLICA
```

- [ ] Conexión SSH exitosa

---

## ⚙️ FASE 3: INSTALAR SOFTWARE EN SERVIDOR

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Java 21
sudo apt install -y openjdk-21-jdk
java -version  # Verificar

# MySQL
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
sudo mysql_secure_installation
# (Configurar contraseña root, anotar: ________________)

# Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version  # Verificar

# Nginx
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Git
sudo apt install -y git
```

**Checklist:**
- [ ] Java 21 instalado
- [ ] MySQL corriendo
- [ ] Node.js 20 instalado
- [ ] Nginx corriendo
- [ ] Git instalado

---

## 💾 FASE 4: CONFIGURAR BASE DE DATOS

```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE addventure CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'addventure_user'@'localhost' IDENTIFIED BY 'TU_PASSWORD_SEGURA';
GRANT ALL PRIVILEGES ON addventure.* TO 'addventure_user'@'localhost';
FLUSH PRIVILEGES;
SHOW DATABASES;
EXIT;
```

- [ ] Base de datos `addventure` creada
- [ ] Usuario `addventure_user` creado
- [ ] Password anotada: `_________________`

---

## 📦 FASE 5: SUBIR CÓDIGO A GITHUB

En tu PC local:

### Backend:
```powershell
cd C:\Users\Diedari\Documents\DesarrolloWebIntegrado\addventure-backend

git init
git add .
git commit -m "Initial commit - Backend"
```

- [ ] Crear repo en GitHub: `addventure-backend`
- [ ] Copiar URL del repo: `_________________`

```powershell
git remote add origin https://github.com/TU-USUARIO/addventure-backend.git
git branch -M main
git push -u origin main
```

### Frontend:
```powershell
cd ..\addventure-fronted

git init
git add .
git commit -m "Initial commit - Frontend"
```

- [ ] Crear repo en GitHub: `addventure-fronted`

```powershell
git remote add origin https://github.com/TU-USUARIO/addventure-fronted.git
git branch -M main
git push -u origin main
```

---

## 🔧 FASE 6: CLONAR Y CONFIGURAR EN SERVIDOR

En el servidor SSH:

```bash
# Crear carpeta apps
mkdir -p ~/apps
cd ~/apps

# Clonar repos (reemplaza TU-USUARIO)
git clone https://github.com/TU-USUARIO/addventure-backend.git
git clone https://github.com/TU-USUARIO/addventure-fronted.git
```

- [ ] Backend clonado
- [ ] Frontend clonado

### Configurar variables de entorno:

```bash
nano ~/.env_addventure
```

Contenido (ajusta valores):
```bash
DB_USERNAME=addventure_user
DB_PASSWORD=TU_PASSWORD_MYSQL
JWT_SECRET=LA_CLAVE_JWT_QUE_GENERASTE
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password
CORS_ALLOWED_ORIGINS=http://TU-IP-PUBLICA
WEBSOCKET_ALLOWED_ORIGINS=http://TU-IP-PUBLICA
```

```bash
# Cargar automáticamente
echo "source ~/.env_addventure" >> ~/.bashrc
echo "export \$(cat ~/.env_addventure | xargs)" >> ~/.bashrc
source ~/.bashrc
```

- [ ] Variables de entorno configuradas

---

## 🗄️ FASE 7: IMPORTAR BASE DE DATOS

**Opción A - Hibernate crea las tablas:**
```bash
cd ~/apps/addventure-backend
nano src/main/resources/application-prod.properties

# Cambiar: spring.jpa.hibernate.ddl-auto=update
# Después del primer arranque, volver a: validate
```

**Opción B - Importar dump SQL:**
```bash
# En tu PC, subir el archivo:
scp -i ~/.ssh/addventure-key.pem database-structure.sql ubuntu@TU-IP:~/

# En el servidor:
mysql -u addventure_user -p addventure < ~/database-structure.sql
```

- [ ] Base de datos importada/creada

---

## 🏗️ FASE 8: COMPILAR APLICACIONES

### Backend:
```bash
cd ~/apps/addventure-backend
./mvnw clean package -DskipTests
# Esperar 2-5 minutos...
ls -lh target/*.jar  # Verificar que se creó el JAR
```

- [ ] Backend compilado (JAR creado)

### Frontend:
```bash
cd ~/apps/addventure-fronted

# Actualizar environment.prod.ts
nano src/environments/environment.prod.ts
```

Cambiar a (usa TU IP pública):
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://TU-IP-PUBLICA:8080/api',
  wsUrl: 'http://TU-IP-PUBLICA:8080/ws',
  baseUrl: 'http://TU-IP-PUBLICA:8080'
};
```

```bash
npm install
npm run build
ls -la dist/addventure-fronted/browser/  # Verificar archivos
```

- [ ] Frontend compilado

---

## 🚀 FASE 9: CREAR SERVICIOS SYSTEMD

### Backend Service:
```bash
sudo nano /etc/systemd/system/addventure-backend.service
```

```ini
[Unit]
Description=AddVenture Spring Boot Backend
After=syslog.target network.target mysql.service

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/apps/addventure-backend
EnvironmentFile=/home/ubuntu/.env_addventure
ExecStart=/usr/bin/java -jar /home/ubuntu/apps/addventure-backend/target/venture-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable addventure-backend
sudo systemctl start addventure-backend
sudo systemctl status addventure-backend
```

- [ ] Backend service corriendo

### Ver logs en tiempo real:
```bash
sudo journalctl -u addventure-backend -f
```

---

## 🌐 FASE 10: CONFIGURAR NGINX

```bash
sudo nano /etc/nginx/sites-available/addventure
```

Pegar configuración (reemplaza TU-IP-PUBLICA):
```nginx
server {
    listen 80;
    server_name TU-IP-PUBLICA;

    location / {
        root /home/ubuntu/apps/addventure-fronted/dist/addventure-fronted/browser;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /ws/ {
        proxy_pass http://localhost:8080/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }

    location /uploads/ {
        proxy_pass http://localhost:8080/uploads/;
    }
}
```

```bash
# Activar sitio
sudo ln -s /etc/nginx/sites-available/addventure /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Probar y reiniciar
sudo nginx -t
sudo systemctl restart nginx
```

- [ ] Nginx configurado correctamente

---

## 🎉 FASE 11: PROBAR APLICACIÓN

### En tu navegador:
```
http://TU-IP-PUBLICA
```

- [ ] Home page carga correctamente
- [ ] Puedes ir a `/auth/register`
- [ ] Puedes registrar un usuario
- [ ] Puedes hacer login
- [ ] Backend responde en `/api/home/data`

### Crear usuarios de prueba:
- [ ] Usuario 1: `_________________`
- [ ] Usuario 2: `_________________`
- [ ] Usuario 3: `_________________`

---

## 🔧 COMANDOS ÚTILES

### Logs del backend:
```bash
sudo journalctl -u addventure-backend -f
sudo journalctl -u addventure-backend -n 100
```

### Reiniciar servicios:
```bash
sudo systemctl restart addventure-backend
sudo systemctl restart nginx
```

### Ver recursos:
```bash
htop
df -h
free -h
```

### Actualizar aplicación:
```bash
# Backend
cd ~/apps/addventure-backend
git pull
./mvnw clean package -DskipTests
sudo systemctl restart addventure-backend

# Frontend
cd ~/apps/addventure-fronted
git pull
npm run build
sudo systemctl restart nginx
```

---

## 📊 MONITOREO

- [ ] Verificar uso de Free Tier: https://console.aws.amazon.com/billing/
- [ ] Configurar alarma de facturación
- [ ] Revisar logs diariamente

---

## ✅ DEPLOYMENT COMPLETADO

- **IP Pública**: `_________________`
- **URL Aplicación**: `http://TU-IP-PUBLICA`
- **URL API**: `http://TU-IP-PUBLICA/api`
- **Usuarios de Prueba**: `___ creados`
- **Estado**: 🟢 Online

**Próximos pasos:**
- [ ] Comprar dominio (opcional)
- [ ] Configurar SSL/HTTPS con Let's Encrypt
- [ ] Configurar backups automáticos
- [ ] Configurar email SMTP real
- [ ] Invitar a los 20 usuarios de prueba

---

## 🆘 TROUBLESHOOTING

### Backend no arranca:
```bash
sudo journalctl -u addventure-backend -n 200
sudo netstat -tulpn | grep 8080
```

### Frontend 404:
```bash
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log
ls -la ~/apps/addventure-fronted/dist/addventure-fronted/browser/
```

### No puedo conectarme:
- Verificar Security Group en AWS
- Verificar que tu IP no haya cambiado
- Ping a la IP pública

---

**Fecha de deployment**: _______________  
**Deployado por**: _______________  
**Versión**: 1.0.0
