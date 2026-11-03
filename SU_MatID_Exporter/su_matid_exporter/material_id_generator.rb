# encoding: UTF-8
# SU_MatID_Exporter - Generador de colores Material ID deterministas
# Fase 2.1

require 'sketchup.rb'
require 'digest'

module SU_MatID_Exporter
  module MaterialIdGenerator
    extend self

    DICT_NAME     = 'SU_MatID_Exporter'.freeze
    MIN_DISTANCE  = 20          # Distancia mínima entre colores RGB
    MIN_COMPONENT = 15          # Evitar valores muy bajos (casi negro)
    MAX_COMPONENT = 240         # Evitar valores muy altos (casi blanco)

    # Devuelve un Sketchup::Color único y determinista para el material.
    # Guarda el mapeo en AttributeDictionary del modelo para consistencia entre sesiones.
    def color_for(material, model)
      return Sketchup::Color.new(128, 128, 128) if material.nil?

      pid = material.persistent_id.to_s
      stored = model.get_attribute(DICT_NAME, pid)

      if stored.is_a?(Array) && stored.length == 3
        return Sketchup::Color.new(*stored)
      end

      # Generar color nuevo
      rgb = generate_unique_rgb(material, model)
      model.set_attribute(DICT_NAME, pid, rgb)
      Sketchup::Color.new(*rgb)
    end

    # Genera un hash de todos los materiales del modelo y devuelve
    # un Hash { material => Sketchup::Color }
    def colors_for_all(model)
      result = {}
      model.materials.each do |mat|
        result[mat] = color_for(mat, model)
      end
      result
    end

    private

    def generate_unique_rgb(material, model)
      # Semilla determinista: nombre + entityID
      seed_str = "#{material.name.to_s}|#{material.entityID}"
      hash = Digest::MD5.hexdigest(seed_str)

      # Extraer 3 valores iniciales del hash
      r = (hash[0..1].to_i(16) % (MAX_COMPONENT - MIN_COMPONENT + 1)) + MIN_COMPONENT
      g = (hash[2..3].to_i(16) % (MAX_COMPONENT - MIN_COMPONENT + 1)) + MIN_COMPONENT
      b = (hash[4..5].to_i(16) % (MAX_COMPONENT - MIN_COMPONENT + 1)) + MIN_COMPONENT

      used = existing_colors(model)

      # Ajustar hasta cumplir distancia mínima
      50.times do |i|
        candidate = [r, g, b]
        if far_enough?(candidate, used)
          return candidate
        end
        # Perturbar de forma determinista
        r = (r + 37 + i * 13) % (MAX_COMPONENT - MIN_COMPONENT + 1) + MIN_COMPONENT
        g = (g + 53 + i * 17) % (MAX_COMPONENT - MIN_COMPONENT + 1) + MIN_COMPONENT
        b = (b + 71 + i * 19) % (MAX_COMPONENT - MIN_COMPONENT + 1) + MIN_COMPONENT
      end

      # Fallback (muy improbable)
      [r, g, b]
    end

    def existing_colors(model)
      colors = []
      dict = model.attribute_dictionary(DICT_NAME, false)
      return colors unless dict

      dict.each_pair do |_key, value|
        colors << value if value.is_a?(Array) && value.length == 3
      end
      colors
    end

    def far_enough?(candidate, used_list)
      used_list.none? do |other|
        distance(candidate, other) < MIN_DISTANCE
      end
    end

    def distance(c1, c2)
      Math.sqrt(
        (c1[0] - c2[0])**2 +
        (c1[1] - c2[1])**2 +
        (c1[2] - c2[2])**2
      )
    end
  end
end
