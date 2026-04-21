# Prompt de prueba para validar el cluster

Usa este prompt en Cursor para verificar que el cluster funciona correctamente con código C++:

```text
Actúa como un arquitecto de software experto en C++20. Tengo 96GB de VRAM. Quiero que diseñes una estructura de datos 'ThreadSafeQueue' usando templates, conceptos de C++20 (requires) y smart pointers. Explícame cómo la gestión de memoria se beneficia de std::unique_ptr en este contexto.
```

## Qué observar

- **Velocidad**: Debería ser fluida (aprox 10-20 tokens/segundo)
- **Monitor de Actividad**:
  - Mac M4: RAM al 80-90% de uso
  - Mac M2: Pico de uso de RAM cuando se generan tokens
- **Calidad**: El código debe compilar sin errores y usar sintaxis moderna de C++20
