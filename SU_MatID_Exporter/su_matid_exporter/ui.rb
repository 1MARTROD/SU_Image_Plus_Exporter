# encoding: UTF-8
# SU_MatID_Exporter - Interfaz de usuario (menú y diálogos)
# Fase 1 + Fase 3

require 'sketchup.rb'

module SU_MatID_Exporter
  module UI_Module
    extend self

    MENU_NAME    = 'Material ID Exporter'.freeze
    COMMAND_NAME = 'Exportar Viewport + MatID'.freeze

    def create_menu
      plugins_menu = UI.menu('Plugins')
      submenu = plugins_menu.add_submenu(MENU_NAME)

      cmd = UI::Command.new(COMMAND_NAME) {
        Exporter.run
      }
      cmd.tooltip = 'Exporta la imagen del Viewport, la imagen Material ID y (opcionalmente) el archivo JSON de mapeo'
      cmd.status_bar_text = 'Exportar Viewport + Material ID + JSON de mapeo'

      submenu.add_item(cmd)
    end
  end
end
