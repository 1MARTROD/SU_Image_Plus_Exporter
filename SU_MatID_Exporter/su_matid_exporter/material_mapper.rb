# encoding: UTF-8
# SU_MatID_Exporter - Generador del archivo JSON de mapeo de materiales
# Fase 2.2

require 'sketchup.rb'
require 'json'

module SU_MatID_Exporter
  module MaterialMapper
    extend self

    # materials_data: Array de hashes con la información de cada material
    # path: ruta completa del archivo .json a escribir
    def export_json(materials_data, path)
      begin
        File.open(path, 'w:UTF-8') do |f|
          f.write(JSON.pretty_generate(materials_data))
        end
        true
      rescue => e
        UI.messagebox("Error al escribir el archivo JSON:\n#{e.message}")
        false
      end
    end

    # Construye el array de hashes a partir del modelo y del mapeo de colores
    # color_map: Hash { Sketchup::Material => Sketchup::Color }
    def build_materials_data(model, color_map)
      data = []

      model.materials.each do |mat|
        color_id = color_map[mat]
        next unless color_id

        orig_color = mat.color
        opacity    = mat.alpha

        material_type =
          if opacity < 1.0
            'transparent'
          elsif mat.texture
            'texture'
          else
            'color'
          end

        data << {
          'id'              => [color_id.red, color_id.green, color_id.blue],
          'name'            => mat.display_name.to_s,
          'guid'            => mat.persistent_id.to_s,
          'color_original'  => [orig_color.red, orig_color.green, orig_color.blue],
          'opacity'         => opacity,
          'material_type'   => material_type,
          'observaciones'   => ''
        }
      end

      # Ordenar por nombre para que el JSON sea más legible y estable
      data.sort_by { |h| h['name'].to_s.downcase }
    end
  end
end
