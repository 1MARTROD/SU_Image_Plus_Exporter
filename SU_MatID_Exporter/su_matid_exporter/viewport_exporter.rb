# encoding: UTF-8
# SU_MatID_Exporter - Exportador de imagen del Viewport, Material ID y Shadow Pass
# Fase 2.3, 2.4 + 5.9 (Shadow Pass)

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

    # Exporta la Shadow Pass (White Model + Shadows).
    # Estrategia Opción A (mejorada):
    # - Materiales opacos → blanco puro + alpha 1.0
    # - Materiales transparentes/translúcidos → blanco + se preserva el alpha original
    #   (para que el vidrio siga transmitiendo luz)
    # - DisplayShadows = true (usa la configuración actual de ShadowInfo)
    # - Sin edges ni profiles (silhouettes)
    # - Fondo blanco
    # - Antialiasing activado
    def export_shadow_pass(path)
      model = Sketchup.active_model
      view  = model.active_view
      ro    = model.rendering_options

      # --- Backup del estado original ---
      original_face_color_mode = ro['FaceColorMode']
      original_shadows         = ro['DisplayShadows']
      original_edge_display    = ro['EdgeDisplayMode'] rescue nil
      original_silhouettes     = ro['DrawSilhouettes'] rescue nil
      original_profiles_only   = ro['DrawProfilesOnly'] rescue nil
      original_bg_color        = ro['BackgroundColor'] rescue nil
      original_draw_ground     = ro['DrawGround'] rescue nil
      original_draw_horizon    = ro['DrawHorizon'] rescue nil

      # Backup de todos los materiales del modelo
      material_backup = {}
      model.materials.each do |mat|
        material_backup[mat] = {
          color: mat.color,
          alpha: mat.alpha
        }
      end

      white = Sketchup::Color.new(255, 255, 255)

      begin
        model.start_operation('SU_MatID_Exporter - Shadow Pass', true)

        # White Model: preservar alpha de materiales transparentes/translúcidos
        # para que el vidrio siga dejando pasar luz y genere el parche de iluminación.
        model.materials.each do |mat|
          original_alpha = material_backup[mat][:alpha]
          mat.color = white
          if original_alpha < 0.99
            mat.alpha = original_alpha   # mantener transparencia del vidrio
          else
            mat.alpha = 1.0
          end
        end

        # Opciones de renderizado para Shadow Pass limpia
        ro['FaceColorMode']   = 0          # Material / Front Color
        ro['DisplayShadows']  = true       # Sombras activas (usa ShadowInfo actual)
        ro['EdgeDisplayMode'] = 0 if original_edge_display != nil   # Sin edges
        ro['DrawSilhouettes'] = false if original_silhouettes != nil # Sin profiles
        ro['DrawProfilesOnly']= false if original_profiles_only != nil
        ro['BackgroundColor'] = white if original_bg_color != nil
        ro['DrawGround']      = false if original_draw_ground != nil
        ro['DrawHorizon']     = false if original_draw_horizon != nil

        # Exportar con antialiasing
        opts = {
          :filename    => path,
          :width       => view.vpwidth,
          :height      => view.vpheight,
          :antialias   => true,
          :transparent => false
        }

        success = view.write_image(opts)
        unless success
          raise "No se pudo escribir la imagen Shadow Pass: #{path}"
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
          ro['FaceColorMode']   = original_face_color_mode
          ro['DisplayShadows']  = original_shadows
          ro['EdgeDisplayMode'] = original_edge_display if original_edge_display != nil
          ro['DrawSilhouettes'] = original_silhouettes if original_silhouettes != nil
          ro['DrawProfilesOnly']= original_profiles_only if original_profiles_only != nil
          ro['BackgroundColor'] = original_bg_color if original_bg_color != nil
          ro['DrawGround']      = original_draw_ground if original_draw_ground != nil
          ro['DrawHorizon']     = original_draw_horizon if original_draw_horizon != nil
        rescue
          # ignore
        end

        # 3. Abortar la operación (no dejar cambios en el historial)
        model.abort_operation
      end
    end
  end
end
