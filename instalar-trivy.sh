# 1. Instalar dependencias
sudo apt-get install wget apt-transport-https gnupg

# 2. Descargar y agregar la clave GPG al keyring específico
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# 3. Agregar repositorio con signed-by específico
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# 4. Actualizar e instalar
sudo apt-get update
sudo apt-get install trivy

