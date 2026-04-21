#!/bin/bash
# Script para verificar el rendimiento del enlace Thunderbolt Bridge
# Ejecutar en el Mac Master (M4) después de iniciar iperf3 -s en el Worker (M2)

echo "Verificando rendimiento del Thunderbolt Bridge..."
echo "Asegúrate de que iperf3 -s está corriendo en el Worker (M2)"
echo ""

# Prueba básica
echo "=== Prueba básica ==="
iperf3 -c 10.0.0.2

echo ""
echo "=== Prueba con múltiples flujos (más realista) ==="
iperf3 -c 10.0.0.2 -P 4 -t 30

echo ""
echo "Si ves valores alrededor de 35-38 Gbit/s, el enlace está funcionando correctamente."

