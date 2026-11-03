# encoding: UTF-8
# SU_MatID_Exporter - Punto de entrada principal

require 'sketchup.rb'

module SU_MatID_Exporter
  # Cargar todos los módulos del plugin
  PLUGIN_ROOT = File.dirname(__FILE__).freeze

  require File.join(PLUGIN_ROOT, 'material_id_generator.rb')
  require File.join(PLUGIN_ROOT, 'material_mapper.rb')
  require File.join(PLUGIN_ROOT, 'viewport_exporter.rb')
  require File.join(PLUGIN_ROOT, 'exporter.rb')
  require File.join(PLUGIN_ROOT, 'ui.rb')

  # Inicializar la interfaz (menú)
  UI_Module.create_menu
end
