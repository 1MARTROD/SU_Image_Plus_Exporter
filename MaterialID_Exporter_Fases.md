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

## Fase 2 – Núcleo Funcional ✅ COMPLETADA

- [x] **2.1** Material ID Generator (`material_id_generator.rb`)
  - [x] Generar color determinista con hash de `material.name` + `material.entityID`
  - [x] Evitar negros y blancos puros + garantizar diferencia mínima de **20 unidades** RGB
  - [x] Tratar el material Default y materiales sin nombre **igual que al resto**
  - [x] Guardar mapeo en `AttributeDictionary` llamado `"SU_MatID_Exporter"`  
        (clave: `material.persistent_id` → valor: `[R, G, B]`)

- [x] **2.2** Material Mapper (`material_mapper.rb`)
  - [x] Campos del JSON:
        - `id` [R, G, B]
        - `name`
        - `guid`
        - `color_original`
        - `opacity`
        - `material_type` → `"color"` / `"texture"` / `"transparent"`
        - `observaciones` → vacío por defecto
  - [x] Nombre del archivo: `nombre_base_YYYYMMDD_HHMM_materials.json`

- [x] **2.3** Viewport Exporter (`viewport_exporter.rb`)
  - [x] Nombre del archivo: `nombre_base_YYYYMMDD_HHMM_viewport.png`
  - [x] Exportar **con antialiasing**
  - [x] Resolución = tamaño actual del viewport

- [x] **2.4** Material ID Image Exporter (núcleo crítico)
  - [x] Nombre del archivo: `nombre_base_YYYYMMDD_HHMM_matid.png`
  - [x] Guardar estado original de `FaceColorMode` y `DisplayShadows`
  - [x] Guardar `color` y `alpha` de cada material
  - [x] Forzar `FaceColorMode = 0` y `DisplayShadows = false`
  - [x] Asignar color ID único + `alpha = 1.0`
  - [x] Exportar **sin antialiasing**
  - [x] Orden de restauración en `ensure`:
        1. Restaurar `color` y `alpha` de cada material
        2. Restaurar `FaceColorMode` y `DisplayShadows`
        3. `model.abort_operation`
  - [x] Si el modelo no tiene materiales → mostrar **advertencia** y cancelar

- [x] **2.5** Manejo de errores y estados
  - [x] Proteger todo con `begin/rescue/ensure`
  - [x] Nunca dejar el modelo en estado intermedio
  - [x] Mensajes en **español** por ahora  
        *(Nota: se mejorará este aspecto en próximas versiones)*
  - [x] Mensajes **descriptivos** por ahora  
        *(Nota: en próximas versiones serán más simples)*

---

## Fase 3 – Interfaz y Experiencia de Usuario ✅ COMPLETADA

- [x] **3.1** Crear diálogo de opciones (simple en v1)
  - [x] Usar **`UI.savepanel`** para elegir carpeta + nombre base
  - [x] Nombre base por defecto: **`NombreDelArchivo-SU_MatID`**  
        (se toma del nombre del modelo de SketchUp + sufijo)
  - [x] Opción “Incluir archivo de mapeo” (Yes/No) → **activado por defecto**  
        (se recuerda la última preferencia del usuario)
  - [x] Recordar la **última carpeta usada** con `Sketchup.write_default` / `read_default`

- [x] **3.2** Feedback al usuario
  - [x] Mensaje de éxito detallado con lista de archivos generados + ruta de la carpeta
  - [x] **No** abrir la carpeta automáticamente (solo mensaje)
  - [x] Mostrar estado en la **status bar** mientras se exporta (“Exportando Material ID…”)

---

## Fase 4 – Empaquetado e Instalación ✅ COMPLETADA

- [x] **4.1** Crear el archivo `.rbz`
  - [x] Nombre del archivo: **`SU_Image_Plus_Exporter_v1.0.0.rbz`**
  - [x] Incluir README.md con:
        - Descripción corta
        - Requisitos (SketchUp 2020+)
        - Cómo instalar
        - Cómo usar
        - Formato de los archivos generados
        - Limitaciones conocidas
  - [x] Sin archivo de licencia por ahora *(a revisar luego)*

- [x] **4.2** Pruebas de instalación y funcionamiento
  - [x] Lista de pruebas prioritarias:
        1. Modelo con pocos materiales (2-5)
        2. Modelo con muchos materiales (30+)
        3. Materiales con texturas
        4. Materiales transparentes / vidrios
        5. Grupos y componentes anidados
        6. Verificar colores únicos y consistentes entre exportaciones
        7. Verificar que el JSON se genere correctamente
        8. Probar cancelar el `savepanel` (que no tire error)
  - [x] Preparar un **modelo de pruebas específico**

- [x] **4.3** Documentación mínima
  - [x] Comentarios en el código: **nivel moderado**
  - [x] Idioma: **todo en español** (código + README) por ahora

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
- [x] **5.9** Shadow Pass (imagen solo con sombras) – Opción A ✅ IMPLEMENTADA
  - Estrategia: **White Model + DisplayShadows = true**
  - Materiales opacos → blanco puro + alpha 1.0
  - Materiales transparentes/translúcidos → blanco + **se preserva el alpha original** (vidrio transmite luz)
  - `FaceColorMode = 0`
  - Fondo blanco
  - Apagar edges (`EdgeDisplayMode = 0`) y profiles (`DrawSilhouettes = false`)
  - Usar la configuración actual de `ShadowInfo` del modelo (hora, soft shadows, etc.)
  - Restauración completa en `ensure` + `abort_operation`
  - Nombre de archivo: `nombre_base_YYYYMMDD_HHMM_shadow.png`
  - **Siempre se genera** (sin opción en UI)
  - Antialiasing: **activado**

---

## Orden Recomendado de Implementación

1. [x] Fase 1 → Estructura + menú vacío
2. [x] Fase 2.3 → Exportar solo el viewport
3. [x] Fase 2.1 + 2.2 → Generador de Material ID + archivo de mapeo
4. [x] Fase 2.4 → Exportar imagen Material ID (núcleo)
5. [x] Fase 3 → Diálogo de opciones
6. [ ] Fase 4 → Empaquetar como `.rbz` y probar

---

**Decisiones clave acumuladas**

| Tema                    | Decisión                                              | Nota futura                          |
|-------------------------|-------------------------------------------------------|--------------------------------------|
| Nombre del plugin       | **SU_MatID_Exporter** (interno)                       | —                                    |
| Nombre del .rbz         | **SU_Image_Plus_Exporter_v1.0.0.rbz**                 | —                                    |
| Formato imagen          | PNG                                                   | —                                    |
| Resolución              | Tamaño del viewport                                   | Usuario podrá definirlo              |
| Opacidad Material ID    | Siempre 1.0 (opaco)                                   | Mejorar soporte de vidrios           |
| Separación de colores   | Mínimo 20 unidades RGB                                | —                                    |
| Persistencia            | AttributeDictionary `"SU_MatID_Exporter"`             | —                                    |
| Antialiasing Viewport   | Activado                                              | —                                    |
| Antialiasing MatID      | Desactivado                                           | —                                    |
| Nombres de archivo      | `nombre_base_YYYYMMDD_HHMM_*.png/json`                | Timestamp corto                      |
| material_type           | `"color"` / `"texture"` / `"transparent"`             | —                                    |
| observaciones           | Vacío por defecto                                     | —                                    |
| Sin materiales          | Mostrar advertencia y cancelar                        | —                                    |
| Mensajes                | Español + descriptivos                                | Se simplificarán y se internacionalizarán |
| Diálogo                 | `UI.savepanel`                                        | —                                    |
| Nombre base por defecto | `NombreDelArchivo-SU_MatID`                           | —                                    |
| Checkbox mapeo          | Activado por defecto                                  | —                                    |
| Última carpeta          | Se recuerda                                           | —                                    |
| Abrir carpeta           | No (solo mensaje)                                     | —                                    |
| Feedback durante export | Status bar                                            | —                                    |
| Comentarios             | Nivel moderado + español                              | —                                    |
| Licencia                | Ninguna por ahora                                     | A revisar luego                      |
| Versión mínima          | SketchUp 2020                                         | —                                    |
| Dependencias            | Ninguna                                               | —                                    |
| Menú                    | Plugins → Material ID Exporter → Exportar Viewport + MatID | Solo menú, sin icono ni atajo   |
| Shadow Pass             | White Model + DisplayShadows = true (Opción A)        | Fondo blanco, materiales blancos |
| Nombre Shadow Pass      | `*_shadow.png`                                        | —                                |
| Shadow Pass siempre     | Sí (sin checkbox)                                     | Edges/profiles apagados          |
| Antialiasing Shadow     | Activado                                              | —                                |
