# SU_MatID_Exporter – Lista de Fases (SketchUp Ruby)

Plugin para exportar:
1. Imagen del Viewport
2. Imagen Material ID (color único por material)
3. Archivo de texto con el mapeo Material ID → propiedades

**Nombre del archivo de distribución:** `SU_Image_Plus_Exporter_v1.0.0.rbz`

---

## Fase 0 – Pensamiento y Diseño ✅ COMPLETADA

- [x] **0.1** Definir el contrato de salida
  - [x] Formato de imágenes: **PNG** (sin pérdida)
  - [x] Resolución: **tamaño actual del viewport**  
        *(Nota: en próximas iteraciones el usuario podrá definir el tamaño)*
  - [x] Material ID: color RGB **completamente opaco** + buena separación visual  
        *(Nota: se tendrá que hacer una mejora posterior para materiales transparentes/translúcidos como vidrios)*
  - [x] Archivo de texto: **JSON** con los campos:
        - `id` → [R, G, B]
        - `name`
        - `guid`
        - `color_original`
        - `opacity`
        - `material_type`
        - `observaciones`

- [x] **0.2** Decidir estrategia de Material ID
  - [x] Generar color **determinista** de la forma más simple posible (hash del nombre + entityID)
  - [x] Guardar mapeo en `AttributeDictionary` del modelo → **consistente entre sesiones**
  - [x] Diferencia mínima entre colores: **20 unidades** en RGB

- [x] **0.3** Definir estrategia de generación de la imagen Material ID
  - [x] Usar modificación de `material.color` + `material.alpha = 1.0`
  - [x] Forzar `rendering_options['FaceColorMode'] = 0` (ignorar texturas)
  - [x] Apagar sombras temporalmente
  - [x] Restaurar todo con backup manual + `abort_operation`
  - [x] Exportar **sin antialiasing** (`antialias: false`)

- [x] **0.4** Definir interfaz de usuario mínima
  - [x] Menú: **Plugins → Material ID Exporter → Exportar Viewport + MatID**
  - [x] Diálogo simple en esta primera versión  
        *(Nota: se mejorará en iteraciones posteriores)*

- [x] **0.5** Definir compatibilidad
  - [x] SketchUp **2020** como mínimo (ideal 2022/2023/2024)
  - [x] Windows y macOS
  - [x] **Cero dependencias externas**

---

## Fase 1 – Estructura del Plugin ✅ COMPLETADA

- [x] **1.1** Crear estructura de carpetas
  ```
  SU_MatID_Exporter/
  ├── su_matid_exporter.rb              ← loader principal
  └── su_matid_exporter/
      ├── main.rb
      ├── exporter.rb
      ├── material_id_generator.rb
      ├── viewport_exporter.rb
      ├── material_mapper.rb
      └── ui.rb
  ```
  - Sin carpeta `icons/` por ahora

- [x] **1.2** Crear el loader principal (`su_matid_exporter.rb`)
  - [x] Usar **patrón clásico** de `SketchupExtension`
  - [x] Verificar versión mínima de SketchUp (2020) y mostrar mensaje si es inferior
  - [x] Cargar todos los archivos del módulo
  - [x] Registrar la extensión

- [x] **1.3** Registrar el comando y el menú
  - [x] Menú: **Plugins → Material ID Exporter → Exportar Viewport + MatID**
  - [x] Solo menú Plugins (sin menú contextual)
  - [x] Sin atajo de teclado
  - [x] Sin icono por ahora

---

## Fase 2 – Núcleo Funcional ⏳ EN PROGRESO

- [ ] **2.1** Material ID Generator (`material_id_generator.rb`)
- [ ] **2.2** Material Mapper (`material_mapper.rb`)
- [ ] **2.3** Viewport Exporter (`viewport_exporter.rb`)
- [ ] **2.4** Material ID Image Exporter (núcleo crítico)
- [ ] **2.5** Manejo de errores y estados

---

## Fase 3 – Interfaz y Experiencia de Usuario ⏳ PENDIENTE

- [ ] **3.1** Crear diálogo de opciones (simple en v1)
- [ ] **3.2** Feedback al usuario

---

## Fase 4 – Empaquetado e Instalación ⏳ PENDIENTE

- [ ] **4.1** Crear el archivo `.rbz`
- [ ] **4.2** Pruebas de instalación y funcionamiento
- [ ] **4.3** Documentación mínima

---

## Fase 5 – Mejoras Posteriores (después de que funcione)

- [ ] **5.1** Mejora para materiales transparentes/translúcidos (vidrios, etc.)
- [ ] **5.2** Permitir al usuario definir resolución de salida
- [ ] **5.3** Mejorar el diálogo de opciones
- [ ] **5.4** Soporte para exportar solo la selección
- [ ] **5.5** Añadir Depth Pass y Normal Pass (futuro)
- [ ] **5.6** Integración con pipeline externo de render
- [ ] **5.7** Mejorar mensajes de error (más simples y multi-idioma)
- [ ] **5.8** Revisar y agregar licencia
