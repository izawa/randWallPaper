# -*- coding: utf-8 -*-
require 'rubygems' unless deployed?
require 'hotcocoa'

if deployed?
  ICON = '/Applications' + File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'Resources', 'Himawari.png'))

else
  ICON = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'Resources', 'Himawari.png'))
end
#ICON = NSBundle.mainBundle.resourcePath.fileSystemRepresentation + 'Himawari.png'
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
    @status.image = image(file: ICON, size: [ 20, 20 ]) if(File.exists?(ICON))
    @status.alternateImage = image(file: ICON2, size: [ 20, 20 ]) if(File.exists?(ICON2))
  end

  def status_menu
    menu(delegate: self) do |status|
      status.item("Change", on_action: Proc.new{ change })
      status.separator()
      status.submenu(:menu) do |apple|
        apple.item(:about, title: "About #{NSApp.name}")
        apple.separator()
        apple.item(:preferences, key: ",", on_action: Proc.new{ config } )
        apple.separator()
        apple.submenu(:services)
        apple.separator()
        apple.item(:hide, title: "Hide #{NSApp.name}", key: "h")
        apple.item(:hide_others, title: "Hide Others", key: "h", modifiers: [:command, :alt])
        apple.item(:show_all, title: "Show All")
        apple.separator()
        apple.item(:quit, title: "Quit #{NSApp.name}", key: "q")
      end
      status.separator()
      status.item("Quit", key: "q", on_action: Proc.new { @app.terminate(self) })
    end
  end

  def config
    main_screen = NSScreen.mainScreen.visibleFrame
    window(
      frame: [(main_screen.size.width-400)/2, (main_screen.size.height-100)/2,
        400, 200], title: @app.name + ' Preferences',
      style: [:titled, :closable]) do |win|
      win << view (frame: [100, 100, 400, 200]) do |v|
        v << label(text: '画像ディレクトリ', layout: {start: false}, frame: [26,156, 119, 17])
        v << @img_path = text_field(text: @img_dir, frame:[29, 123, 282, 22])
        @img_path.setEditable(nil)
        v << button(title: '.', on_action: Proc.new{ fsel }, frame:[315, 120, 29,30])
        v << label(text: '自動切り替え時間', layout: {start: false}, frame: [26,73, 228, 17])
        v << @slider = slider(max: 3600, min: 0, tic_marks: 13, frame: [27, 47, 315, 21], on_action: Proc.new {|sec| change_interval(sec) })
        #v << @slider = slider(max: 26, min: 0, tic_marks: 13, frame: [27, 47, 315, 21], on_action: Proc.new {|sec| change_interval(sec) })
        @slider.setAllowsTickMarkValuesOnly(true)
        @slider.setFloatValue(@interval)
        @slider.setContinuous(nil)

        v << label(text: 'なし', frame:[23, 25, 46, 17], font: font(name: "Tahoma", size: 9))
        5.step(60, 5) { |min|
          v << label(text: "#{min}分", frame:[25+min*5, 25, 46, 17], font: font(name: "Tahoma", size: 9))
        }
      end
    end
  end

  def change_interval(sec)
    @interval = sec.to_i
    user_defaults.setObject(sec.to_i, forKey: 'interval')
    user_defaults.synchronize
    start_timer(sec.to_i)
  end

  def start_timer(sec)
    if sec != 0
      @timer.invalidate
      @timer = NSTimer.scheduledTimerWithTimeInterval(
        sec,
        target: self, 
        selector: "change",
        userInfo: nil, 
        repeats: true)
    else
      @timer.invalidate
    end
  end

  def fsel
    panel = NSOpenPanel.openPanel
    panel.setCanChooseFiles(nil)
    panel.setCanChooseDirectories(true)
    if panel.runModal == NSOKButton
      @img_path.text = panel.URLs[0].path
      @img_dir = panel.URLs[0].path
      user_defaults.setObject(panel.URLs[0].path, forKey: 'img_dir')
      user_defaults.synchronize
    end
  end

  def load_prefs
    unless user_defaults.objectForKey('img_dir')
      user_defaults.setObject(File.expand_path("~/Pictures"), forKey: 'img_dir')
      user_defaults.synchronize
    end
    @img_dir = user_defaults.objectForKey('img_dir')

    unless user_defaults.objectForKey('interval')
      user_defaults.setObject(0, forKey: 'interval')
      user_defaults.synchronize
    end
    @interval = user_defaults.objectForKey('interval')

    @timer = NSTimer.scheduledTimerWithTimeInterval(
      999,
      target: self, 
      selector: "test",
      userInfo: nil, 
      repeats: true)
    @timer.invalidate

    start_timer(@interval)
  end

  def change
    wallpaper_dir = @img_dir
    workspace = NSWorkspace.sharedWorkspace

    NSScreen.screens.each do |screen|
      wallpaper_path = 
        Dir.glob("#{wallpaper_dir}/**/*.{jpg,JPG,jpeg,JPEG}").sample
      if wallpaper_path != nil
        wallpaper_url = NSURL.fileURLWithPath(wallpaper_path, isDirectory: false)
        workspace.setDesktopImageURL(
          wallpaper_url, 
          forScreen:screen, 
          options:nil, 
          error:nil)
      end
    end
  end
end


RandWallpaper.new.start
