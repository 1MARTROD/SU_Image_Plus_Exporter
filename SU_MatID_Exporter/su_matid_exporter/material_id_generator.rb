# encoding: UTF-8
# SU_MatID_Exporter - Generador de colores Material ID deterministas
# (Implementación completa en Fase 2)

require 'sketchup.rb'

module SU_MatID_Exporter
  module MaterialIdGenerator
    extend self

    # Placeholder - se implementará en Fase 2
    def generate_color(_material)
      # TODO: Fase 2.1
      Sketchup::Color.new(128, 128, 128)
    end
  end
end
