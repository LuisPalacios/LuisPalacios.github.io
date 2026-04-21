## Información Básica

**Título del Post**: Cluster de IA Distribuido en Casa

**Fecha propuesta**: 2025-11-29

**Categoría principal**: infraestructura

**Tags**: ia, ai, llm, ollama, exo, lm-studio, cursor, software, desarrollo, macos, homelab, mlx, qwen

**Draft**: false

## Descripción del Contenido

**Propósito del post**: Explicar en una guía técnica, completa y rigurosa cómo montar en mi casa un cluster de Macs como motor que suministra inteligencia artificial en bruto. El equivalente a tener mi propio centro de datos de OpenAI en miniatura. Estar construyendo un Servidor de Inferencia Distribuido (Distributed Inference Server).

**Audiencia objetivo**: Desarrolladores y técnicos que les gusta el DIY, que se montan home-labs, con servidores o equipos caseros, que trabajan con Mac y que probablemente tengan algún Mac mas antiguo que quieran poder aprovechar. Desarrolladores de software que utilizan IDE's avanzados que permiten configurar equipos custom para LLM.

## Estructura del Contenido

### Introducción

El objetivo es montar en mi home lab un cluster con un par de Macs para tener un Servidor de Inferencia Distribuido, el equivalente a un mini centro de datos de OpenAI en casa. Para ejecutarlo voy a usar Mac Mini (Apple Silicon) y el software Exo. Mi caso de uso va a ser para desarrollo de software, desde un tercer ordenador donde tengo Cursor para desarrollo en C++ principalmente, y puntualmente desarrollo en Golang y web full-stack (js, ts, html, css).

El objetivo final es que Cursor use de forma transparente a los Mac's, en vez de consumir tokens (ahorro). Los equipos que tengo son un Mac mini M4 Pro (64GB) y un Mac mini M2 Pro (32GB) por lo que tendré disponible 96GB de Unified Memory. Gracias a Exo es como tener 96GB de memoria unificada, lo que me permitirá ejecutar el modelo que he elegido, el **Qwen 2.5 72B**, un modelo de vanguardia en generación de código ("Open Weights").

- **Nodo Master:** Mac mini M4 Pro (64GB). Ejecutará el proceso principal y la API.
- **Nodo Worker:** Mac mini M2 Pro (32GB). Servirá como expansión de memoria VRAM.
- **Software:** `exo` (motor de inferencia distribuida) y `Cursor` (IDE que se conecta al motor).
- **Interconexión:** Thunderbolt Bridge a 40Gbps entre los dos Nodos para que `exo` vuele !
- **Red:** Todos los ordenadores están conectados por cable a una red Ethernet de 1Gbps de la casa, que solo sirve para que Cursor hable con el nodo Master.

### Secciones principales

1. **Arquitectura general y conceptos**
   - Introducción explicativa sobre los modelos de despliegue posibles: un solo servidor, cluster doméstico, nodos GPU/CPU mixtos
   - Cómo se integra Exo en esta arquitectura
   - Comparativa de running local vs. distribución del modelo entre nodos
   - Incluir un esquema de arquitectura (ASCII o Mermaid) mostrando la conexión entre los nodos

2. **Requisitos de hardware**
   - CPUs recomendadas, memoria RAM según tamaño de modelos
   - GPUs compatibles y recomendadas (NVIDIA con CUDA, AMD ROCm, sin GPU)
   - Consideraciones térmicas y de consumo para un homelab
   - Qué cambiar si quiero añadir más nodos en el futuro

3. **Mi setup específico: cluster doméstico con dos Macs**
   - Descripción del hardware: Mac mini M4 Pro (64GB) como Master y Mac mini M2 Pro (32GB) como Worker
   - Balanceo de carga y reparto de modelos
   - Limitaciones reales del multi-node en casa
   - Estrategias de almacenamiento compartido (NFS, ZFS, Gluster, etc.). Ver si me aplica, dado que NO voy a almacenar nada
   - Quiero que mi cluster atienda a un ordenador con Windows donde tendré Cursor para desarrollo de software

4. **Configuración de red: Thunderbolt Bridge**
   - Muy somera descripción sobre cómo exponer o no exponer servicios y la configuración LAN/VLAN
   - Para que la IA responda rápido, necesitamos los 20-40 Gbps del cable Thunderbolt, no el 1 Gbps de Ethernet ni mucho menos Wi-Fi
   - Conectar un cable **Thunderbolt 3 o 4** (USB-C de alta velocidad) directamente entre ambos Macs
   - Configuración de IPs Estáticas (Crucial): Aseguro que `exo` use el TB, con IP's estáticas
     - En ambos Mac's uso Red > Interfaz "Puente Thunderbolt" (no el que pone Thunderbolt Ethernet)
     - En el Mac M4 (Master): Dirección IP: `10.0.0.1`. Máscara de subred: `255.255.255.0`. Router: (vacío)
     - En el Mac M2 (Worker): Dirección IP: `10.0.0.2`. Máscara de subred: `255.255.255.0`. Router: (vacío)
     - Verifico que el ping funciona: Terminal en el M4 `ping 10.0.0.2`. Deberías ver tiempos de respuesta inferiores a 0.5ms
   - Verificación de rendimiento con iperf3
     - Instalar homebrew y luego `brew install iperf3`
     - En el Mac `Worker` actúo de servidor, lanzo `iperf3 -s` para dejarlo escuchando
     - En el Mac `Master` actúo como cliente, lanzo `iperf3 -c 10.0.0.2` y luego opcionalmente `iperf3 -c 10.0.0.2 -P 4 -t 30` para usar varios flujos en paralelo
     - Si los resultados se sitúan de forma estable alrededor de 35–38 Gbit/s, se puede considerar que el enlace Thunderbolt Bridge está funcionando a su capacidad práctica máxima

5. **Instalación y configuración de Exo**
   - Requisito previo: Python instalado
   - Instalación de `exo` en macOS: `pip install exo` en un entorno virtual con `venv`
   - Explicar qué es Exo y algunos conceptos como qué es un agente, permisos y directorios
   - Si lo consideras necesario explicar conceptos sobre cómo crear endpoints de inferencia y cómo ajustar CPU/GPU scheduling. Si no aplica a mi setup con dos Mac's explicar porqué
   - Describir que en el Mac ya tenemos garantizado que la GPU es correcta, pero que si estuviésemos en otros equipos linux o windows deberías verificar la GPU, drivers, CUDA o ROCm
   - Incluir un ejemplo realista de `exo.yaml` para un servidor doméstico

6. **Optimización y cuantización**
   - Explicar qué es la cuantización (Q4, Q5, Q8, AWQ, GPTQ, GGUF, etc.)
   - El offloading CPU/GPU
   - Cómo medir rendimiento y latencia

7. **Selección del modelo LLM**
   - Cómo elegir el modelo adecuado según el hardware
   - En mi ejemplo quiero un modelo ideal para programar en C++ principalmente y eventualmente en golang y web full stack (javascript, typescript, html, css)
   - Para C++, necesitamos precisión lógica (templates, punteros, gestión de memoria)
   - Con **96GB de RAM**, podemos apuntar a la cuantización de alta fidelidad
   - El modelo que voy a utilizar:
     - **Modelo:** Qwen 2.5 72B Instruct
     - **Formato:** MLX (Nativo de Apple)
     - **Cuantización:** 8-bit (Preferencia) o 4-bit (Fallback)

     | Versión | RAM Estimada | Espacio libre para Contexto | Recomendación |
     | :--- | :--- | :--- | :--- |
     | **8-bit** | ~77 GB | ~19 GB | **Ideal para máxima inteligencia** |
     | **4-bit** | ~45 GB | ~51 GB | Usar si el 8-bit va lento o falla |

8. **Descarga y carga de modelos**
   - Explicar qué es HuggingFace
   - Cómo descargar modelos
   - El nombre del repo que voy a usar es: `mlx-community/Qwen2.5-72B-Instruct-8bit`
   - Cómo cargarlos en Exo
   - Ejemplos concretos de comandos y archivos de configuración
   - Scripts de inicio:
     - `start_master.sh` para el nodo Master (M4)
     - `start_worker.sh` para el nodo Worker (M2)
   - Procedimiento de arranque:
     - Ejecutar `sh start_worker.sh` en el M2. Esperar 5 segundos
     - Ejecutar `sh start_master.sh` en el M4. La primera vez tardará bastante descargando los GBs del modelo

9. **Configuración de Cursor (IDE)**
   - Una vez que exo esté corriendo en el M4, verás un mensaje: API listening on http://...:52415
   - Abrir Cursor en tu PC (o Mac)
   - Ve a Settings (Rueda dentada) -> Models
   - Desactivar los modelos online (opcional) para evitar cobros
   - Añadir Modelo:
     - Nombre: `mlx-community/Qwen2.5-72B-Instruct-8bit` (Debe coincidir con lo que dice la terminal de Exo)
     - Override OpenAI Base URL: `http://192.168.100.5:52415/v1`
     - Uso la IP de la LAN del M4, porque programo desde un tercer PC fuera del Thunderbolt

10. **Prueba de contexto y validación**
    - Para verificar que el "cerebro distribuido" funciona y no alucina con C++:
      - Prompt de prueba en Cursor: "Actúa como un arquitecto de software experto en C++20. Tengo 96GB de VRAM. Quiero que diseñes una estructura de datos 'ThreadSafeQueue' usando templates, conceptos de C++20 (requires) y smart pointers. Explícame cómo la gestión de memoria se beneficia de std::unique_ptr en este contexto."
      - Qué observar:
        - Velocidad: Debería ser fluida (aprox 10-20 tokens/segundo gracias al Thunderbolt)
        - Monitor de Actividad:
          - En el Mac M4: Deberías ver la RAM al 80-90% de uso (o lo que requiera su parte)
          - En el Mac M2: Deberías ver un pico de uso de RAM cuando se generan tokens (Exo mueve datos entre ellos)
        - Calidad: El código debe compilar sin errores y usar sintaxis moderna (requires, std::move, std::mutex)

11. **Comparación con otras soluciones**
    - Comparación honesta entre Exo, Oobabooga, LM Studio, Ollama y vLLM para homelabs

12. **Otros usos y casos de uso**
    - Hostear un endpoint local para usar con ChatGPT o clientes OpenAI API compatibles
    - Montar agentes locales y workflows
    - Integrar el LLM doméstico con Home Assistant, apps propias o VSCode

13. **Automatización y mantenimiento**
    - Cómo automatizar actualizaciones de modelos
    - Cómo persistir configuraciones
    - Cómo monitorizar uso de GPU y temperatura
    - Backups y restauración

### Conclusión

La conclusión debe resumir en un solo párrafo el artículo.

## Recursos y Referencias

**Enlaces externos relevantes**:

- [Exo - Distributed Inference Server](https://github.com/exo-lang/exo) - Repositorio oficial de Exo
- [MLX - Machine Learning Framework for Apple Silicon](https://github.com/ml-explore/mlx) - Framework MLX
- [Qwen 2.5 72B en HuggingFace](https://huggingface.co/mlx-community/Qwen2.5-72B-Instruct-8bit) - Modelo Qwen 2.5 72B
- [Cursor IDE](https://cursor.sh/) - IDE con soporte para LLMs locales
- [HuggingFace](https://huggingface.co/) - Plataforma de modelos de IA

**Posts relacionados (enlaces internos)**:

- (Buscar posts relacionados sobre Mac, desarrollo, o herramientas similares)

## Imágenes y Recursos Visuales

**Logo del post**: Logo relacionado con IA/cluster, ruta: `/img/posts/logo-ai.svg`

**Imágenes a incluir**:

1. Esquema de arquitectura del cluster - `2025-11-29-cluster-ia-distribuido-01.svg`
2. Configuración de red Thunderbolt Bridge - `2025-11-29-cluster-ia-distribuido-02.png`
3. Ejemplo de configuración exo.yaml - `2025-11-29-cluster-ia-distribuido-03.png`
4. Monitor de actividad mostrando uso de RAM en ambos nodos - `2025-11-29-cluster-ia-distribuido-04.png`
5. Configuración de Cursor IDE - `2025-11-29-cluster-ia-distribuido-05.png`

## Código y Snippets

**Snippets de código a incluir**:

1. Script de inicio del nodo Master - `snippets/2025-11-29-cluster-ia-distribuido/start_master.sh`
2. Script de inicio del nodo Worker - `snippets/2025-11-29-cluster-ia-distribuido/start_worker.sh`
3. Configuración exo.yaml - `snippets/2025-11-29-cluster-ia-distribuido/exo.yaml`
4. Script de verificación de red con iperf3 - `snippets/2025-11-29-cluster-ia-distribuido/test_thunderbolt.sh`
5. Ejemplo de prompt de prueba para Cursor - `snippets/2025-11-29-cluster-ia-distribuido/test_prompt.md`

**Lenguajes de programación**: bash, yaml, markdown

## Notas Adicionales

- Este post es muy técnico y detallado, dirigido a desarrolladores con experiencia en homelabs
- Incluir advertencias sobre consumo eléctrico y térmico de mantener dos Macs corriendo constantemente
- Mencionar alternativas más simples (un solo Mac, modelos más pequeños) para usuarios con menos recursos
- Considerar incluir una sección de troubleshooting común
- El post debe ser práctico y reproducible, con comandos exactos y configuraciones verificadas
