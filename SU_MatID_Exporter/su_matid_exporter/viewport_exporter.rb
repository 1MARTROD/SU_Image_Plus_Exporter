# encoding: UTF-8
# SU_MatID_Exporter - Exportador de imagen del Viewport y Material ID
# Fase 2.3 y 2.4

require 'sketchup.rb'

module SU_MatID_Exporter
  module ViewportExporter
    extend self

    # Exporta la imagen normal del viewport (con antialiasing)
    def export_viewport(path)
      model = Sketchup.active_model
      view  = model.active_view

      opts = {
        :filename    => path,
        :width       => view.vpwidth,
        :height      => view.vpheight,
        :antialias   => true,
        :transparent => false
      }

      success = view.write_image(opts)
      unless success
        raise "No se pudo escribir la imagen del Viewport: #{path}"
      end
      true
    end

    # Exporta la imagen Material ID (sin antialiasing).
    # color_map: Hash { Sketchup::Material => Sketchup::Color }
    # Esta es la operación crítica: modifica temporalmente los materiales.
    def export_material_id(path, color_map)
      model = Sketchup.active_model
      view  = model.active_view
      ro    = model.rendering_options

      # --- Backup del estado original ---
      original_face_color_mode = ro['FaceColorMode']
      original_shadows         = ro['DisplayShadows']

      material_backup = {}
      color_map.each_key do |mat|
        material_backup[mat] = {
          color: mat.color,
          alpha: mat.alpha
        }
      end

      begin
        model.start_operation('SU_MatID_Exporter - Material ID', true)

        # Forzar modo de color de cara y apagar sombras
        ro['FaceColorMode']  = 0   # 0 = Material / Front Color
        ro['DisplayShadows'] = false

        # Asignar colores ID opacos
        color_map.each do |mat, id_color|
          mat.color = id_color
          mat.alpha = 1.0
        end

        # Exportar sin antialiasing
        opts = {
          :filename    => path,
          :width       => view.vpwidth,
          :height      => view.vpheight,
          :antialias   => false,
          :transparent => false
        }

        success = view.write_image(opts)
        unless success
          raise "No se pudo escribir la imagen Material ID: #{path}"
        end

        true
      ensure
        # --- Restauración obligatoria (orden estricto) ---
        # 1. Restaurar color y alpha de cada material
        material_backup.each do |mat, data|
          begin
            mat.color = data[:color]
            mat.alpha = data[:alpha]
          rescue
            # Si el material fue eliminado mientras tanto, ignorar
          end
        end

        # 2. Restaurar opciones de renderizado
        begin
          ro['FaceColorMode']  = original_face_color_mode
          ro['DisplayShadows'] = original_shadows
        rescue
          # ignore
        end

        # 3. Abortar la operación (no dejar cambios en el historial)
        model.abort_operation
      end
    end
  end
end
