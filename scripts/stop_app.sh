#!/bin/bash
echo "Parando aplicação Flask..."
sudo pkill -f "python3 app.py"

BACKUP_DIR="/opt/flaskapp_backup/$(date +%Y%m%d_%H%M%S)"
sudo mkdir -p "$BACKUP_DIR"

# Move tudo de /opt/flaskapp para o diretório de backup
sudo mv /opt/flaskapp/* "$BACKUP_DIR" 2>/dev/null || echo "Nada para mover"

sudo echo "Backup realizado em: $BACKUP_DIR"