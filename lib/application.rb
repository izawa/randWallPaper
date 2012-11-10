# -*- coding: utf-8 -*-
require 'rubygems' unless deployed?
require 'hotcocoa'

ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'Resources', 'himawari.png'))
#ICON = NSBundle.mainBundle.resourcePath.fileSystemRepresentation + 'himawari.png'
ICON2 =  ICON

class NetWallpaper
  include HotCocoa

  def start

    @app = application(name: 'NetWallpaper', delegate: self)
    @status = status_item
    set_status_menu()

    @app.run()
  end

  def set_status_menu
    @menu = status_menu()
    @status.menu = @menu
    # @status.title = "Hello" # アイコンの横にタイトルを付ける
    @status.image = image(:file => ICON, :size => [ 20, 20 ])           if(File.exists?(ICON))
    @status.alternateImage = image(:file => ICON2, :size => [ 40, 40 ]) if(File.exists?(ICON2))
    #@status.setHighlightMode(true)
  end

  def status_menu
    menu(:delegate => self) do |status|
      status.item("Change", :on_action => Proc.new{ change })
      status.item("TEST", key: "w", :on_action => Proc.new{ test })
      status.separator()
      status.submenu(:menu) do |apple|
        apple.item(:about, :title => "About #{NSApp.name}")
        apple.separator()
        apple.item(:preferences, :key => ",").setState(NSOnState) # チェックを付ける
        apple.separator()
        apple.submenu(:services)
        apple.separator()
        apple.item(:hide, :title => "Hide #{NSApp.name}", :key => "h")
        apple.item(:hide_others, :title => "Hide Others", :key => "h", :modifiers => [:command, :alt])
        apple.item(:show_all, :title => "Show All")
        apple.separator()
        apple.item(:quit, :title => "Quit #{NSApp.name}", :key => "q")
      end
      status.separator()
      status.item("Quit", :key => "q", :on_action => Proc.new { @app.terminate(self) })
      status.separator()
      status.item("#{ICON}",  :on_action => Proc.new { @app.terminate(self) })
    end
  end

  def test
    window frame: [100, 100, 300, 200], title: @app.name, style: [:titled, :closable, :miniaturizable] do |win|
      win << label(text: 'Hello from HotCocoa', layout: {start: false})
      win << button(text: 'Ok', on_action: Proc.new { test2 })
    end
  end

  def test2
    print "aaa"
  end



  def change
    wallpaper_dir = File.expand_path("~/myphotos")
    wallpaper_path = Dir.glob("#{wallpaper_dir}/**/*.{jpg,JPG,jpeg,JPEG}").sample
    wallpaper_url = NSURL.fileURLWithPath(wallpaper_path, isDirectory: false)
    workspace = NSWorkspace.sharedWorkspace

    NSScreen.screens.each do |screen|
      wallpaper_path = 
        Dir.glob("#{wallpaper_dir}/**/*.{jpg,JPG,jpeg,JPEG}").sample
      wallpaper_url = NSURL.fileURLWithPath(wallpaper_path, isDirectory: false)
      workspace.setDesktopImageURL(
        wallpaper_url, 
        forScreen:screen, 
        options:nil, 
        error:nil)
    end
  end
end


NetWallpaper.new.start
