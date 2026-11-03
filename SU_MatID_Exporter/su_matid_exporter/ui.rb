# encoding: UTF-8
# SU_MatID_Exporter - Interfaz de usuario (menú y diálogos)

require 'sketchup.rb'

module SU_MatID_Exporter
  module UI_Module
    extend self

    MENU_NAME = 'Material ID Exporter'.freeze
    COMMAND_NAME = 'Exportar Viewport + MatID'.freeze

    def create_menu
      # Crear submenú bajo Plugins
      plugins_menu = UI.menu('Plugins')
      submenu = plugins_menu.add_submenu(MENU_NAME)

      # Comando principal
      cmd = UI::Command.new(COMMAND_NAME) {
        Exporter.run
      }
      cmd.tooltip = 'Exporta la imagen del Viewport, la imagen Material ID y el archivo JSON de mapeo'
      cmd.status_bar_text = 'Exportar Viewport + Material ID + JSON'

      submenu.add_item(cmd)
    end
  end
end
