#!/bin/bash
# Script para iniciar el nodo Worker del cluster Exo
# Ejecutar en el Mac mini M2 Pro (Worker Node)

echo "Iniciando Nodo Worker (M2)..."
# Forzamos a Exo a escuchar en la IP del Thunderbolt
export EXO_HOST=10.0.0.2
exo

