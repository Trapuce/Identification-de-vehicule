# Utiliser une image Python officielle avec support pour OpenCV
FROM python:3.11-slim

# Installer les dépendances système nécessaires (version simplifiée)
RUN apt-get update && apt-get install -y --fix-missing \
    tesseract-ocr \
    tesseract-ocr-fra \
    ffmpeg \
    libglib2.0-0 \
    libgomp1 \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de requirements
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code de l'application
COPY . .

# Créer les répertoires nécessaires
RUN mkdir -p plate_recognition/uploads plate_recognition/static/exports

# Exposer le port 5000
EXPOSE 5000

# Variables d'environnement
ENV FLASK_APP=plate_recognition/app.py
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Commande pour démarrer l'application
CMD ["python", "plate_recognition/app.py"]
