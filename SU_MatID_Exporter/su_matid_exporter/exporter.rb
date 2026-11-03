# encoding: UTF-8
# SU_MatID_Exporter - Orquestador principal de la exportación
# Fase 2 – Núcleo funcional

require 'sketchup.rb'
require 'fileutils'

module SU_MatID_Exporter
  module Exporter
    extend self

    def run
      model = Sketchup.active_model

      if model.nil?
        UI.messagebox('No hay ningún modelo abierto.')
        return
      end

      materials = model.materials
      if materials.nil? || materials.length == 0
        UI.messagebox(
          "El modelo no tiene materiales.\n" \
          "No se puede generar la imagen Material ID."
        )
        return
      end

      # --- Diálogo simple de guardado (se mejorará en Fase 3) ---
      default_name = default_base_name(model)
      last_dir     = Sketchup.read_default('SU_MatID_Exporter', 'last_folder', nil)

      path = UI.savepanel(
        'Exportar Viewport + Material ID',
        last_dir,
        default_name
      )
      return if path.nil?   # Usuario canceló

      # Normalizar extensión y separar carpeta / nombre base
      path = path.gsub(/\\/, '/')
      dir  = File.dirname(path)
      base = File.basename(path, '.*')

      # Recordar última carpeta
      Sketchup.write_default('SU_MatID_Exporter', 'last_folder', dir)

      timestamp = Time.now.strftime('%Y%m%d_%H%M')
      base_with_ts = "#{base}_#{timestamp}"

      viewport_path = File.join(dir, "#{base_with_ts}_viewport.png")
      matid_path    = File.join(dir, "#{base_with_ts}_matid.png")
      json_path     = File.join(dir, "#{base_with_ts}_materials.json")

      begin
        Sketchup.status_text = 'Generando colores Material ID…'
        color_map = MaterialIdGenerator.colors_for_all(model)

        Sketchup.status_text = 'Exportando imagen del Viewport…'
        ViewportExporter.export_viewport(viewport_path)

        Sketchup.status_text = 'Exportando imagen Material ID…'
        ViewportExporter.export_material_id(matid_path, color_map)

        Sketchup.status_text = 'Generando archivo JSON de mapeo…'
        materials_data = MaterialMapper.build_materials_data(model, color_map)
        MaterialMapper.export_json(materials_data, json_path)

        Sketchup.status_text = ''

        # Mensaje de éxito
        msg = "Exportación completada correctamente.\n\n"
        msg << "Archivos generados:\n"
        msg << "• #{File.basename(viewport_path)}\n"
        msg << "• #{File.basename(matid_path)}\n"
        msg << "• #{File.basename(json_path)}\n\n"
        msg << "Carpeta:\n#{dir}"
        UI.messagebox(msg)

      rescue => e
        Sketchup.status_text = ''
        UI.messagebox(
          "Error durante la exportación:\n\n#{e.message}\n\n" \
          "El modelo no debería haber quedado modificado."
        )
      end
    end

    private

    def default_base_name(model)
      title = model.title.to_s.strip
      if title.empty? || title.downcase == 'untitled'
        'SU_MatID'
      else
        # Limpiar caracteres problemáticos para nombres de archivo
        clean = title.gsub(/[\\\/:*?"<>|]/, '_').strip
        "#{clean}-SU_MatID"
      end
    end
  end
end
