# -*- coding: utf-8 -*-
require 'rubygems' unless deployed?
require 'hotcocoa'

ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'Resources', 'Himawari.png'))
#ICON = NSBundle.mainBundle.resourcePath.fileSystemRepresentation + 'himawari.png'
ICON2 =  ICON

class RandWallpaper
  include HotCocoa

  def start
    @app = application(name: 'RandWallpaper', delegate: self)
    @status = status_item
    set_status_menu()
    load_prefs()
    @app.run()
  end

  def set_status_menu
    @menu = status_menu()
    @status.menu = @menu
    # @status.title = "Hello" # アイコンの横にタイトルを付ける
    @status.image = image(:file => ICON, :size => [ 20, 20 ])           if(File.exists?(ICON))
    @status.alternateImage = image(:file => ICON2, :size => [ 20, 20 ]) if(File.exists?(ICON2))
    #@status.setHighlightMode(true)
  end

  def status_menu
    menu(:delegate => self) do |status|
      status.item("Change", :on_action => Proc.new{ change })
      status.item("TEST", key: "w", :on_action => Proc.new{ config })
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

  def config
    window(frame: [100, 100, 400, 200], title: @app.name + ' Configuration',
      style: [:titled, :closable, :miniaturizable]) do |win|
      win << view (frame: [100, 100, 400, 200]) do |v|
        v << label(text: '画像ディレクトリ', layout: {start: false}, frame: [26, 137, 119, 17])
        v << @img_path = text_field(text: @img_dir, frame:[29, 107, 282, 22])
        #v << button(title: 'OK', on_action: Proc.new{  }, frame:[307, 13, 59, 32])
        v << button(title: '.', on_action: Proc.new{ fsel }, frame:[315, 102, 29,30])
      #@field.text = "aaa"
        @img_path.setEditable(nil)
      end
    end
  end

  def fsel
    a=NSOpenPanel.openPanel
    a.setCanChooseFiles(nil)
    a.setCanChooseDirectories(true)
    # if a.runModalForDirectory(nil, file:nil) == NSOKButton
    if a.runModal == NSOKButton
      @img_path.text = a.URLs[0].path
      @img_dir = a.URLs[0].path
      user_defaults.setObject(a.URLs[0].path, forKey:'img_dir')
      user_defaults.synchronize
    end
  end

  def load_prefs
    unless user_defaults.objectForKey('img_dir')
      user_defaults.setObject(File.expand_path("~/Pictures"), forKey:'img_dir' )
      p user_defaults.synchronize
    end
    @img_dir = user_defaults.objectForKey('img_dir')
  end


  def change
    #wallpaper_dir = File.expand_path("~/myphotos")
    wallpaper_dir = @img_dir
   
    p wallpaper_dir

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


RandWallpaper.new.start
