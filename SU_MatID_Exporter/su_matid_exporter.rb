# encoding: UTF-8
# SU_MatID_Exporter - Loader principal
# Plugin para exportar Viewport + Material ID + mapeo JSON

require 'sketchup.rb'
require 'extensions.rb'

module SU_MatID_Exporter
  EXTENSION_NAME     = 'Material ID Exporter'.freeze
  EXTENSION_VERSION  = '1.0.0'.freeze
  EXTENSION_CREATOR  = 'SU_MatID_Exporter'.freeze
  EXTENSION_COPYRIGHT = '2025'.freeze
  EXTENSION_DESCRIPTION = 'Exporta imagen del Viewport, imagen Material ID y archivo JSON de mapeo de materiales.'.freeze

  # Versión mínima de SketchUp requerida (2020 = 20.0)
  MIN_SU_VERSION = 20.0

  unless file_loaded?(__FILE__)
    # Verificar versión mínima
    if Sketchup.version.to_f < MIN_SU_VERSION
      UI.messagebox(
        "Material ID Exporter requiere SketchUp 2020 o superior.\n" \
        "Versión actual: #{Sketchup.version}"
      )
    else
      extension = SketchupExtension.new(EXTENSION_NAME, 'su_matid_exporter/main')
      extension.version     = EXTENSION_VERSION
      extension.creator     = EXTENSION_CREATOR
      extension.copyright   = EXTENSION_COPYRIGHT
      extension.description = EXTENSION_DESCRIPTION

      Sketchup.register_extension(extension, true)
    end

    file_loaded(__FILE__)
  end
end
