#!/bin/bash

# Script pour injecter la clé API Google Maps dans web/index.html
# Usage: ./scripts/inject_google_maps_key.sh

if [ ! -f .env ]; then
    echo "❌ Fichier .env non trouvé"
    exit 1
fi

# Lire la clé API depuis .env
GOOGLE_MAPS_KEY=$(grep GOOGLE_PLACES_API_KEY .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)

if [ -z "$GOOGLE_MAPS_KEY" ]; then
    echo "❌ GOOGLE_PLACES_API_KEY non trouvée dans .env"
    exit 1
fi

# Remplacer la clé dans web/index.html
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/YOUR_GOOGLE_MAPS_API_KEY/$GOOGLE_MAPS_KEY/g" web/index.html
else
    # Linux
    sed -i "s/YOUR_GOOGLE_MAPS_API_KEY/$GOOGLE_MAPS_KEY/g" web/index.html
fi

echo "✅ Clé API Google Maps injectée dans web/index.html"

