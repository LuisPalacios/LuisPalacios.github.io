#!/bin/bash
# Script para iniciar el nodo Master del cluster Exo
# Ejecutar en el Mac mini M4 Pro (Master Node)

echo "Iniciando Cluster Master (M4)..."
export EXO_HOST=10.0.0.1

# Comando para descargar y ejecutar el modelo distribuido
# Exo detectará automáticamente al peer en 10.0.0.2
exo run mlx-community/Qwen2.5-72B-Instruct-8bit

