# SU_Image_Plus_Exporter

Plugin de SketchUp para exportar de forma determinista:

1. **Imagen del Viewport** (PNG)
2. **Imagen Material ID** (color único por material)
3. **Archivo JSON** con el mapeo Material ID → propiedades del material

**Nombre del archivo de distribución:** `SU_Image_Plus_Exporter_v1.0.0.rbz`

## Requisitos

- SketchUp 2020 o superior
- Windows / macOS
- Sin dependencias externas

## Estado actual

- ✅ **Fase 0** – Diseño y contratos
- ✅ **Fase 1** – Estructura del plugin + menú
- ⏳ **Fase 2** – Núcleo funcional (en progreso)
- ⏳ **Fase 3** – Interfaz de usuario
- ⏳ **Fase 4** – Empaquetado `.rbz`

## Estructura

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

## Instalación (desarrollo)

Copia la carpeta `SU_MatID_Exporter` dentro de la carpeta de Plugins de SketchUp y reinicia.

## Uso (actualmente)

**Plugins → Material ID Exporter → Exportar Viewport + MatID**

(Por ahora muestra un mensaje de confirmación de Fase 1)

---

Desarrollado para hacer más simple y determinista la generación de renders fotorrealísticos.
