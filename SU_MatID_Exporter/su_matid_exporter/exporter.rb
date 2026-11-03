# encoding: UTF-8
# SU_MatID_Exporter - Orquestador principal de la exportación

require 'sketchup.rb'

module SU_MatID_Exporter
  module Exporter
    extend self

    # Punto de entrada principal (llamado desde el menú)
    def run
      model = Sketchup.active_model

      if model.nil?
        UI.messagebox('No hay ningún modelo abierto.')
        return
      end

      # Placeholder de Fase 1: solo confirma que el menú funciona
      UI.messagebox(
        "Material ID Exporter v#{EXTENSION_VERSION}\n\n" \
        "Fase 1 completada.\n" \
        "El menú y la estructura del plugin están listos.\n\n" \
        "Próximo paso: Fase 2 (núcleo funcional)."
      )
    end
  end
end
